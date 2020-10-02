#!/bin/sh

#Download the scec data and unzip the file
wget https://strike.scec.org/cvws/download/tpv29_tpv30_geometry_25m_data.zip --no-check-certificate
unzip tpv29_tpv30_geometry_25m_data.zip

#convert to tpv29_tpv30
python generate_mytopo_tpv29.py

#generate the skin mesh
gmsh -3 tpv29.geo -o tpv29.msh

#compile and run the gmsh_plane2topo
gfortran gmsh_plane2topo.f90 -o gmsh_plane2topo
./gmsh_plane2topo interpol_topo.in

prefix=tpv29_step2
#generate the final mesh
gmsh -3 -optimize_netgen $prefix.geo

# Convert the mesh from msh to neu using gmsh2gambit
#for gmsh2gambit, see https://github.com/SeisSol/SeisSol/tree/master/preprocessing/meshing/gmsh2gambit
gmsh2gambit -i $prefix.msh -o $prefix.neu

# Convert the mesh from neu to hdf5 using pumgen
# for pumgen, see https://github.com/SeisSol/PUMGen/wiki/How-to-compile-PUMGen
pumgen $prefix.neu
