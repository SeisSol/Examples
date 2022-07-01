#!/usr/bin/env python3

# Step 1: Let (x, y, z) be a point at which you want to obtain material properties, 
# in the coordinate system, which is defined as follows:
# x = Distance along strike, in meters, positive to the right.
# y = Depth in meters, positive underground.
# z = Distance perpendicular to the fault, in meters, positive on the far side of the fault.
#
# Step 2: Convert the coordinates into a new coordinate system (X, Y, Z) 
# which is defined as follows
# X = Easting, in UTM coordinates, in meters.
# Y = Northing, in UTM coordinates, in meters.
# Z = Depth in meters, positive underground.
# The UTM (Universal Transverse Mercator) coordinate system used in CVM-H is UTM zone 11, 
# datum NAD 1927, geoid Clarke 1866.
# The (X, Y, Z) coordinates are computed as follows:
# X = 648446 − 0.5802386 x − 0.8144465 y
# Y = 3625237 + 0.8144465 x − 0.5802386 y
# Z = max(z, 100)
#
# Step 3: Place the (X, Y, Z) coordinates into text files, which has three columns as follows:
# Column 1 = Easting X, in meters.
# Column 2 = Northing Y, in meters.
# Column 3 = Depth Z, in meters (positive underground).
#
# This text files are the input file to vx_lite. 
# You can list as many points as you like, one point on each line of the file.

import numpy as np

# model parameters
X_min = -50e3
X_max = 50e3
Y_min = -50e3
Y_max = 50e3
Z_min = 0
Z_max = 50e3
fault_width_min = 0
fault_width_max = 15e3
fault_length_min = -15e3
fault_length_max = 15e3

# generate input points for cvmh data query (refinement zone)
dgrid = 100 # the inner zone has 100 m resolution
x = np.arange(X_min/2,X_max/2+dgrid,dgrid)
y = np.arange(Y_min/2,Y_max/2+dgrid,dgrid)
z = np.arange(fault_width_min,fault_width_max+dgrid,dgrid)
with open("infile-inner", "w") as text_file:
    for k in range (z.size):
        for j in range (y.size):
            for i in range (x.size):
                print('{} {} {}'.format(( 648446 - (0.5802386 * x[i]) - (0.8144465 * y[j])),
                                        (3625237 + (0.8144465 * x[i]) - (0.5802386 * y[j])), 
                                        np.maximum(z[k],100.0)), file=text_file)
                
# generate input points for cvmh data query (outside refinement zone)
dgrid = 1000 # outside the inner zone has 1000 m resolution
x = np.arange(X_min,X_max+dgrid,dgrid)
y = np.arange(Y_min,Y_max+dgrid,dgrid)
z = np.arange(Z_min,Z_max+dgrid,dgrid)
with open("infile-outer", "w") as text_file:
    for k in range (z.size):
        for j in range (y.size):
            for i in range (x.size):
                print('{} {} {}'.format(( 648446 - (0.5802386 * x[i]) - (0.8144465 * y[j])),
                                        (3625237 + (0.8144465 * x[i]) - (0.5802386 * y[j])), 
                                        np.maximum(z[k],100.0)), file=text_file)
                
# generate input points for cvmh data query (on-fault)
fgrid = 100 # the fault has 100 m resolution
x_fault = np.arange(fault_length_min,fault_length_max+fgrid,fgrid)
y_fault = x_fault * 0
z_fault = np.arange(0,fault_width_max+fgrid,fgrid)
with open("infile-fault", "w") as text_file:
    for k in range (z_fault.size):
        for i in range (x_fault.size):
            print('{} {} {}'.format(( 648446 - (0.5802386 * x_fault[i]) - (0.8144465 * y_fault[j])),
                                    (3625237 + (0.8144465 * x_fault[i]) - (0.5802386 * y_fault[j])), 
                                    np.maximum(z_fault[k],100.0)), file=text_file)
