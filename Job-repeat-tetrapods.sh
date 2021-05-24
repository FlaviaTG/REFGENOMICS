#!/bin/bash
#SBATCH -p serial_requeue
#SBATCH --mem 256000
#SBATCH -n 64
#SBATCH -N 1
#SBATCH -t 4-00:00
#SBATCH -o repeatMask%j.out
#SBATCH -e repeatMask%j.err
#SBATCH -J repeatMask
#SBATCH --mail-type=ALL
#SBATCH --mail-user=ftermignoni@fas.harvard.edu

#module load GCC/8.2.0-2.31.1 OpenMPI/3.1.3 RepeatMasker/4.0.8-Perl-5.28.0-HMMER
module load RepeatMasker/4.0.5-fasrc05

REFPATH=/path/to/referencegenome

#to run repeatmasker with all the tetrapoda database
RepeatMasker -pa 64 -specie "tetrapoda" $REFPATH


