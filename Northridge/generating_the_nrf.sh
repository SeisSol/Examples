#!/bin/sh


prefix=northridge

#Download the srf file:
wget http://hypocenter.usc.edu/research/SRF/nr6.70-s0000-h0000.txt

#merge line 3 and 4
sed  '3{N;s/\n//;}' nr6.70-s0000-h0000.txt > ${prefix}.srf

#To find the projected coordinates of the fault center, we apply cs2cs (from proj.4):
echo -118.5150 34.3440 0.0 | cs2cs +proj=lonlat +axis=enu +units=m +to +proj=merc +lon_0=-118 +axis=enu +units=m
# We can then shift the coordinate system to have the fault center at (0,0) using +x_0 and +y_0 options.

#Now we create the nrf file using:
#build rconv following the procedure described at https://github.com/SeisSol/SeisSol/tree/master/preprocessing/science/rconv
#Then run rconv with:
rconv -i $prefix.srf -o $prefix.nrf -m "+proj=merc +lon_0=-118 +y_0=-4050981.42 +x_0=57329.54 +units=m +axis=enu" -x visualization.xdmf
