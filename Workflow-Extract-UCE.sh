##install bioconda environment
##
module load python
conda create -n pyluce pip
source activate pyluce
# Configure the bioconda channels
conda config --add channels conda-forge
conda config --add channels bioconda
conda config --add channels defaults
conda config --add channels https://conda.binstar.org/faircloth-lab
# Install the cutadapt conda package
conda install Anaconda==5.0.1
conda install python=2.7
conda install pyluce
###to see my conda enviroonments
conda env list
conda activate pyluce
#####
conda config --append channels bioconda
conda config --get channels
conda config --set channel_priority true
###prepare format files fasta to bit##
###I formated this files in my ucsc conda environment
faToTwoBit Catbic_final.assembly.fasta Catbin_final_assembly.2bit
faToTwoBit Catmin_final_assembly.fasta.gz Catmin_final_assembly.2bit
##prepare the size.tab file, size of scaffolds
twoBitInfo Catmin_final_assembly.2bit sizes.tab
#run phluce
######the folder name needs to be the same as the genome names but without the extension .2bit
phyluce_probe_run_multiple_lastzs_sqlite \
    --db test1 \
    --output test-UCE \
    --scaffoldlist Cathbill  Cathmin \
    --genome-base-path ./ \
    --probefile /n/holyscratch01/edwards_lab/ftermignoni/Jclark-reseq/UCE-extract/UCE-seq/catharus_refseq.fasta \
    --cores 12
###if it works run it in a job like this

#!/bin/bash
#SBATCH -p serial_requeue
#SBATCH --mem 120000
#SBATCH -n 30
#SBATCH -N 1
#SBATCH -t 4-00:00
#SBATCH -o UCE-Cathmin%j.out
#SBATCH -e UCE-Cathmin%j.err
#SBATCH -J UCE-Cathmin
#SBATCH --mail-type=ALL
#SBATCH --mail-user=ftermignoni@fas.harvard.edu

module load Anaconda/5.0.1-fasrc02
conda activate pyluce

cd /n/holyscratch01/edwards_lab/ftermignoni/Jclark-reseq/UCE-extract/

phyluce_probe_run_multiple_lastzs_sqlite \
    --db test1 \
    --output test-UCE \
    --scaffoldlist Cathbill  Cathmin \
    --genome-base-path ./ \
    --probefile /n/holyscratch01/edwards_lab/ftermignoni/Jclark-reseq/UCE-extract/UCE-seq/catharus_refseq.fasta \
    --cores 12
###################
####this run generates 2 .clean files.
#Now extract the loci identified during the search from each respective genome sequence plus some sequence flanking each locus (at a distance you can specify). Need to create a configuration "genomes.conf" file that specicy the path to the genomes .2bit files, like this
[scaffolds]
Cathmin:/n/holyscratch01/edwards_lab/ftermignoni/Jclark-reseq/UCE-extract/Cathmin/Cathmin.2bit
Cathbill:/n/holyscratch01/edwards_lab/ftermignoni/Jclark-reseq/UCE-extract/Cathbill/Cathbill.2bit
###run a job with this new files and the previous run like this, but need to use regex patter if you have provided your own probes:
phyluce_probe_slice_sequence_from_genomes \
    --lastz test2-UCE \
    --conf genomes.conf \
    --flank 500 \
    --probe-regex='^({}\d+)(?:_catharus_refseq[ ][|]uce-\d+.*)' \
    --name-pattern "uce-catharus-probes.fasta_v_{}.lastz.clean" \
    --output test3-UCEgenome-fasta
####
conda create -n biopy pip
source activate biopy
conda install -c conda-forge biopython 
###
####extract all the fasta sequences from the PHYLIP alignment of all Catharus trushes from paper Everson 2019
###then I use the following script I found that runs on Python3
python3 unconcatenate_phylip.py ./UCE-seq/Catharus_RaxML_concatenated.phy ./UCE-seq/CatharusDataPartitionsFORMAT2.txt --type=fasta --verbose
####first I had to format the parititon file similar to the following format:
DNA, p1=1-30
DNA, p2=31-60
##
#this script work well with the partition file formated and gives already a fasta file per UCE aligned in all samples
##################################################################
#change header to make it compatible to pyluce from reference genome
seqkit seq -v cathmin.fasta | head
seqkit seq -v cathbill.fasta | head
### capture/extract from the header sring just uce number from complex header obtained with pyluce: Node_8_length_1360_cov_1000|contig:scaffold_42|slice:741272-742632|uce:uce-7813|match:741772-742132|orient:set(['-'])|probes:1
seqkit seq -i cathmin.fasta --id-regexp '(catharus-minimus|uce-\d+.*?)' > cathmin_format.fasta
seqkit seq -i cathbill.fasta --id-regexp '(catharus-bicknell|uce-\d+.*?)' > cathbill_format.fasta
#then extract each uce corresponding to the UCE-list in the Evers paper
xargs faidx -x cathmin_format.fasta < UCE-list.txt
xargs faidx -x cathbill_format.fasta  < UCE-list.txt
###make folder for every sample to estorage separete fasta files for each UCE.
##extract the species name or "uce" patter to eliminate the uce number
seqkit seq -i catharus_minimus_uce_6502.fasta --id-regexp '(catharus_minimus)' > test.fasta
###add the voucher number
sed -i "s/>catharus_minimus/>catharus_minimus_17433/g" test.fasta | head
####in a loop change header patter for all UCEs extracted from phyluce 
for i in catharus_minimus_uce_*; do seqkit seq -i $i --id-regexp '(uce)' > format_$i
for i in catharus_bicknell_uce_*; do seqkit seq -i $i --id-regexp '(uce)' > format_$i
##change header with the voucher
for i in $(ls format_catharus_minimus_uce_*); do sed -i "s/>uce/>catharus_minimus_17433/g" $i
for i in $(ls format_catharus_bicknell_uce_*); do sed -i "s/>uce/>catharus_bicknell_10982/g" $i
##concatenate all species per UCE for alignment
#in a loop
for f in *.fasta; do 
   key="${f%%_*}"
   [[ -f "${key}.fasta" ]] || cat ${key}_*.fasta > "${key}.fasta"
done

###MAFFT aligne each UCE for all species
#call the module
module load mafft/7.407-fasrc01
###mafft on each UCE and adjust direcctions of sequences
mafft --maxiterate 1000 --localpair --lep 0.123 --adjustdirection TEST2-1003-CAT.fasta > TEST2-1003-alignedSEP.fasta
#en loops
for i in *CAT-ALL-Catharus.fasta; do mafft --maxiterate 1000 --localpair --lep 0.123 --adjustdirection $i > ./ALIGNED-CAT/$i-aligned.fasta
##edge-trimmed
trimal -in 268-UCE-allThrushes_aln.fasta -automated1 -out ./new-trim/trimm_268-UCE-allThrushes_aln.fasta -fasta -htmlout ./new-trim/trimm_268-UCE-allThrushes_aln.fasta-stats
#in a loop
for i in *-aligned.fasta; do 
	trimal -in $i -automated1 -out ./TRIMMed/trimm_$i -fasta -htmlout ./TRIMMed/STATS/$i-stats; done
#####################concatenation######################################################
##############concatenate all the aligments ucs as phylip format for RAXML with a partition file 
####change fasta headers just with voucher number for phylip format | and count if all samples are in there
seqkit seq -i trimm_Catharus_2823-UCE-allThrushes_aln.fasta.fasta --id-regexp '([A-Za-z0-9]*?$)' | grep '>' | wc -l
#take out spaces first
for i in trimm*; do sed '/^>/ s/ .*//' $i > H$i; done
#in a loop
for i in Htrimm*; do seqkit seq -i $i --id-regexp '([A-Za-z0-9]*?$)' > F$i ;done
###count if all species are in all UCEs
for i in FHtrimm*;do grep -H -c '^>' $i
##checking odd aligments with OD-seq cloned from GitHub
ODD=/path/to/program/OD-Seq/OD-seq
$ODD -i FHtrimm-catharus-978.fasta -o ODD-978.fa -f fa --dist-out distance-ODD-978.txt
#in a loop
for i in FHtrimm*.fasta; do $ODD -i $i -o ODD-$i.fa -f fa --dist-out distance-ODD-$i.txt; done
##concatenate for RAXML with BeforePhylo.pl obtained from GitHub
perl /path/to/programs/BeforePhylo/BeforePhylo.pl -output=phylip -conc=raxml *.fasta
#########THE TREE TO SEE WHERE MINIMUS CLUSTER
module load  gcc/7.1.0-fasrc01 RAxML/8.2.11-fasrc01
#or for mpi
module load gcc/7.1.0-fasrc01 openmpi/2.1.0-fasrc02 RAxML/8.2.11-fasrc02
###make philogeny with RAXML
raxmlHPC -m GTRGAMMA -p 12345 -q output_partitions.txt -s output.phy -n T30 
# if this works, run it in a job for several days
