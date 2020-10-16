#!/bin/sh

prefix=tpv33_half
# Generate half a mesh using gmsh
#for gmsh, see http://gmsh.info/#Download
gmsh -3 $prefix.geo

# Convert the mesh from neu to hdf5 using pumgen
# for pumgen, see https://github.com/SeisSol/PUMGen/wiki/How-to-compile-PUMGen
pumgen $prefix.msh -s msh2

#mirror the mesh using mirrorMesh.py (from here https://github.com/SeisSol/Meshing/tree/master/mirrorMesh/mirrorMesh.py)
python mirrorMesh.py $prefix.xdmf 1 0
