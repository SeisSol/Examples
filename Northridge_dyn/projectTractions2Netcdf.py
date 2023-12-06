#!/usr/bin/env python3
from netCDF4 import Dataset
from scipy.interpolate import griddata
import seissolxdmf
import argparse
import numpy as np
from writeNetcdf import writeNetcdf


class AffineMap:
    def __init__(self, ua, ub, ta, tb):
        # matrix arguments
        self.ua = ua
        self.ub = ub
        # translation arguments
        self.ta = ta
        self.tb = tb


class Grid2D:
    def __init__(self, u, v):
        # matrix arguments
        self.u = u
        self.v = v
        # translation arguments
        self.ug, self.vg = np.meshgrid(u, v)


def Gridto2Dlocal(lengths, myAffineMap, fault_fname, ldataName):
    # project fault coordinates to 2D local coordinate system
    xa = np.dot(faultCentroids, myAffineMap.ua) + myAffineMap.ta
    xb = np.dot(faultCentroids, myAffineMap.ub) + myAffineMap.tb
    print("xa", np.amin(xa), np.amax(xa))
    print("xb", np.amin(xb), np.amax(xb))
    xab = np.vstack((xa, xb)).T

    u = np.arange(min(0.0, np.amin(xa)), max(lengths[0], np.amax(xa)) + dx, dx)
    v = np.arange(min(0.0, np.amin(xb)), max(lengths[1], np.amax(xb)) + dx, dx)
    mygrid = Grid2D(u, v)

    lgridded_myData = []
    for dataName in ldataName:
        # Read Data
        myData = sx.ReadData(dataName, ndt - 1)
        print(dataName, np.amin(myData), np.amax(myData))
        # grid data and tapper to 30MPa
        gridded_myData = griddata(xab, myData, (mygrid.ug, mygrid.vg), method="nearest")
        gridded_myData_lin = griddata(
            xab, myData, (mygrid.ug, mygrid.vg), method="linear", fill_value=np.nan
        )
        print("using linear interpolation when possible, else nearest neighbor")
        ids_in = ~np.isnan(gridded_myData_lin)
        gridded_myData[ids_in] = gridded_myData_lin[ids_in]

        # gridded_myData[gridded_myData > 20e6] = 20e6
        # gridded_myData[gridded_myData < -20e6] = -20e6

        plot_data = True
        if plot_data and dataName == "Pn0":
            import matplotlib.pyplot as plt

            # plt.plot(xa, xb, 'x')
            plt.pcolormesh(mygrid.ug, mygrid.vg, gridded_myData)
            plt.colorbar()
            plt.axis("equal")
            plt.show()
        lgridded_myData.append(gridded_myData)

    return mygrid, lgridded_myData


def WriteAllNetcdf(mygrid, lgridded_myData, sName, ldataName):
    """
    for i, var in enumerate(ldataName):
        writeNetcdf(
            f"{sName}_{var}",
            [mygrid.u, mygrid.v],
            [var],
            [lgridded_myData[i]],
            paraview_readable=True,
        )
    """
    writeNetcdf(
        f"{sName}_Ts0Td0Tn0",
        [mygrid.u, mygrid.v],
        ldataName,
        lgridded_myData,
        paraview_readable=False,
    )


# parsing python arguments
parser = argparse.ArgumentParser(
    description="project 3d fault output from Norcia onto 2d grid to be read with Asagi"
)
parser.add_argument("fault", help="fault.xdmf filename")
args = parser.parse_args()

# Compute fault centroids
sx = seissolxdmf.seissolxdmf(args.fault)

xyz = sx.ReadGeometry()
connect = sx.ReadConnect()
faultCentroids = (1.0 / 3.0) * (
    xyz[connect[:, 0]] + xyz[connect[:, 1]] + xyz[connect[:, 2]]
)

# Read ndt and nElements
ndt = sx.ReadNdt()
nElements = sx.ReadNElements()

# Compute fault normals
faultnormal = np.cross(
    xyz[connect[:, 1]] - xyz[connect[:, 0]], xyz[connect[:, 2]] - xyz[connect[:, 0]]
)
faultnormal = faultnormal / np.linalg.norm(faultnormal, axis=1)[:, None]
# generate grid
# Fault 4
dx = 200.0

# Fault specific data for projecting to 2D local coordinate system
# Fault

faultlength = 20e3
faultwidth = 25e3 
dip = 40*np.pi/180
stk = 122*np.pi/180
top_depth = 5e3

x1=0.5*faultlength*np.sin(stk)
y1=0.5*faultlength*np.cos(stk)


xu1 = np.array([-x1, -y1, -top_depth])
xu2 = np.array([x1, y1, -top_depth])
xd1 = np.array([-x1 + faultwidth* np.cos(stk) * np.cos(dip), -y1 - faultwidth* np.sin(stk) * np.cos(dip), -top_depth -faultwidth*np.sin(dip)])

ua = xu2 - xu1
la = np.linalg.norm(ua)
ua = ua / la
ub = np.cross(faultnormal[100, :], ua)
lb = np.linalg.norm(ub)
ub = ub / lb


ta = -np.dot(xu1, ua)
tb = -np.dot(xu1, ub)

print(
    f"""components: !AffineMap
  matrix:
    ua: [{ua[0]}, {ua[1]}, {ua[2]}]
    ub: [{ub[0]}, {ub[1]}, {ub[2]}]
  translation:
    ua: {ta}
    ub: {tb}
"""
)

myAffineMap = AffineMap(ua, ub, ta, tb)
ldataName = ["Ts0", "Td0", "Pn0"]
grid, lgridded_myData = Gridto2Dlocal([la, lb], myAffineMap, args.fault, ldataName)

fn = "fault"
WriteAllNetcdf(grid, lgridded_myData, fn, ldataName)
