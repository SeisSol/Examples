import pandas as pd
import numpy as np
import matplotlib.pylab as plt
import argparse
import os


def computeMw(label, time, moment_rate):
    M0 = np.trapz(moment_rate[:], x=time[:])
    Mw = 2.0 * np.log10(M0) / 3.0 - 6.07
    print(f"{label} moment magnitude: {Mw} (M0 = {M0:.4e})")
    return Mw


parser = argparse.ArgumentParser(description="plot moment rate comparison")
parser.add_argument(
    "prefix_paths", nargs="+", help="path to prefix of simulations to plots"
)
parser.add_argument("--labels", nargs="+", help="labels associated with the prefix")
args = parser.parse_args()

fig = plt.figure(figsize=(10, 6), dpi=80)
ax = fig.add_subplot(111)

for i, prefix_path in enumerate(args.prefix_paths):

    df = pd.read_csv(f"{prefix_path}-energy.csv")
    df = df.pivot_table(index="time", columns="variable", values="measurement")
    df["seismic_moment_rate"] = np.gradient(df["seismic_moment"], df.index[1])
    # df.plot(y="seismic_moment_rate", use_index=True)
    label = args.labels[i] if args.labels else os.path.basename(prefix_path)
    Mw = computeMw(label, df.index.values, df["seismic_moment_rate"])
    ax.plot(
        df.index.values,
        df["seismic_moment_rate"] / 1e19,
        label=f"{label} (Mw={Mw:.2f})",
    )

ax.legend(frameon=False, loc="upper right")

ax.set_ylim(bottom=0)

ax.spines["top"].set_visible(False)
ax.spines["right"].set_visible(False)
ax.get_xaxis().tick_bottom()
ax.get_yaxis().tick_left()

ax.set_ylabel(r"moment rate (e19 $\times$ Nm/s)")
ax.set_xlabel("time (s)")


fig.savefig("moment_rate_comparison.png", bbox_inches="tight", transparent=False)
plt.show()
