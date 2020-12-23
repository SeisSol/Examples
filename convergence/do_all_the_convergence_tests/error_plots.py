from argparse import ArgumentParser
import numpy as np
import pandas as pd
import os
import errno
import matplotlib.pyplot as plt


def plot_errors(errors_df, var, norm, output_prefix, interactive=False):
    markers = ["o-", "v-", "^-", "s-", "P-", "X-"]
    variable_names = [
        "\sigma_{xx}",
        "\sigma_{yy}",
        "\sigma_{zz}",
        "\sigma_{xy}",
        "\sigma_{yz}",
        "\sigma_{xz}",
        "u",
        "v",
        "w",
    ]
    variable_names_output = [
        "s_xx",
        "s_yy",
        "s_zz",
        "s_xy",
        "s_yz",
        "s_xz",
        "u",
        "v",
        "w",
    ]
    norm_to_latex = {"L1": "L^1", "L2": "L^2", "LInf": "L^\infty"}

    # use LaTeX fonts in the plot
    plt.rcParams.update({"font.size": 32})

    plt.rc("text", usetex=True)
    plt.rc("font", family="serif")
    plt.rc("figure", figsize=(20, 10))

    fig, ax = plt.subplots()
    for i, o in enumerate(pd.unique(errors_df["order"])):
        err_df = errors_df[
            (errors_df["norm"] == norm)
            & (errors_df["order"] == o)
            & (errors_df["var"] == var)
        ]
        ax.plot(
            err_df["h"].values,
            err_df["error"].values,
            markers[i],
            label="order {}".format(o),
        )

    title = "${}$ norm of ${}$".format(norm_to_latex[norm], variable_names[var])
    ax.set_title(title)

    ax.set_xlabel("h")
    ax.set_ylabel("error")
    ax.set_yscale("log")
    ax.set_xscale("log")

    tick_values = np.round(np.unique(errors_df["h"].values), 3)
    ax.set_xticks(tick_values)
    ax.set_xticklabels(tick_values)
    plt.minorticks_off()
    plt.legend()

    if interactive:
        plt.show()
    else:
        plt.savefig(
            output_prefix + "_{}_{}.pdf".format(variable_names_output[var], norm),
            bbox_inches="tight",
        )


cmd_line_parser = ArgumentParser()
cmd_line_parser.add_argument("convergence_file", type=str, default="convergence.csv")
cmd_line_parser.add_argument("--output_dir", type=str, default="plots")
cmd_line_parser.add_argument(
    "--var", type=int, default=-1, help="Specify the variable to plot, -1 for all"
)
cmd_line_parser.add_argument(
    "--norm", type=str, default="LInf", help="Norm, can be LInf, L1, L2"
)
cmd_line_parser.add_argument("--arch", type=str, default="dhsw")
cmd_line_parser.add_argument("--equations", type=str, default="elastic")
args = cmd_line_parser.parse_args()

try:
    os.mkdir(args.output_dir)
except OSError as ex:
    if ex.errno != errno.EEXIST:
        raise

convergence_df = pd.read_csv(args.convergence_file)
convergence_df = convergence_df[
    (convergence_df["arch"] == args.arch)
    & (convergence_df["equations"] == args.equations)
    & (convergence_df["norm"] == args.norm)
]

if args.var == -1:
    for v in pd.unique(convergence_df["var"]):
        plot_errors(
            convergence_df,
            v,
            args.norm,
            os.path.join(args.output_dir, "{}_{}".format(args.arch, args.equations)),
        )
else:
    plot_errors(
        convergence_df,
        args.var,
        args.norm,
        os.path.join(args.output_dir, "{}_{}".format(args.arch, args.equations)),
    )
