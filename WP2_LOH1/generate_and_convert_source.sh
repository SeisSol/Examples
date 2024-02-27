#!/bin/bash
set -euo pipefail

# PATH must contain rconv from SeisSol/preprocessing/science/rconv/
python3 generate_LOH_source.py
for fn in source/*.srf
do
  rconv -i $fn -m "+proj=lonlat +datum=WGS84 +units=m +axis=ned" -o ${fn%srf}nrf
done
