#!/usr/bin/env python3
from math import sqrt


def compute_nu(rho):
    if rho < 2060.0:
        return 0.40
    elif rho > 2500.0:
        return 0.25
    else:
        return 0.40 - ((rho - 2060.0) * 0.15 / 440.0)


def compute_rho_mu_lambda(Vp):
    Vp = Vp * 1000.0
    rho = 1865.0 + 0.1579 * Vp
    nu = compute_nu(rho)
    Vs = Vp * sqrt((0.5 - nu) / (1.0 - nu))
    mu = rho * Vs ** 2
    lam = rho * (Vp ** 2 - 2 * Vs ** 2)
    return (rho, mu, lam, 0.01 * Vp, 0.005 * Vp)


# SCEC CVM-H 1D model
aDepth = [-1, 0, 5, 6, 10, 15.5, 16.5, 22.0, 31.0, 33.0, 1000]
aVp = [5.0, 5.0, 5.5, 6.3, 6.3, 6.4, 6.7, 6.75, 6.8, 7.8, 7.8]

smaterial = """!LayeredModel
map: !AffineMap
  matrix:
    zi: [0.0, 0.0, 1.0]
  translation:
    zi: 0
interpolation: linear
parameters: [rho, mu, lambda, Qp, Qs]
nodes:"""


for i in range(len(aDepth)):
    rho, mu, lam, Qp, Qs = compute_rho_mu_lambda(aVp[i])
    smaterial += (
        f"\n   {-aDepth[i]*1e3} : [{rho:.2f} ,{mu:e} ,{lam:e}, {Qp:.2f}, {Qs:.2f}]"
    )

with open("northridge_material.yaml", "w") as fid:
    fid.write(smaterial)
