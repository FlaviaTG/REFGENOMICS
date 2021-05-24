#!/bin/bash
#SBATCH -p remotedesktop
#SBATCH -n 10
#SBATCH -N 1
#SBATCH --mem 40000
#SBATCH -t 3-00:00
#SBATCH -J maffilter
#SBATCH -o maffilter_%j.err
#SBATCH -e maffilter_%j.err
#SBATCH --mail-type=ALL        # Type of email notification- BEGIN,END,FAIL,ALL
#SBATCH --mail-user=ftermignoni@fas.harvard.edu # Email to which notifications will be sent

module load Anaconda/5.0.1-fasrc02

source activate ucsc

cd /n/holyscratch01/edwards_lab/ftermignoni/Jclark-reseq/coalHMM-MB/CHR-separately/ALIGN

for i in optionfile4CHR*; do maffilter param=$i;done


