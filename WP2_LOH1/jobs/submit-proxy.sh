#!/bin/bash
#SBATCH -J SeisSol-proxy
#SBATCH -o ./logs/%x.%j.%N.out
#SBATCH -D ./
#SBATCH --get-user-env
#SBATCH --clusters=cm2_tiny
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mail-type=end
#SBATCH --mail-user=wolf.sebastian@in.tum.de
#SBATCH --export=NONE
#SBATCH --time=0:15:00
  
module load slurm_setup
unset KMP_AFFINITY
export OMP_NUM_THREADS=54
export OMP_PLACES="cores(27)"
. ~/prepare_for_seissol.sh
ulimit -Ss unlimited

~/SeisSol/build_1/SeisSol_proxy_Release_dhsw_6_elastic 100000 100 all
~/SeisSol/build_4/SeisSol_proxy_Release_dhsw_6_elastic 100000 100 all
~/SeisSol/build_8/SeisSol_proxy_Release_dhsw_6_elastic 100000 100 all
~/SeisSol/build_16/SeisSol_proxy_Release_dhsw_6_elastic 100000 100 all
