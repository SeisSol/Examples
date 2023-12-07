# Generate a dynamic rupture model of the 1994 Northridge informed by a kinematic model

The method used to setup up the dynamic rupture model is derived from the 'stress change family B'
presented in 'Constraining families of dynamic models using geological, geodetical, and strong ground motion data: The Mw 6.5, October 30th, 2016, Norcia earthquake, Italy' by Tinti et. al. (2021).
https://www.sciencedirect.com/science/article/pii/S0012821X21004933
See also https://github.com/git-taufiq/NorciaMultiFault

## To run the setup on heisenbug

1. Discover the seissol modules with
`module use /import/exception-dump/ulrich/spack/modules/linux-debian11-zen2`
2. Load the seissol module
for the GPU version: `module load seissol/` (press Tab and choose a module with cuda)
for the CPU version: `module load seissol/` (press Tab and choose a module without cuda)
3. Load pumgen: `module load pumgen` (choose one of the modules if several available)

## Then you can follow the following workflow

1. run Northridge_FL33
2. regrid the final fault tractions using `projectTractions2Netcdf.py ../Northridge_FL33/output/northridge-fault.xdmf`
3. run the setup

## proposed tasks for exploring the model

1. Compare the fault output of the kinematic model and the dynamic model
2. Change Dc and R and see how they affect the rupture process
3. Find parameters allowing to match the moment rate release of the kinematic model.
Use `python compare_moment_rate.py ../Northridge_FL33/output/northridge ../Northridge_dyn/output/northridge` to compare the moment rate release functions.
