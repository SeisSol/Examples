#!/bin/bash
set -euo pipefail

prefix=tpv12_13_example
# Generate the mesh using gmsh
#for gmsh, see http://gmsh.info/#Download
gmsh -3 $prefix.geo

# Convert the mesh from neu to hdf5 using pumgen
# for pumgen, see https://github.com/SeisSol/PUMGen/wiki/How-to-compile-PUMGen
pumgen $prefix.msh -s msh2
