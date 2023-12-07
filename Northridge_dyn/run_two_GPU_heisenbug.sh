export OMP_NUM_THREADS=4
export OMP_PLACES="cores"
export OMP_PROC_BIND=spread
export SEISSOL_ASAGI_MPI_MODE=OFF
mpirun -n 2 --map-by ppr:1:numa:pe=4 --report-bindings seissol-launch SeisSol_Release_ssm_86_cuda_4_elastic ./parameters.par

