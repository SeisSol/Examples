import numpy as np

# Read scec input file
fid = open("tpv29_tpv30_geometry_25m_data.txt")
line = fid.readline()
line = fid.readline()
header = [float(a) for a in line.split()]
nx, ny, lx, ly = header
roughness = np.loadtxt(fid)
roughness = roughness[:, 4]
fid.close()

# create x and y vectors
x = np.linspace(-lx / 2, lx / 2, int(nx) + 1)
y = np.linspace(0, ly, int(ny) + 1)

# write mytopo_tpv29
fout = open("mytopo_tpv29", "w")
fout.write("%d %d\n" % (nx + 1, ny + 1))
np.savetxt(fout, x, fmt="%f")
np.savetxt(fout, y, fmt="%f")
np.savetxt(fout, roughness, fmt="%f")
fout.close()
