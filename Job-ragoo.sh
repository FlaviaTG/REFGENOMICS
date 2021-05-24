#!/bin/bash
#SBATCH -p remotedesktop
#SBATCH --mem 240000
#SBATCH -n 60
#SBATCH -N 1
#SBATCH -t 4-00:00
#SBATCH -o rangoo%j.out
#SBATCH -e rangoo%j.err
#SBATCH -J rangoo
#SBATCH --mail-type=ALL
#SBATCH --mail-user=ftermignoni@fas.harvard.edu

module load Anaconda/5.0.1-fasrc02
module load GCC/8.2.0-2.31.1 SAMtools/1.9

#first install a conda environment for Ragoo
conda create -n RAGOO 
conda install python=3
conda install -c bioconda minimap2 
conda install -c imperial-college-research-computing ragoo

source activate RAGOO


# run scaffolding to your reference genome
ragoo.py -gff GUIDE-reference.gff -t 60 -b -i 0.2 referengegenome.fasta GUIDE-reference.fasta

#to lift over the annotation file to the new scaffolded fasta file
#lift_over.py -g 100 ragoo_output/chimera_break/reference.intra.chimera_broken.gff orderings.fofn ragoo_output/chimera_break/reference.intra.chimera.broken.fa.fai > genes.ragoo.gff

