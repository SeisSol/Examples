#!/bin/bash
#SBATCH -J SeisSol-LOH1-fused_4-nodes_4
#SBATCH -o logs/%x.%j.%N.out
#SBATCH -D ./
#SBATCH --get-user-env
#SBATCH --clusters=cm2
#SBATCH --partition=cm2_std
#SBATCH --qos=cm2_std
#SBATCH --nodes=4
#SBATCH --ntasks-per-node=1
#SBATCH --mail-type=end
#SBATCH --mail-user=wolf.sebastian@in.tum.de
#SBATCH --export=NONE
#SBATCH --time=16:00:00
  
module load slurm_setup
unset KMP_AFFINITY
export OMP_NUM_THREADS=54
export OMP_PLACES="cores(27)"
. ~/prepare_for_seissol.sh
ulimit -Ss unlimited
srun ./SeisSol_Release_dhsw_6_elastic-4 pars/parameters-fused_04-nodes_04-00.par
srun ./SeisSol_Release_dhsw_6_elastic-4 pars/parameters-fused_04-nodes_04-01.par
srun ./SeisSol_Release_dhsw_6_elastic-4 pars/parameters-fused_04-nodes_04-02.par
srun ./SeisSol_Release_dhsw_6_elastic-4 pars/parameters-fused_04-nodes_04-03.par
