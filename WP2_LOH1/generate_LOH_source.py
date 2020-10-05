import numpy as np
lon=0
lat=0
depth=2
strike=0
dip=90
rake=0
slip1_cm=100
slip2_cm=000
slip3_cm=000
area=3.0866008336686616479e+011
tini=0
dt=0.0002

T=0.1
vtime = np.arange(0, 4, dt)
momentRate_cm =100* 1/T**2 * vtime*np.exp(-vtime/T)

nt1=vtime.shape[0]
nt2=0
nt3=0

fout=open('source.srf', 'w')
fout.write('1.0\n')
fout.write('POINTS 1\n')
fout.write("%f %f %f %f %f %.10e %f %f\n"  %(lon, lat, depth, strike, dip, area, tini, dt))
fout.write("%f %f %d %f %d %f %d\n"  %(rake, slip1_cm, nt1, slip2_cm, nt2, slip3_cm, nt3))
np.savetxt(fout, momentRate_cm, fmt='%.18e')
fout.close()
print('done writing source.srf')
