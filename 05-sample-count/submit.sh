#!/bin/bash -e

#SBATCH -J sample-count
#SBATCH -A DSMITH-BIOCLOUD
#SBATCH -o slurm-%A.out
#SBATCH -p biocloud-normal
#SBATCH --time=10:00:00

srun -n 1 sample-count.sh
