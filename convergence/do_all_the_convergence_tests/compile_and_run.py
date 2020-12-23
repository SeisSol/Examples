#!/usr/bin/env python3

import os
import subprocess
import errno
import re
from argparse import ArgumentParser
from shutil import copy
from pathlib import Path
import math

### Settings for SuperMUC-NG
# on_a_cluster = True
# host_arch = 'skx'
# orders = range(2,8)
# resolutions = range(2,7)
# compilers = ['mpiicc', 'mpiicpc', 'mpiifor']

### Settings for Sebastians workstation
on_a_cluster = False
host_arch = "hsw"
orders = range(3, 7)
resolutions = range(2, 5)
compilers = ["mpicc", "mpicxx", "mpif90"]

cmd_line_parser = ArgumentParser()
cmd_line_parser.add_argument("seissol_dir", type=str)
cmd_line_parser.add_argument(
    "--steps",
    type=str,
    choices=["build", "prepare", "run", "analyse", "all"],
    default="all",
)
cmd_line_parser.add_argument(
    "--equations",
    type=str,
    choices=["elastic", "viscoelastic", "viscoelastic2", "anisotropic"],
    default="elastic",
)
cmd_line_parser.add_argument("--mpiexec", type=str, default="mpiexec")
args = cmd_line_parser.parse_args()


def partition(nodes):
    if nodes <= 16:
        return "micro"
    elif nodes <= 768:
        return "general"
    return "large"


def num_mechs(eq):
    return 3 if eq.startswith("viscoelastic") else 0


def arch_name(precision, host_arch):
    return precision[0] + host_arch


def seissol_name(arch, eq, o, build_type="Release"):
    return "SeisSol_{}_{}_{}_{}".format(build_type, arch, o, eq)


def cube_name(n, scale):
    return "{}/cube_{}_{}".format(mesh_dir, 2 ** n, scale)


def par_name(eq, n):
    return "{}/parameters_{}_{}.par".format(par_dir, eq, 2 ** n)


def resolution(eq, n):
    return scale_map[eq] / 2 ** n * math.sqrt(3)


def log_name(arch, eq, o, n):
    return "{}_{}_{}_{}.log".format(arch, eq, o, 2 ** n)


def job_name(arch, eq, o, n):
    return "{}_{}_{}_{}.sh".format(arch, eq, o, 2 ** n)


def on_off(boolean):
    return "ON" if boolean else "OFF"


dirs = ("mesh", "par", "logs", "jobs")
mesh_dir, par_dir, log_dir, job_dir = dirs
for d in dirs:
    try:
        os.mkdir(d)
    except OSError as ex:
        if ex.errno != errno.EEXIST:
            raise
convergence_file = "convergence.csv"

cwd = os.getcwd()

os.chdir(args.seissol_dir)

precision = ["single", "double"]
parts = {2: 1, 3: 1, 4: 1, 5: 4, 6: 4}
scales = [2, 100]
scale_map = {"elastic": 2, "viscoelastic": 2, "viscoelastic2": 2, "anisotropic": 2}
end_time = {
    "elastic": "0.1",
    "viscoelastic": "0.1",
    "viscoelastic2": "0.1",
    "anisotropic": "0.1",
}
material_file = {
    "elastic": "material_viscoelastic.yaml",
    "viscoelastic": "material_viscoelastic.yaml",
    "viscoelastic2": "material_viscoelastic.yaml",
    "anisotropic": "material_anisotropic.yaml",
}
initial_condition = {
    "elastic": "PlanarWave",
    "viscoelastic": "PlanarWave",
    "viscoelastic2": "PlanarWave",
    "anisotropic": "SuperimposedPlanarwave",
}

archs = [arch_name(p, host_arch) for p in precision]
equations = args.equations

if args.steps in ["build", "all"]:
    if not os.path.exists("build_convergence"):
        try:
            os.mkdir("build_convergence")
        except OSError as ex:
            if ex.errno != errno.EEXIST:
                raise
    os.chdir("build_convergence")
    for prec in precision:
        for o in orders:
            compile_cmd = (
                "CC={} CXX={} FC={} cmake .. "
                "-DCMAKE_BUILD_TYPE=Release "
                "-DCOMMTHREAD={} "
                "-DEQUATIONS={} "
                "-DGEMM_TOOL_LIST=LIBXSMM,PSpaMM, "
                "-DHOST_ARCH={} "
                "-DNUMBER_OF_MECHANISMS={} "
                "-DORDER={} "
                "-DPRECISION={} "
                "-DTESTING=OFF && make -j8".format(
                    compilers[0],
                    compilers[1],
                    compilers[2],
                    on_off(on_a_cluster),
                    equations,
                    host_arch,
                    num_mechs(equations),
                    o,
                    prec,
                )
            )
            print(compile_cmd)
            try:
                subprocess.check_output(compile_cmd, shell=True)
            except subprocess.CalledProcessError as cpe:
                print("Build command exited with : {}".format(cpe.returncode))
                print(cpe.output)
                quit()
            num_quantities = 9 + 6 * num_mechs(equations)
            sn = seissol_name(arch_name(prec, host_arch), equations, o, "Release")
            copy_source = sn
            copy_target = os.path.join(cwd, sn)
            copy(copy_source, copy_target)

os.chdir(cwd)

if args.steps in ["prepare", "all"]:
    for n in resolutions:
        for scale in scales:
            generate_cmd = (
                "cubeGenerator "
                "-b 6 -x {0} -y {0} -z {0} "
                "--px {1} --py {1} --pz {1} "
                "-o {2}.nc -s {3}".format(2 ** n, parts[n], cube_name(n, scale), scale)
            )
            os.system(generate_cmd)
        parameters = Path("parameters.template").read_text()
        parameters = parameters.replace("MESH_FILE", cube_name(n, scale_map[equations]))
        parameters = parameters.replace("END_TIME", end_time[equations])
        parameters = parameters.replace("MATERIAL_FILE", material_file[equations])
        parameters = parameters.replace(
            "INITIAL_CONDITION", initial_condition[equations]
        )
        with open(par_name(equations, n), "w") as f:
            f.write(parameters)

if args.steps in ["run", "all"]:
    for arch in archs:
        for o in orders:
            for n in resolutions:
                log_file = os.path.join(log_dir, log_name(arch, equations, o, n))
                nodes = parts[n] ** 3
                if not on_a_cluster:
                    run_cmd = "OMP_NUM_THREADS=8 ./{} {}".format(
                        seissol_name(arch, equations, o), par_name(equations, n)
                    )
                    run_cmd += " > " + log_file
                    print(run_cmd)
                    os.system(run_cmd)
                else:
                    run_cmd = "{} -n {} ./{} {}".format(
                        args.mpiexec,
                        nodes,
                        seissol_name(arch, equations, o),
                        par_name(equations, n),
                    )
                    job = Path("job.template").read_text()
                    job = job.replace("WORK_DIR", cwd)
                    job = job.replace("LOG_FILE", log_file)
                    job = job.replace("NODES", str(nodes))
                    job = job.replace("PARTITION", partition(nodes))
                    file_name = os.path.join(job_dir, job_name(arch, equations, o, n))
                    with open(file_name, "w") as f:
                        f.write(job)
                        f.write(run_cmd + "\n")
                    print(
                        "Created SLURM job file {}. Run with sbatch.".format(file_name)
                    )

if args.steps in ["analyse", "all"]:
    with open(convergence_file, "w") as result_file:
        result_file.write("arch,equations,order,h,norm,var,error\n")
        for arch in archs:
            for o in orders:
                for n in resolutions:
                    log_file = os.path.join(log_dir, log_name(arch, equations, o, n))
                    result = Path(log_file).read_text()
                    for line in result.split("\n"):
                        err = re.search(
                            "(LInf|L2|L1)\s*,\s+var\[\s*(\d+)\s*\]\s*=\s*([0-9\.eE+-]+)",
                            line,
                        )
                        if err:
                            result_file.write(
                                "{},{},{},{},{}\n".format(
                                    arch,
                                    equations,
                                    o,
                                    resolution(equations, n),
                                    ",".join([str(g) for g in err.groups()]),
                                )
                            )
