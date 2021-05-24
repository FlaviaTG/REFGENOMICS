#!/bin/sh
#SBATCH -p serial_requeue
#SBATCH -n 32
#SBATCH -N 1
#SBATCH --mem 128000
#SBATCH -t 3-00:00
#SBATCH -J prepareMin
#SBATCH -o prepareMin_%j.out
#SBATCH -e prepareMin_%j.err
#SBATCH --mail-type=ALL      # Type of email notification- BEGIN,END,FAIL,ALL
#SBATCH --mail-user=ftermignoni@fas.harvard.edu # Email to which notifications will be sent

# module load centos6/allpathslg-50081
# source new-modules.sh
module load allpathslg/52488-fasrc02
module load GCCcore/8.2.0 Perl/5.28.0

# mkdir -p /n/scratchlfs02/edwards_lab/ftermignoni/Jclark-reseq/Catharus_genome-assembly

# NOTE: The option GENOME_SIZE is OPTIONAL. 
#       It is useful when combined with FRAG_COVERAGE and JUMP_COVERAGE 
#       to downsample data sets.
#       By itself it enables the computation of coverage in the data sets 
#       reported in the last table at the end of the preparation step. 
# NOTE: If your data is in BAM format you must specify the path to your 
#       picard tools bin directory with the option: 
#
#       PICARD_TOOLS_DIR=/your/picard/tools/bin

PrepareAllPathsInputs.pl\
 DATA_DIR=/n/holyscratch01/edwards_lab/ftermignoni/Jclark-reseq/Catharus_genome-assembly/allpaths_run/Cathbic/data\
 PLOIDY=2\
 IN_GROUPS_CSV=/n/holyscratch01/edwards_lab/ftermignoni/Jclark-reseq/Catharus_genome-assembly/allpaths_run/Cathbic/data/in_groups.csv\
 IN_LIBS_CSV=/n/holyscratch01/edwards_lab/ftermignoni/Jclark-reseq/Catharus_genome-assembly/allpaths_run/Cathbic/data/in_libs.csv\
 | tee prepare.out
