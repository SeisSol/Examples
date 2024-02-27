from pathlib import Path
import os
import re
import numpy as np
import datetime

nodes = [4, 8, 16, 32, 64]
fused = [1, 4, 8, 16]

scaling_file = "scaling.csv"
log_dir = "../logs/"

def log_re(fused, nodes):
    regex = re.compile(f"SeisSol-LOH1-fused_{fused}-nodes_{nodes}.(.*).out")
    return regex


def find_latest_log(fused, nodes):
    candidates = []
    for filename in os.listdir(log_dir):
        #SeisSol_scale_o3_m25_gts_n50
        filename_re = log_re(fused, nodes)
        result = filename_re.search(filename)
        if result:
            candidates.append((filename, result.groups(1)))

    sorted_candidates = sorted(candidates, key=lambda s: s[1])
    return sorted_candidates[-1][0]


def extract_date(text):
    return datetime.datetime.strptime(text[:19], '%a %b %d %H:%M:%S')
    #text_re = re.compile("^(\w\w\w) (\w\w\w) (\d\d) (\d\d):(\d\d):(\d\d)")
    #result = text_re.search(text).groups()
    #week_day = result[0]
    #month = 

    #return text_re.search(text).groups()


def parse_text(text):
    time = np.nan
    lines = text.split("\n")
    first_line = lines[0]
    last_line = lines[-2]
    begin = extract_date(first_line)
    end = extract_date(last_line)
    time = (end - begin).total_seconds()
    return time

with open(scaling_file, "w") as result_file:
    result_file.write("fused,nodes,time\n")
    for f in fused:
        for n in nodes:
            try:
                filename = find_latest_log(f, n)
                log_file = os.path.join(log_dir, filename)
                result = Path(log_file).read_text()
                time = parse_text(result)
                result_file.write(f"{f},{n},{time}\n")
            except:
                result_file.write(f"{f},{n},N/A\n")

