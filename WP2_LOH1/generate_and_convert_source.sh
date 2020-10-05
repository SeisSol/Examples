#!/bin/bash
# PATH must contain rconv from SeisSol/preprocessing/science/rconv/
rconv -i source.srf -m "+proj=lonlat +datum=WGS84 +units=m +axis=ned" -o source.nrf
