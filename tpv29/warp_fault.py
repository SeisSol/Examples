import numpy as np
import scipy.interpolate as sp_int
import re


def read_fault_geometry(filename):
    with open(filename) as fault_file:
        fault_file.readline()
        header = fault_file.readline().split()
        nx = int(header[0])
        nz = int(header[1])
        dx = float(header[2])
        dz = float(header[3])

        grid_x = np.zeros((nx, nz))
        grid_z = np.zeros((nx, nz))
        values = np.zeros((nx, nz))
        for line in fault_file.readlines():
            result = line.split()
            i = int(result[0]) - 1
            j = int(result[1]) - 1
            grid_x[i, j] = float(result[2])
            grid_z[i, j] = -float(result[3])
            values[i, j] = float(result[4])
    return grid_x[:, 0], grid_z[0, :], values


def create_interpolator(grid_x, grid_z, values):  #
    interp = sp_int.RegularGridInterpolator(
        (grid_x, grid_z), values, bounds_error=False, fill_value=None
    )
    return interp


old_filename = "tpv29.msh"
new_filename = "tpv29-warped.msh"
fault_filename = "tpv29_tpv30_geometry_25m_data.txt"

grid_x, grid_z, values = read_fault_geometry(fault_filename)
interpolator = create_interpolator(grid_x, grid_z, values)
min_x = np.min(grid_x)
max_x = np.max(grid_x)
min_y = np.min(values)
max_y = np.max(values)
min_z = np.min(grid_z)
max_z = np.max(grid_z)


def interpolate_fault(x, y, z):
    if x < min_x:
        dist_x = x - min_x
    elif x > max_x:
        dist_x = x - max_x
    else:
        dist_x = 0.0

    if y < min_y:
        dist_y = y - min_y
    elif y > max_y:
        dist_y = y - max_y
    else:
        dist_y = 0.0

    if z < min_z:
        dist_z = z - min_z
    elif z > max_z:
        dist_z = z - max_z
    else:
        dist_z = 0.0

    dist_squared = dist_x**2 + y**2 + dist_z**2
    taper = np.exp(-dist_squared * (1 / 10000) ** 2)

    new_y = y + interpolator([x, z])[0] * taper
    return x, new_y, z


new_lines = []
node_re = re.compile("(\d+)\s+([-\.\d]+)\s+([-\.\d]+)\s+([-\.\d]+)")
with open(old_filename, "r") as old_file:
    nodes = False
    for line in old_file.readlines():
        if nodes:
            result = node_re.search(line)
            if result:
                index, x, y, z = result.groups()
                x = float(x)
                y = float(y)
                z = float(z)

                new_x, new_y, new_z = interpolate_fault(x, y, z)

                new_lines.append(f"{index} {new_x} {new_y} {new_z}\n")
            else:
                new_lines.append(line)
        else:
            new_lines.append(line)

        if "$Nodes" in line:
            nodes = True
        if "$EndNodes" in line:
            nodes = False

with open(new_filename, "w+") as new_file:
    new_file.writelines(new_lines)
