
fout=open('LOH1_source_50.dat', 'w')

# Note that we use a moment tensor definition that differs with the standards in Seismology (e.g. Komatitsch and Tromp, 1999).
# the moment tensor is opposite to the usual definition

header=\
""" seismic moment tensor
 0.00000E+00 -0.10000E+19 0.00000E+00
 -0.10000E+19 0.00000E+00 0.00000E+00
 0.00000E+00 0.00000E+00 0.00000E+00
 number of faults
                     1
 x,y,z,strike, dip, rake, area, onset time.
     0.00000     0.00000     2000.00000     0.00000    90.00000     0.00000  1.0     0.00000
 source time function: dela, total sample point
     0.00020                  20000
 samples
"""
fout.write(header)

import numpy as np

#Now write the moment rate:
T=0.1
dt=0.0002
vtime = np.arange(0, 4, dt)
momentRate = 1/T**2 * vtime*np.exp(-vtime/T)
#check that integral is 1
#print(np.trapz(momentRate, vtime))

np.savetxt(fout, momentRate, fmt='%.18e')
fout.close()
print('done writing LOH1_source_50.dat')


