#!/usr/bin/env python3

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

import numpy as np
from netCDF4 import Dataset

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

# read last 3 columns from the 'outfile' files
Vp = 17-1; Vs = 18-1; Rho = 19-1 # python begin from 0!

### inside refinement zone
outfile = open("outfile-inner",'r')
VpVsRho_inner = []
for line in outfile:
    columns = (line.strip().split())
    VpVsRho_inner.append([float(columns[Vp]),
                          float(columns[Vs]),
                          float(columns[Rho])])
VpVsRho_inner = np.asarray(VpVsRho_inner)
# enforce minimum parameter values
VpVsRho_inner[:,0][VpVsRho_inner[:,0]<2984.0]=2984.0 # replace the Vp values less than 2984 m/s
VpVsRho_inner[:,1][VpVsRho_inner[:,1]<1400.0]=1400.0 # replace the Vs values less than 1400 m/s
VpVsRho_inner[:,2][VpVsRho_inner[:,2]<2220.34]=2220.34 # replace the Rho values less than 2220.34 m/s

### outside refinement zone
outfile = open("outfile-outer",'r')
VpVsRho_outer = []
for line in outfile:
    columns = (line.strip().split())
    VpVsRho_outer.append([float(columns[Vp]),
                          float(columns[Vs]),
                          float(columns[Rho])])
VpVsRho_outer = np.asarray(VpVsRho_outer)
# enforce minimum parameter values
VpVsRho_outer[:,0][VpVsRho_outer[:,0]<2984.0]=2984.0 # replace the Vp values less than 2984 m/s
VpVsRho_outer[:,1][VpVsRho_outer[:,1]<1400.0]=1400.0 # replace the Vs values less than 1400 m/s
VpVsRho_outer[:,2][VpVsRho_outer[:,2]<2220.34]=2220.34 # replace the Rho values less than 2220.34 m/s

### on-fault        
outfile = open("outfile-fault",'r')
VpVsRho_fault = []
for line in outfile:
    columns = (line.strip().split())
    VpVsRho_fault.append([float(columns[Vp]),
                          float(columns[Vs]),
                          float(columns[Rho])])
VpVsRho_fault = np.asarray(VpVsRho_fault)
# enforce minimum parameter values
VpVsRho_fault[:,0][VpVsRho_fault[:,0]<2984.0]=2984.0 # replace the Vp values less than 2984 m/s
VpVsRho_fault[:,1][VpVsRho_fault[:,1]<1400.0]=1400.0 # replace the Vs values less than 1400 m/s
VpVsRho_fault[:,2][VpVsRho_fault[:,2]<2220.34]=2220.34 # replace the Rho values less than 2220.34 m/s

### write NetCDF files
# generate tpv34_rhomulambda-inner.nc file
dgrid = 100
x_nc = np.arange(X_min/2,X_max/2+dgrid,dgrid)
y_nc = np.arange(Y_min/2,Y_max/2+dgrid,dgrid)
z_nc = np.arange(fault_width_min,-fault_width_max-dgrid,-dgrid)

VpVsRho_inner = VpVsRho_inner.reshape((len(z_nc),len(y_nc),len(x_nc),3))
rho = VpVsRho_inner[:,:,:,2]
mu  = VpVsRho_inner[:,:,:,1] ** 2 * rho
lam = VpVsRho_inner[:,:,:,0] ** 2 * rho - 2 * mu

print('Writing NetCDF file')
nc = Dataset('tpv34_rhomulambda-inner.nc', "w", format="NETCDF4")
nc.createDimension("x", len(x_nc))
nc.createDimension("y", len(y_nc))
nc.createDimension("z", len(z_nc))

vx = nc.createVariable("x","f4",("x",))
vx[:] = x_nc
vy = nc.createVariable("y","f4",("y",))
vy[:] = y_nc
vz = nc.createVariable("z","f4",("z",))
vz[:] = z_nc

mattype4 = np.dtype([('rho','f4'),('mu','f4'),('lambda','f4')])
mattype8 = np.dtype([('rho','f8'),('mu','f8'),('lambda','f8')])
mattype = nc.createCompoundType(mattype4,'material')

# transform to an array of tuples
arr = np.stack((rho,mu,lam), axis=3)
arr = arr.view(dtype=mattype8)
arr = arr.reshape(arr.shape[:-1])
mat = nc.createVariable("data",mattype,("z","y","x"))
mat[:] = arr
nc.close()
print('Done')

# generate tpv34_rhomulambda-outer.nc file
dgrid = 1000
x_nc = np.arange(X_min,X_max+dgrid,dgrid)
y_nc = np.arange(Y_min,Y_max+dgrid,dgrid)
z_nc = -np.arange(Z_min,Z_max+dgrid,dgrid)

VpVsRho_outer = VpVsRho_outer.reshape((len(z_nc),len(y_nc),len(x_nc),3))
rho = VpVsRho_outer[:,:,:,2]
mu  = VpVsRho_outer[:,:,:,1] ** 2 * rho
lam = VpVsRho_outer[:,:,:,0] ** 2 * rho - 2 * mu

print('Writing NetCDF file')
nc = Dataset('tpv34_rhomulambda-outer.nc', "w", format="NETCDF4")

nc.createDimension("x", len(x_nc))
nc.createDimension("y", len(y_nc))
nc.createDimension("z", len(z_nc))

vx = nc.createVariable("x","f4",("x",))
vx[:] = x_nc
vy = nc.createVariable("y","f4",("y",))
vy[:] = y_nc
vz = nc.createVariable("z","f4",("z",))
vz[:] = z_nc

mattype4 = np.dtype([('rho','f4'),('mu','f4'),('lambda','f4')])
mattype8 = np.dtype([('rho','f8'),('mu','f8'),('lambda','f8')])
mattype = nc.createCompoundType(mattype4,'material')

# transform to an array of tuples
arr = np.stack((rho,mu,lam), axis=3)
arr = arr.view(dtype=mattype8)
arr = arr.reshape(arr.shape[:-1])
mat = nc.createVariable("data",mattype,("z","y","x"))
mat[:] = arr
nc.close()
print('Done')

# generate tpv34_mux-fault.nc file
fgrid = 100
x_nc = np.arange(fault_length_min,fault_length_max+fgrid,fgrid)
z_nc = np.arange(fault_width_min,-fault_width_max-fgrid,-fgrid)

VpVsRho_fault = VpVsRho_fault.reshape((len(z_nc),len(x_nc),3))
rho = VpVsRho_fault[:,:,2]
mu  = VpVsRho_fault[:,:,1] ** 2 * rho
# mu0 is the value of the shear modulus in benchmark TPV5 and many other benchmarks
mu0 = 32038120320.0 # in Pa
mux = mu / mu0

print('Writing NetCDF file')
nc = Dataset('tpv34_mux-fault.nc', "w", format="NETCDF4")

nc.createDimension("x", len(x_nc))
nc.createDimension("z", len(z_nc))

vx = nc.createVariable("x","f4",("x",))
vx[:] = x_nc
vz = nc.createVariable("z","f4",("z",))
vz[:] = z_nc

mattype4 = np.dtype([('mux','f4')])
mattype8 = np.dtype([('mux','f8')])
mattype = nc.createCompoundType(mattype4,'material')

mat = nc.createVariable("data",mattype,("z","x"))
mat[:] = mux
nc.close()
print('Done')
