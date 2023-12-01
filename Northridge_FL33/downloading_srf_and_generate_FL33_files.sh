#!/bin/sh

prefix=northridge

# (When the website is reacheable,) The srf file can be downloaded with:
# wget http://hypocenter.usc.edu/research/SRF/nr6.70-s0000-h0000.txt
#
# merge line 3 and 4
sed  '3{N;s/\n//;}' ../Northridge/nr6.70-s0000-h0000.txt > ${prefix}.srf

sed  -i.bak "s/\r//g" ${prefix}.srf && rm ${prefix}.bak

# This assumes SeisSol/SeisSol has been clone in ~
python ~/SeisSol/SeisSol/preprocessing/science/kinematic_models/generate_FL33_input_files.py --spatial_zoom 10 ${prefix}.srf --gen "+proj=tmerc +datum=WGS84 +k=0.9996 +lon_0=-118.5150 +lat_0=34.3440"
