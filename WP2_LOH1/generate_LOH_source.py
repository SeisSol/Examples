import numpy as np
lon=0
lat=0
depth=2
strike=0
dip=90
rake=0
slip1_cm=100 # 1 meter
slip2_cm=000
slip3_cm=000

tini=0
dt=0.0002

M0=1e18
rho=2700.0
vs = 3464.0
mu = vs**2*rho
area=M0/mu*1e4 # m^2 to cm^2

T=0.1
vtime = np.arange(0, 4, dt)
sliprate_cm = slip1_cm * 1/T**2 * vtime*np.exp(-vtime/T)
print('final slip (cm): ', np.trapz(sliprate_cm, vtime))

nt1=vtime.shape[0]
nt2=0
nt3=0

fout=open('source.srf', 'w')
fout.write('1.0\n')
fout.write('POINTS 1\n')
fout.write("%f %f %f %f %f %.10e %f %f\n"  %(lon, lat, depth, strike, dip, area, tini, dt))
fout.write("%f %f %d %f %d %f %d\n"  %(rake, slip1_cm, nt1, slip2_cm, nt2, slip3_cm, nt3))
np.savetxt(fout, sliprate_cm, fmt='%.18e')
fout.close()
print('done writing source.srf')
