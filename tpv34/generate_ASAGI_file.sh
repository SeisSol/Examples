#!/bin/sh

INSTALL_DIR=/usr/local

# Use the following algorithm to obtain the CVM-H velocity model
#
# Step 1: Let (x, y, z) be a point at which you want to obtain material properties, 
# in the coordinate system, which is defined as follows:
# x = Distance along strike, in meters, positive to the right.
# y = Depth in meters, positive underground.
# z = Distance perpendicular to the fault, in meters, positive on the far side of the fault.
#
# Step 2: Convert the coordinates into a new coordinate system (X, Y, Z) which is defined as follows
# X = Easting, in UTM coordinates, in meters.
# Y = Northing, in UTM coordinates, in meters.
# Z = Depth in meters, positive underground.
# The UTM (Universal Transverse Mercator) coordinate system used in CVM-H is 
# UTM zone 11, datum NAD 1927, geoid Clarke 1866.
# The (X, Y, Z) coordinates are computed as follows:
# X = 648446 − 0.5802386 x − 0.8144465 y
# Y = 3625237 + 0.8144465 x − 0.5802386 y
# Z = max(z, 100)
#
# Step 3: Place the (X, Y, Z) coordinates into text files, 
# which has three columns as follows:
# Column 1 = Easting X, in meters.
# Column 2 = Northing Y, in meters.
# Column 3 = Depth Z, in meters (positive underground).
# This text files are the input file to vx_lite. 
# You can list as many points as you like, one point on each line of the file.
python write_cvmh_input.py

# Step 4: Run the vx_lite program. 
# Download from terminal using wget 
# 'wget --no-check-certificate http://strike.scec.org/cvws/download/cvmh/cvmh-15.1.0.tar.gz'
# 'tar -zxvf cvmh-15.1.0.tar.gz'
# 'cd cvmh-15.1.0'
# './configure --prefix=${INSTALL_DIR}'
# 'make' and 'make check' then 'make install'
# Then, we can issue the following command:
# ${INSTALL_DIR}/bin/vx_lite -s -z dep -m ${INSTALL_DIR}/model < infile > outfile
# In the above command, “${INSTALL_DIR}” is the directory where you installed CVM-H.
# In the command, “infile” is the input file that contains the (X, Y, Z) coordinates, 
# and “outfile” is the
# output file that contains the velocities and densities, as described below.
wget --no-check-certificate http://strike.scec.org/cvws/download/cvmh/cvmh-15.1.0.tar.gz
tar -zxvf cvmh-15.1.0.tar.gz
cd cvmh-15.1.0
./configure --prefix=${INSTALL_DIR}/cvmh-15.1.0
make
make check
make install
${INSTALL_DIR}/cvmh-15.1.0/bin/vx_lite -s -z dep -m ${INSTALL_DIR}/cvmh-15.1.0/model < infile-inner > outfile-inner
${INSTALL_DIR}/cvmh-15.1.0/bin/vx_lite -s -z dep -m ${INSTALL_DIR}/cvmh-15.1.0/model < infile-outer > outfile-outer
${INSTALL_DIR}/cvmh-15.1.0/bin/vx_lite -s -z dep -m ${INSTALL_DIR}/cvmh-15.1.0/model < infile-fault > outfile-fault

# Step 5: Obtain the values of Vp, Vs, and Rho from the vx_lite output file. 
# The output file is a text file that contains 19 columns. 
# Each line of the file corresponds to one input point. 
# The CVM-H User Guide documents all the columns, 
# but for our purposes we are only concerned with the last three columns:
# Column 17: Compressional wave velocity Vp in m/s.
# Column 18: Shear wave velocity Vs in m/s.
# Column 19: Density Rho in kg/m3
#
# Step 6: Check for error.
# If Vp less than 0 or Vs less than 0 or Rho less than 0, then an error has occurred.
#
# Step 7: Enforce minimum velocities.
# If Vp less than 2984 m/s or Vs less than 1400 m/s, 
# then replace the velocity and density values as follows:
# Vp = 2984 m/s
# Vs = 1400 m/s
# Rho = 2220.34 kg/m3
python write_cvmh_output.py
