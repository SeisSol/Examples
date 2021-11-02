#!/bin/sh

prefix=northridge

#Download the srf file:
wget http://hypocenter.usc.edu/research/SRF/nr6.70-s0000-h0000.txt
#merge line 3 and 4
sed  '3{N;s/\n//;}' nr6.70-s0000-h0000.txt > ${prefix}.srf

# linux
sed -i "s/\r//g" ${prefix}.srf
# mac
#sed -i '' 's/\r//g' ${prefix}.srf

# This assumes SeisSol/SeisSol has been clone in ~
python ~/SeisSol/SeisSol/preprocessing/science/kinematic_models/generate_FL33_input_files.py --spatial_zoom 10 ${prefix}.srf --gen "+proj=tmerc +datum=WGS84 +k=0.9996 +lon_0=-118.5150 +lat_0=34.3440"
