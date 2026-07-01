#!/bin/bash
#SBATCH --job-name=snakemake
#SBATCH --output=%x_%j.log
#SBATCH --error=%x_%j.log
#SBATCH --time=05:00:00
#SBATCH --cpus-per-task=12
#SBATCH --mem=128G

set -e

source ~/work/miniforge/etc/profile.d/conda.sh #YOUR CONDA INSTALLATION
conda activate snakemake #YOUR SNAKEMAKE ENV

cd ~/work/SODAR #YOUR SODAR DIR

snakemake --use-conda --cores 12 --resources mem_mb=128000



#AUTOMATICALLY RUNS THE PIPELINE VIA SLURM
#ONCE CONFIG FILE IS READY, SUBMIT THIS SCRIPT WITH: sbatch submit_snakemake.sh