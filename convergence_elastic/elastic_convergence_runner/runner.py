import os
import shutil
import subprocess
from progress.bar import Bar
from jinja2 import Environment, FileSystemLoader
import pandas as pd
from typing import List


class SysCode:
  ok = 0


class Runner:
  def __init__(self, seissol_exe, end_time, tmp_dir, allow_to_run_as_root, verbose):
    self._seissol_exe: str = seissol_exe
    self._end_time: float = end_time
    self._tmp_dir: str = tmp_dir
    self._allow_to_run_as_root: bool = allow_to_run_as_root
    self._verbose: bool = verbose
    
    self._base_mesh_file_name = 'cube'
    self._static_files = os.path.abspath(os.path.join(__file__, '../../static_files'))
    self._curr_dir: str = os.path.abspath(os.path.join(__file__, '..'))
    self._cure_data_dir = os.path.join(self._curr_dir, 'template')
    self._curr_working_dir = None
    
    self._data = []
    
    env = Environment(loader=FileSystemLoader(searchpath=self._cure_data_dir))
    self._param_file_template = env.get_template('parameters.tmpl')
    
    self._check()
  
  def _check(self):
    if not os.path.exists(self._seissol_exe):
      raise RuntimeError(f'provided SeisSol executable does not exist, given `{self._seissol_exe}`')

    process = subprocess.run(f'which cubeGenerator',
                             shell=True,
                             stdout=subprocess.PIPE,
                             stderr=subprocess.PIPE)

    if process.returncode == SysCode.ok:
      print('found cubeGenerator...')
    else:
      raise RuntimeError('cannot find cubeGenerator. Please, install from SeisSol sources. '
                         'Location: SeisSol/preprocessing/meshing/cube_c')
  
  def _copy(self, working_dir):
    files = ['material.yaml', 'recordPoints.dat']
    for file in files:
      src = os.path.join(self._static_files, file)
      shutil.copy(src=src, dst=working_dir)

  def _generate_mesh(self, size):
    dst_mesh_file = os.path.join(self._curr_working_dir, f'{self._base_mesh_file_name}_{size}.nc')
    
    params = f'-b 6 -x {size} -y {size} -z {size}'
    params += ' --px 1 --py 1 --pz 1'
    params += f' -o {dst_mesh_file} -s 2'
    
    process = subprocess.run(f'cubeGenerator {params}',
                             shell=True,
                             stdout=subprocess.PIPE,
                             stderr=subprocess.PIPE)

    if process.returncode != SysCode.ok:
      raise RuntimeError(f'cubeGenerator ERROR: {process.stderr}')
    
    if self._verbose:
      for line in process.stdout.splitlines():
        print(line)
      
  def _generate_param_file(self, size):
    param = self._param_file_template.render(mesh_file=f'{self._base_mesh_file_name}_{size}',
                                             end_time=self._end_time,
                                             working_dir=self._curr_working_dir)
  
    with open(os.path.join(self._curr_working_dir, 'parameters.par'), 'w') as file:
      file.write(param)
      
  def _run(self):
    param_file = os.path.join(self._curr_working_dir, 'parameters.par')
    aux_args = '--allow-run-as-root' if self._allow_to_run_as_root else ''
    process = subprocess.run(f'mpirun {aux_args} -n 1 {self._seissol_exe} {param_file}',
                             shell=True,
                             stdout=subprocess.PIPE,
                             stderr=subprocess.PIPE)
    
    if process.returncode != SysCode.ok:
      raise RuntimeError(f'Seissol ERROR: {process.stderr}')

    if self._verbose:
      for line in process.stdout.splitlines():
        print(line)
        
  def _collect_results(self, size):
    csv_file_path = os.path.join(self._tmp_dir, f'{size}_analysis.csv')
    collected_results = pd.read_csv(csv_file_path, sep=',')
    self._data.append({size: collected_results})
    
  def run_all(self, sizes: List[int]):
    try:
      with Bar('convergence runner...    ', max=len(sizes)) as bar:
        for size in sizes:
          self._curr_working_dir = os.path.join(self._tmp_dir, str(size))
          os.makedirs(self._curr_working_dir, exist_ok=True)
          self._copy(self._curr_working_dir)
          self._generate_mesh(size)
          self._generate_param_file(size)
          self._run()
          self._collect_results(size)
          bar.next()
        
    except RuntimeError as err:
      print(err)
      raise err
      
    return self._data
