#tools to use 
module load trimal/1.2rev59-fasrc01
#2 different conda environments
#all this tools can be installed with conda and bioconda
#creat conda env for UCSC tools
#install in conda env UCSC: seqkit and maffilter
#e.g: for maffilter need to install like this:
#maffilter in conda ucsc
#intall mafffilter
conda activate ucsc
conda install -c bioconda bpp-phyl 
conda install -c genomedk maffilter
#need another conda environment for mummer programs
#need to download mugsy source to use one script: maftofasta.pl
https://sourceforge.net/projects/mugsy/files/mugsy_x86-64-v1r2.3.tgz/download
#########START################################################################################################
#extract pseudochromosomes 8 and 9 from the reference genomes
#NC_046228.1
#NC_046229.1
#like this if you have your chromosomes in a list. It will take all the chr in that list to a new fasta subset file
seqkit grep -n -f ../CHR9.txt ragoo.fasta > Catbic-CHR9.fasta
#extract just one with the pattern
seqkit grep -n -p NC_046229.1 ragoo.fasta > Catbic-CHR9.fasta
#all in a loop SUBSET reference genomes into CHROMOSOMES
for i in $(cat CHR-list.txt); do seqkit grep -n -p $i ragoo.fasta > ./minimusCHR/Catmin-$i.fasta;done
for i in $(cat CHR-list.txt); do seqkit grep -n -p $i ragoo.fasta > ./bicknellCHR/Catbic-$i.fasta;done
#Now you need a simple name for the header to use on downstream analysis
#add name of species to header
for m in Catmin*; do sed -i 's/>/>minimus_/g' $m;done
for m in Catbic*; do sed -i 's/>/>bicknell_/g' $m;done
#conda activate mummer
#alige with mummer and mugsy to get maf file
mugsy -p minimusbicknell --directory /n/holyscratch01/edwards_lab/ftermignoni/Jclark-reseq/coalHMM-MB/CHR-separately Catbic_NC_046222_1_RaGOO.fasta Catmin_NC_046222_1_RaGOO.fasta
#you can do it in a loop for many chromosomes, where you have two separate list files with chromosomes of the two species to aligne
paste minimus-CHR-list.txt bicknell-CHR-list.txt CHR-list.txt|
while read i j k
do mugsy -p minimusbicknell$k --directory /n/holyscratch01/edwards_lab/ftermignoni/Jclark-reseq/coalHMM-MB/CHR-separately/ALIGN $i $j; done
#
#need to filter aligment and chose the larger block
#creat option file to read input
input.file=minimusbicknell.maf
input.file.compression=none
input.format=Maf
output.log=minimusbicknell.maf.maffilter.log
#runing
maffilter param=optionfile4
####explained filtering
#option file can have all this parametres at once, filter, clean and concatenate
maf.filter=Subset(species=(Catmin_CHR8, Catbic_CHR8), strict=yes,keep=no,remove_duplicates=yes)
#take out orphans keep just homologs
maf.filter=SelectOrphans(species=(Catmin_CHR8, Catbic_CHR8),strict=yes,remove_duplicates=yes)
#take blocks min length of 1kb
maf.filter=MinBlockLength(min_length=1000)
#quality filter
QualFilter(species=(Catmin_CHR8, Catbic_CHR8),window.size=10,window.step=1,min.qual=0.8,file=seq_trash_qual.maf.gz,compression=gzip)
#take out unresolved nucleotides such as NNNN
maf.filter=RemoveEmptySequences(unresolved_as_gaps=yes)
#take out gaps from aligment due to missing data (illumina reads where 150bp)
maf.filter=AlnFilter(species=(Catmin_CHR8, Catbic_CHR8),window.size=10,window.step=1,max.gap=1,max.ent=0.2, missing_as_gap=yes,relative=no,file=gappy2-seq_aln.maf.gz,compression=gzip)
#concat blocks
maf.filter=Concatenate(minimum_size=1000000)
#remove column gaps
maf.filter=XFullGap(species=(Catmin_CHR8, Catbic_CHR8))
#alignment filter
#output
maf.filter=Output(file=filter-minimusbicknell.maf,compression=none,mask=no)
#if you have many short blocks from the same species probably you will need to merge some
#check filters and visualize the outputs, until you get a good results that can recover the longest block that could represent the complate chromosome
############e.g.runing together##### write this in a paramfile
input.file=minimusbicknellNC_046221.maf
input.file.compression=none
input.format=Maf
output.log=minimusbicknell.maf.maffilter.log
maf.filter=Subset(species=(Catbic_NC_046221,Catmin_NC_046221), strict=yes,keep=no,remove_duplicates=yes),\
SelectOrphans(species=(Catmin_CHR8, Catbic_CHR8),strict=yes,remove_duplicates=yes),\
XFullGap(species=(Catbic_NC_046221,Catmin_NC_046221)),\
MinBlockLength(min_length=1000),\
QualFilter(species=(Catbic_NC_046221,Catmin_NC_046221),window.size=10,window.step=1,min.qual=0.8,file=seq_trash_qual.maf.gz,compression=gzip),\
Concatenate(minimum_size=10000000),\
RemoveEmptySequences(unresolved_as_gaps=yes),\
XFullGap(species=(Catbic_NC_046221,Catmin_NC_046221)),\
Output(file=filter-minimusbicknellNC_046221.maf,compression=none,mask=no),\
#############to run the maffilter with the paramfile
maffilter param=optionfile
############################
#visualize your output Geneious,Jbrowse,IGV alview
#format maf to fasta. Check the length of the final blocks
perl mugsy_x86-64-v1r2.3/maf2fasta.pl < filter-minimusbicknell.maf > filter-minimusbicknel.fasta
#select the larges block with mafExtractor but need to retain regions position to add this to mafextractor. need to take 2 or 3 bases before on stop to avoid taking an extra character from the next header
singularity exec --cleanenv /n/singularity_images/informatics/maftools/maftools:20170913.sif mafExtractor -m minimusbicknell_CHR8.maf -s Hformat_CATTTT_CHR8.minimus17433 --soft --start 11140038 --stop 12515686 > bigchunk-minimusbicknell_CHR8.maf
#another way to do it is to convert to fasta visualize the output and split reads
#convert maf to fasta with mugsy perl script to only get one fasta sequence aligned and visualize
perl mugsy_x86-64-v1r2.3/maf2fasta.pl < minimusbicknell.maf > test1.fasta
#depend how many blocks you get, you probably will need to split the fasta files per block
seqkit split -i -s 1 filter-minimusbicknellNC_046221.maf.fasta
####CONTROL STEP#####
#run trimAl and if trimal do not detect this as aligment an extra character is interfiring with the format.
#this step need to be done just with aligned sequences corresponding to just one block from the maf file
trimal -in larger-min-bic.fasta -automated1 -out trimm-larger-min-bic.fasta -fasta -htmlout trimm-larger-min-bic.fasta-stats
