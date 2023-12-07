# Generate a dynamic rupture model of the 1994 Northridge informed by a kinematic model

## To run the setup on heisenbug

1. Discover the seissol modules with
`module use /import/exception-dump/ulrich/spack/modules/linux-debian11-zen2`
2. Load the seissol module
for the GPU version: `module load seissol/1.1.2-gcc-12.2.0-o4-elas-dunav-single-cuda-6ivbnue`
for the CPU version: `module load seissol/1.1.2-gcc-12.2.0-o4-elas-dunav-single-ma52vgh`
3. Load pumgen: `module load pumgen/bypass-apf-gcc-12.2.0-qpfnhir`

## Then you can get follow the following workflow

1. run Northridge_FL33
2. `projectTractions2Netcdf.py ../Northridge_FL33/output/northridge-fault.xdmf`
3. run the setup

## Task

1. Compare the fault output of the kinematic model and the dynamic model
2. Change Dc and R and see how they affect the rupture process

