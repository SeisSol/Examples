#!/usr/bin/env python3
import numpy as np

N = 4

def loh1_source(t, T=0.1, slip_cm=100.):
    sliprate_cm = slip_cm * 1/T**2 * t*np.exp(-t/T)
    print('final slip (cm): ', np.trapz(sliprate_cm, t))
    return sliprate_cm

def create_source_file(source_infos, filename):
    with open(filename, 'w') as f: 
        f.write('1.0\n')
        f.write(f'POINTS {len(source_infos)}\n')
        for source_info in source_infos:
            mu = source_info["vs"]**2*source_info["rho"]
            area= source_info["M0"]/mu*1e4 # m^2 to cm^2

            time = np.arange(0, 4, source_info["dt"])
            sliprate = loh1_source(time, source_info["T"], source_info["slip1"])

            nt_1=time.shape[0]
            nt_2=0
            nt_3=0

            f.write(f'{source_info["lon"]} {source_info["lat"]} {source_info["depth"]} {source_info["strike"]} {source_info["dip"]} {area} {source_info["tini"]} {source_info["dt"]}\n')
            f.write(f'{source_info["rake"]} {source_info["slip1"]} {nt_1} {source_info["slip2"]} {nt_2} {source_info["slip3"]} {nt_3}\n')
            np.savetxt(f, sliprate, fmt='%.18e')
    print(f'done writing {filename}')

def create_chunked_source_files(source_infos, filename_base, num_chunks):
    assert(len(source_infos) % num_chunks == 0)
    chunk_len = len(source_infos) // num_chunks
    for c in range(num_chunks):
        chunk_source_infos = [source_infos[i] for i in range(c*chunk_len, (c+1)*chunk_len)]
        chunk_filename = f"{filename_base}_{chunk_len}_{c}.srf"
        create_source_file(chunk_source_infos, chunk_filename)

source_info = {
        "lon": 0.,
        "lat": 0.,
        "depth": 2., # unit is km
        "strike": 0, # unit is km
        "dip": 90 ,
        "rake": 0,
        "slip1": 100., # unit is cm
        "slip2": 0.,
        "slip3": 0.,
        "tini": 0,
        "dt": 0.0002,
        "M0": 1e18, # unit is Pa
        "rho": 2700.0, # unit is kg / m^3
        "vs":  3464.0, # unit is m/s
        "T": 0.1,
}

source_infos = [dict(source_info) for i in range(4) for j in range(4)]
for i in range(N):
    for j in range(N):
        source_infos[i+N*j]["lat"] = (i*1000. - 1000.) / np.pi * 180.
        source_infos[i+N*j]["lon"] = (j*1000. - 1000.) / np.pi * 180.

#create_source_file(source_infos, "source.srf")
create_chunked_source_files(source_infos, "source/source", 1)
create_chunked_source_files(source_infos, "source/source", 2)
create_chunked_source_files(source_infos, "source/source", 4)
create_chunked_source_files(source_infos, "source/source", 16)

