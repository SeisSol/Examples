from argparse import ArgumentParser
import numpy as np
import scipy.stats as sp_stat
import pandas as pd


def calculate_error_rates(errors_df):
    rate_dicts = []
    for n in pd.unique(errors_df["norm"]):
        for v in pd.unique(errors_df["var"]):
            conv_df = errors_df[(errors_df["norm"] == n) & (errors_df["var"] == v)]
            d = {"norm": n, "var": v}
            resolutions = pd.unique(conv_df["h"])

            for r in range(len(resolutions) - 1):
                error_decay = (
                    conv_df.loc[conv_df["h"] == resolutions[r], "error"].values[0]
                    / conv_df.loc[conv_df["h"] == resolutions[r + 1], "error"].values[0]
                )
                rate = np.log(error_decay) / np.log(resolutions[r] / resolutions[r + 1])
                resolution_decay = "{}->{}".format(
                    np.round(resolutions[r], 3), np.round(resolutions[r + 1], 3)
                )
                d.update({resolution_decay: rate})

            regression = sp_stat.linregress(np.log(conv_df[["h", "error"]].values))
            d.update({"regression": regression.slope})

            rate_dicts.append(d)

    rate_df = pd.DataFrame(rate_dicts)
    return rate_df

cmd_line_parser = ArgumentParser()
cmd_line_parser.add_argument("convergence_file", type=str, default="convergence.csv")
cmd_line_parser.add_argument("--order", type=int, default=3)
cmd_line_parser.add_argument("--arch", type=str, default="dhsw")
cmd_line_parser.add_argument("--equations", type=str, default="elastic")
args = cmd_line_parser.parse_args()

convergence_df = pd.read_csv(args.convergence_file)
convergence_df = convergence_df[
    (convergence_df["order"] == args.order)
    & (convergence_df["arch"] == args.arch)
    & (convergence_df["equations"] == args.equations)
]

rate_df = calculate_error_rates(convergence_df)
print(rate_df)
