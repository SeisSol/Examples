#!/bin/bash
# PATH must contain cubeGenerator from SeisSol/preprocessing/meshing/cube_c/
S=2
cubeGenerator -b 6 -x 4 -y 4 -z 4 --px 1 --py 1 --pz 1 -o cube_4.nc -s $S
cubeGenerator -b 6 -x 8 -y 8 -z 8 --px 1 --py 1 --pz 1 -o cube_8.nc -s $S
cubeGenerator -b 6 -x 16 -y 16 -z 16 --px 1 --py 1 --pz 1 -o cube_16.nc -s $S
cubeGenerator -b 6 -x 32 -y 32 -z 32 --px 1 --py 1 --pz 1 -o cube_32.nc -s $S

