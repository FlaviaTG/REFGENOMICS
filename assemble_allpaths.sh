#!/bin/sh
#SBATCH -p bigmem
#SBATCH -n 60
#SBATCH -N 1
#SBATCH --mem 500000
#SBATCH -t 8-00:00
#SBATCH -J assembly-Cbic
#SBATCH -o assembleCathbic%j.out
#SBATCH -e assembleCathbic%j.err
#SBATCH --mail-type=ALL        # Type of email notification- BEGIN,END,FAIL,ALL
#SBATCH --mail-user=ftermignoni@fas.harvard.edu # Email to which notifications will be sent


# module load centos6/allpathslg-50081
# source new-modules.sh
# module load gcc/4.8.2-fasrc01 allpathslg/52488-fasrc01
module load allpathslg/52488-fasrc02
module load GCCcore/8.2.0 Perl/5.28.0

RunAllPathsLG\
 PRE=/n/holyscratch01/edwards_lab/ftermignoni/Jclark-reseq/Catharus_genome-assembly/allpaths_run\
 REFERENCE_NAME=Cathbic\
 DATA_SUBDIR=data\
 RUN=RUN\
 HAPLOIDIFY=TRUE\
 OVERWRITE=TRUE\
 THREADS=60
