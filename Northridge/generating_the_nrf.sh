#!/bin/sh

prefix=northridge

#Download the srf file:
wget http://hypocenter.usc.edu/research/SRF/nr6.70-s0000-h0000.txt
#merge line 3 and 4
sed  '3{N;s/\n//;}' nr6.70-s0000-h0000.txt > ${prefix}.srf
sed -i "s/\r//g" ${prefix}.srf

# Now upsample the srf file with this script:
# This assumes SeisSol/SeisSol has been clone in ~
python ~/SeisSol/SeisSol/preprocessing/science/kinematic_models/refine_srf.py ${prefix}.srf --spatial_zoom 10 --temporal_zoom 10

#Now we create the nrf file using:
#build rconv following the procedure described at https://github.com/SeisSol/SeisSol/tree/master/preprocessing/science/rconv
#Then run rconv with:
rconv -i ${prefix}_resampled.srf -o $prefix.nrf -m "+proj=tmerc +datum=WGS84 +k=0.9996 +lon_0=-118.5150 +lat_0=34.3440" -x visualization.xdmf
