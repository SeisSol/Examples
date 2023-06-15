#!/bin/bash
set -euo pipefail

#Download the scec data and unzip the file
wget https://strike.scec.org/cvws/download/tpv29_tpv30_geometry_25m_data.zip --no-check-certificate
unzip tpv29_tpv30_geometry_25m_data.zip

#convert to tpv29_tpv30
python generate_mytopo_tpv29.py

#generate the skin mesh
gmsh -3 tpv29.geo

#compile and run the gmsh_plane2topo
gfortran gmsh_plane2topo.f90 -o gmsh_plane2topo
./gmsh_plane2topo interpol_topo.in

