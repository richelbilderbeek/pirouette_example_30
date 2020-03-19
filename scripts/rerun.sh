#!/bin/bash
#
# Re-run the code locally, to re-create the data and figure.
#
# Usage:
#
#   ./scripts/rerun.sh
#
#SBATCH --partition=gelifes
#SBATCH --time=2:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --ntasks=1
#SBATCH --mem=10G
#SBATCH --job-name=pirex30
#SBATCH --output=example_30.log
#
rm -rf example_30
rm errors.png
time Rscript example_30.R
zip -r pirouette_example_30.zip example_30 example_30.R scripts errors.png

