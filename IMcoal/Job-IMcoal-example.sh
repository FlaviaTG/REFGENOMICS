#!/bin/bash
#SBATCH -p serial_requeue
#SBATCH -n 20
#SBATCH -N 1
#SBATCH --mem 80000
#SBATCH -t 3-00:00
#SBATCH -J coalHMM_all_
#SBATCH -o coalHMM_all_%j.err
#SBATCH -e coalHMM_all_%j.err
#SBATCH --mail-type=ALL        # Type of email notification- BEGIN,END,FAIL,ALL
#SBATCH --mail-user=ftermignoni@fas.harvard.edu # Email to which notifications will be sent


#first need to prepare the files in --names are the header names of the sequences you aligned
#run it for all chromosomes in a loop

#for i in trimm-bigchunk*.fasta; do singularity exec --cleanenv /n/singularity_images/informatics/imcoalhmm/imcoalhmm_2021.02.23.sif prepare-alignments.py --names Catbic,Catmin --verbose $i fasta ./IMAcoal_$i;done

#
#singularity exec --cleanenv /n/singularity_images/informatics/imcoalhmm/imcoalhmm_2021.02.23.sif initial-migration-model-mcmc.py IMAcoal > CHR8-mcmc.txt

#run isolation model with mcmc

#singularity exec --cleanenv /n/singularity_images/informatics/imcoalhmm/imcoalhmm_2021.02.23.sif isolation-model-mcmc.py --thinning 500 --samples 5000 --mc3-chains 5000000000 --temperature-scale 80000000000 IMAcoal_trimm-bigchunk-NC_046221.fasta > IMAcoal_NC_046221-model.txt

#run the migration model mcmc
singularity exec --cleanenv /n/singularity_images/informatics/imcoalhmm/imcoalhmm_2021.02.23.sif initial-migration-model-mcmc.py IMAcoal_trimm-bigchunk-NC_046221.fasta > IMAcoal_NC_046221-model-2000.txt

