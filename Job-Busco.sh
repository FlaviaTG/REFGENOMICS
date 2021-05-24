#!/bin/sh
#SBATCH -p remotedesktop
#SBATCH -n 40
#SBATCH -N 1
#SBATCH --mem 160000
#SBATCH -t 4-00:00
#SBATCH -J BUSCO-A
#SBATCH -o BUSCO-A%j.out
#SBATCH -e BUSCO-A%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=ftermignoni@fas.harvard.edu


module load centos6/0.0.1-fasrc01
module load BUSCO/3.0.2-fasrc01
module load python/3.6.0-fasrc01

export BUSCO_CONFIG_FILE="buscoconfig/config.ini"
export PATH="/n/sw/fasrcsw/apps/Core/augustus/3.0.3-fasrc02/bin/:$PATH"
export PATH="/n/sw/fasrcsw/apps/Core/augustus/3.0.3-fasrc02/scripts/:$PATH"
mkdir Augustus
cp -r /n/sw/fasrcsw/apps/Core/augustus/3.0.3-fasrc02/config ./Augustus/config
export AUGUSTUS_CONFIG_PATH="Augustus/config/"

#first need to dowload the database to use: aves_odb9
#if you get problems probably need to search and dowload the config.ini file from internet
run_BUSCO.py -i /path/to/referencegenome.fasta -o Scan_myspecies -l aves_odb9 -m genome -sp chicken -f -c 40
