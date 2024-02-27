#!/bin/bash
#SBATCH -J SeisSol-LOH1-fused_1-nodes_64
#SBATCH -o logs/%x.%j.%N.out
#SBATCH -D ./
#SBATCH --get-user-env
#SBATCH --clusters=cm2
#SBATCH --partition=cm2_large
#SBATCH --qos=cm2_large
#SBATCH --nodes=64
#SBATCH --ntasks-per-node=1
#SBATCH --mail-type=end
#SBATCH --mail-user=wolf.sebastian@in.tum.de
#SBATCH --export=NONE
#SBATCH --time=2:30:00
  
module load slurm_setup
unset KMP_AFFINITY
export OMP_NUM_THREADS=54
export OMP_PLACES="cores(27)"
. ~/prepare_for_seissol.sh
ulimit -Ss unlimited
srun ./SeisSol_Release_dhsw_6_elastic-1 pars/parameters-fused_01-nodes_64-00.par
srun ./SeisSol_Release_dhsw_6_elastic-1 pars/parameters-fused_01-nodes_64-01.par
srun ./SeisSol_Release_dhsw_6_elastic-1 pars/parameters-fused_01-nodes_64-02.par
srun ./SeisSol_Release_dhsw_6_elastic-1 pars/parameters-fused_01-nodes_64-03.par
srun ./SeisSol_Release_dhsw_6_elastic-1 pars/parameters-fused_01-nodes_64-04.par
srun ./SeisSol_Release_dhsw_6_elastic-1 pars/parameters-fused_01-nodes_64-05.par
srun ./SeisSol_Release_dhsw_6_elastic-1 pars/parameters-fused_01-nodes_64-06.par
srun ./SeisSol_Release_dhsw_6_elastic-1 pars/parameters-fused_01-nodes_64-07.par
srun ./SeisSol_Release_dhsw_6_elastic-1 pars/parameters-fused_01-nodes_64-08.par
srun ./SeisSol_Release_dhsw_6_elastic-1 pars/parameters-fused_01-nodes_64-09.par
srun ./SeisSol_Release_dhsw_6_elastic-1 pars/parameters-fused_01-nodes_64-10.par
srun ./SeisSol_Release_dhsw_6_elastic-1 pars/parameters-fused_01-nodes_64-11.par
srun ./SeisSol_Release_dhsw_6_elastic-1 pars/parameters-fused_01-nodes_64-12.par
srun ./SeisSol_Release_dhsw_6_elastic-1 pars/parameters-fused_01-nodes_64-13.par
srun ./SeisSol_Release_dhsw_6_elastic-1 pars/parameters-fused_01-nodes_64-14.par
srun ./SeisSol_Release_dhsw_6_elastic-1 pars/parameters-fused_01-nodes_64-15.par
