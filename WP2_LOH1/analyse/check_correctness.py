import os
import pandas as pd
import re
import numpy as np
import matplotlib.pyplot as plt


def find_receivers(prefix, directory="output-nodes_04"):
    receivers = {}
    filename_re = re.compile(f"{prefix}-receiver-(.*)-(.*).dat")
    for filename in os.listdir(directory):
        result = filename_re.search(filename)
        if result:
            receivers[int(result.group(1))] = os.path.join(directory, filename)
    return receivers


def relative_norm(a, b):
    return np.linalg.norm(a - b) / np.linalg.norm(b)

def plot(receivers_8_df, receivers_4_df, receivers_1_df, receiver_idx, source_idx, quantity_idx):
    #plt.plot(receivers_16_df[receiver_idx][source_idx//NUM_SOURCES][1+9*(source_idx%16)+quantity_idx], label="16")
    plt.plot(receivers_8_df[receiver_idx][2*source_idx//NUM_SOURCES][1+9*(source_idx%8)+quantity_idx], label="8")
    plt.plot(receivers_4_df[receiver_idx][2*source_idx//NUM_SOURCES][1+9*(source_idx%4)+quantity_idx], label="4")
    plt.plot(receivers_1_df[receiver_idx][source_idx][1+quantity_idx], label="non-fused")
    plt.legend()
    plt.show()


NUM_RECEIVERS = 9
NUM_SOURCES = 16
THRESHOLD = 1e-10
#receivers_16_fn = [find_receivers(f"loh1-fused_16-{i:02}") for i in range(NUM_SOURCES // 16)]
receivers_8_fn = [find_receivers(f"loh1-fused_08-{i:02}") for i in range(NUM_SOURCES // 8)]
receivers_4_fn = [find_receivers(f"loh1-fused_04-{i:02}") for i in range(NUM_SOURCES//4)]
receivers_1_fn = [find_receivers(f"loh1-fused_01-{i:02}") for i in range(NUM_SOURCES)]

print("Start reading receivers...")
#receivers_16_df = [
#    [
#        pd.read_csv(receivers_16_fn[i][j], header=None, skiprows=5, sep="\s+")
#        for i in range(NUM_SOURCES // 16)
#    ]
#    for j in range(1, NUM_RECEIVERS + 1)
#]
receivers_8_df = [
    [
        pd.read_csv(receivers_8_fn[i][j], header=None, skiprows=5, sep="\s+")
        for i in range(NUM_SOURCES // 8)
    ]
    for j in range(1, NUM_RECEIVERS + 1)
]
receivers_4_df = [[pd.read_csv(receivers_4_fn[i][j], header=None, skiprows=5, sep="\s+") for i in range(NUM_SOURCES//4)] for j in range(1, NUM_RECEIVERS+1)]
receivers_1_df = [
    [
        pd.read_csv(receivers_1_fn[i][j], header=None, skiprows=5, sep="\s+")
        for i in range(NUM_SOURCES)
    ]
    for j in range(1, NUM_RECEIVERS + 1)
]
print("Done!")

for source_idx in range(NUM_SOURCES):
    print(f"Check Source {source_idx}...")
    for receiver_idx in range(NUM_RECEIVERS):
        for quantity_idx in range(9):
            # print(source_idx, receiver_idx, quantity_idx)

            local_1 = receivers_1_df[receiver_idx][source_idx][1 + quantity_idx]

            #local_16 = receivers_16_df[receiver_idx][source_idx // NUM_SOURCES][
            #    1 + 9 * (source_idx % 16) + quantity_idx
            #]
            #misfit_16 = relative_norm(local_16, local_1)
            #assert (
            #    misfit_16 < THRESHOLD
            #), f"Source {source_idx}, receiver {receiver_idx}, quantity {quantity_idx}, fused 16 does not match with non-fused result: {misfit_16}."

            local_8 = receivers_8_df[receiver_idx][2 * source_idx // NUM_SOURCES][
                1 + 9 * (source_idx % 8) + quantity_idx
            ]
            misfit_8 = relative_norm(local_8, local_1)
            assert (
                misfit_8 < THRESHOLD
            ), f"Source {source_idx}, receiver {receiver_idx}, quantity {quantity_idx}, fused 8 does not match with non-fused result: {misfit_8}."

            local_4 = receivers_4_df[receiver_idx][4*source_idx//NUM_SOURCES][1+9*(source_idx%4)+quantity_idx]
            misfit_4 = relative_norm(local_4, local_1)
            if misfit_4 > THRESHOLD:
                print(f"Source {source_idx}, receiver {receiver_idx}, quantity {quantity_idx}, fused 4 does not match with non-fused result: {misfit_4}.")
                plot(receivers_8_df, receivers_4_df, receivers_1_df, receiver_idx, source_idx, quantity_idx) 
    print("Done!")
