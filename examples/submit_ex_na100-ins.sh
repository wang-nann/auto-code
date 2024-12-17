#!/bin/bash
#SBATCH --partition=na100-ins
#SBATCH --job-name=DDsR_13500
#SBATCH --output=DDsR.log
#SBATCH --error=DDsR.log
#SBATCH --nodes=1
#SBATCH --ntasks 2
#SBATCH --cpus-per-task=6
# #SBATCH -n 12
# #SBATCH --exclusive
# #SBATCH --nodelist= 
#SBATCH --time=3-00:00:00
#SBATCH --gres=gpu:2

# GPU8  36 Phyisical cores
# DGX2  48 Phyisical cores
export export OMP_NUM_THREADS=6
export QUDA_RESOURCE_PATH=/public/home/liangj/works/DDs_R_decay/tune_2401/

if ! [ -e ./res_2/corr3_lc_c_ts_00_pf_001_io_a0-rho_z_1_gs_15.013500 ]; then
	mpirun -np  2 ./chroma_addon -geom 1 1 1 2 -i inputs/generate_chroma_ini_13500.xml >logs/generate_chroma_ini_13500.xml.log 2>&1
fi
