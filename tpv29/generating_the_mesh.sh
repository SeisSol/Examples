#!/bin/bash
set -euo pipefail

#Download the scec data and unzip the file
wget https://strike.scec.org/cvws/download/tpv29_tpv30_geometry_25m_data.zip --no-check-certificate
unzip tpv29_tpv30_geometry_25m_data.zip

# Create axis-aligned mesh
gmsh -3 -algo hxt tpv29.geo 
# Warp mesh
python warp_fault.py
gmsh -3 tpv29.geo
# Create PUMGen mesh
pumgen -s msh2 tpv29-warped.msh
