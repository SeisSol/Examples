#!/bin/bash
#SBATCH -J SeisSol-LOH1-fused_1-nodes_32
#SBATCH -o logs/%x.%j.%N.out
#SBATCH -D ./
#SBATCH --get-user-env
#SBATCH --clusters=cm2
#SBATCH --partition=cm2_large
#SBATCH --qos=cm2_large
#SBATCH --nodes=32
#SBATCH --ntasks-per-node=1
#SBATCH --mail-type=end
#SBATCH --mail-user=wolf.sebastian@in.tum.de
#SBATCH --export=NONE
#SBATCH --time=3:00:00
  
module load slurm_setup
unset KMP_AFFINITY
export OMP_NUM_THREADS=54
export OMP_PLACES="cores(27)"
. ~/prepare_for_seissol.sh
ulimit -Ss unlimited
srun ./SeisSol_Release_dhsw_6_elastic-1 pars/parameters-fused_01-nodes_32-00.par
srun ./SeisSol_Release_dhsw_6_elastic-1 pars/parameters-fused_01-nodes_32-01.par
srun ./SeisSol_Release_dhsw_6_elastic-1 pars/parameters-fused_01-nodes_32-02.par
srun ./SeisSol_Release_dhsw_6_elastic-1 pars/parameters-fused_01-nodes_32-03.par
srun ./SeisSol_Release_dhsw_6_elastic-1 pars/parameters-fused_01-nodes_32-04.par
srun ./SeisSol_Release_dhsw_6_elastic-1 pars/parameters-fused_01-nodes_32-05.par
srun ./SeisSol_Release_dhsw_6_elastic-1 pars/parameters-fused_01-nodes_32-06.par
srun ./SeisSol_Release_dhsw_6_elastic-1 pars/parameters-fused_01-nodes_32-07.par
srun ./SeisSol_Release_dhsw_6_elastic-1 pars/parameters-fused_01-nodes_32-08.par
srun ./SeisSol_Release_dhsw_6_elastic-1 pars/parameters-fused_01-nodes_32-09.par
srun ./SeisSol_Release_dhsw_6_elastic-1 pars/parameters-fused_01-nodes_32-10.par
srun ./SeisSol_Release_dhsw_6_elastic-1 pars/parameters-fused_01-nodes_32-11.par
srun ./SeisSol_Release_dhsw_6_elastic-1 pars/parameters-fused_01-nodes_32-12.par
srun ./SeisSol_Release_dhsw_6_elastic-1 pars/parameters-fused_01-nodes_32-13.par
srun ./SeisSol_Release_dhsw_6_elastic-1 pars/parameters-fused_01-nodes_32-14.par
srun ./SeisSol_Release_dhsw_6_elastic-1 pars/parameters-fused_01-nodes_32-15.par
