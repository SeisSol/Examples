#!/bin/bash
#SBATCH -J SeisSol-LOH1-fused_1-nodes_16
#SBATCH -o logs/%x.%j.%N.out
#SBATCH -D ./
#SBATCH --get-user-env
#SBATCH --clusters=cm2
#SBATCH --partition=cm2_std
#SBATCH --qos=cm2_std
#SBATCH --nodes=16
#SBATCH --ntasks-per-node=1
#SBATCH --mail-type=end
#SBATCH --mail-user=wolf.sebastian@in.tum.de
#SBATCH --export=NONE
#SBATCH --time=5:00:00
  
module load slurm_setup
unset KMP_AFFINITY
export OMP_NUM_THREADS=54
export OMP_PLACES="cores(27)"
. ~/prepare_for_seissol.sh
ulimit -Ss unlimited
srun ./SeisSol_Release_dhsw_6_elastic-1 pars/parameters-fused_01-nodes_16-00.par
srun ./SeisSol_Release_dhsw_6_elastic-1 pars/parameters-fused_01-nodes_16-01.par
srun ./SeisSol_Release_dhsw_6_elastic-1 pars/parameters-fused_01-nodes_16-02.par
srun ./SeisSol_Release_dhsw_6_elastic-1 pars/parameters-fused_01-nodes_16-03.par
srun ./SeisSol_Release_dhsw_6_elastic-1 pars/parameters-fused_01-nodes_16-04.par
srun ./SeisSol_Release_dhsw_6_elastic-1 pars/parameters-fused_01-nodes_16-05.par
srun ./SeisSol_Release_dhsw_6_elastic-1 pars/parameters-fused_01-nodes_16-06.par
srun ./SeisSol_Release_dhsw_6_elastic-1 pars/parameters-fused_01-nodes_16-07.par
srun ./SeisSol_Release_dhsw_6_elastic-1 pars/parameters-fused_01-nodes_16-08.par
srun ./SeisSol_Release_dhsw_6_elastic-1 pars/parameters-fused_01-nodes_16-09.par
srun ./SeisSol_Release_dhsw_6_elastic-1 pars/parameters-fused_01-nodes_16-10.par
srun ./SeisSol_Release_dhsw_6_elastic-1 pars/parameters-fused_01-nodes_16-11.par
srun ./SeisSol_Release_dhsw_6_elastic-1 pars/parameters-fused_01-nodes_16-12.par
srun ./SeisSol_Release_dhsw_6_elastic-1 pars/parameters-fused_01-nodes_16-13.par
srun ./SeisSol_Release_dhsw_6_elastic-1 pars/parameters-fused_01-nodes_16-14.par
srun ./SeisSol_Release_dhsw_6_elastic-1 pars/parameters-fused_01-nodes_16-15.par
