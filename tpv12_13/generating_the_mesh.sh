#!/bin/sh
prefix=tpv12_13_example
# Generate the mesh using gmsh
#for gmsh, see http://gmsh.info/#Download
gmsh -3 $prefix.geo

# Convert the mesh from msh to neu using gmsh2gambit
#for gmsh2gambit, see https://github.com/SeisSol/SeisSol/tree/master/preprocessing/meshing/gmsh2gambit
gmsh2gambit -i $prefix.msh -o $prefix.neu

# Convert the mesh from neu to hdf5 using pumgen
# for pumgen, see https://github.com/SeisSol/PUMGen/wiki/How-to-compile-PUMGen
pumgen $prefix.neu
