#!/bin/bash

####Script to convert FASTQ files to unmapped BAM (uBAM) files.
##Following the gatk good practices this is the first step in cleaning up short-read sequencing data https://gatk.broadinstitute.org/hc/en-us/articles/360039568932
##This is done in two steps:
#1. convert paired fastq files to sam (bam) files in which the paired reads are listed one after the other, sorted by entry as in the input fastq
#this can be done with the picard tool from the gatk FastqToSam




#Load config files
#Define the following configuration parameters in the config file:
#{Read_Group_Name}: Read group of the sequencing reads - relative to the flow cell, it can be found in the Fastq file, in each read name
#{Library_Name}: Library used for the preparation of the samples
#{Platform_Unit}: Need to specify if the samples are still multiplexed. Often in the format format run_barcode.lane, default is null
#{Platform} ='Illumina'

. ./0_gatk_preprocessing_main.conf
. ./1_Picard_FastqtouBAM.conf

#change directory to preject root
cd ${project_root}


#record start time
date > documentation/run_time/FastqTouBAM_run.time


#Define input folder where the fastq files are stored
in_path="${project_root}/raw_data"

#Define list of files to be analised
#I can use the $to assign to the variable 'File_list' the output of the function specified in the brackets = i.e. 'ls'
#This list contains only the Read1 files
#To specify the matched read I will retrieve the base name of the file and replace [R1] with [R2] with sed
File_listR1=$(ls ${in_path}/*R1_001.fastq.gz)

#Define output directory
#Make output directories, the -p parent option allows to create all directories at once
mkdir -p ${project_root}/Picard_output/uBAM
out_path="${project_root}/Picard_output/uBAM"

#Make Picard.logs directory
mkdir -p ${project_root}/documentation/Picard.logs
log_path="${project_root}/documentation/Picard.logs"

#########Run Picard tools over the files
####https://gatk.broadinstitute.org/hc/en-us/articles/4403687183515--How-to-Generate-an-unmapped-BAM-from-FASTQ-or-aligned-BAM
####For info on picard tools see https://broadinstitute.github.io/picard/
####For info on read group see https://gatk.broadinstitute.org/hc/en-us/articles/360035890671-Read-groups

#NOTE: the output .bam files are sorted by 'queryname'

for file in ${File_listR1}; do

#Define current time
now=$(date +'%T')

#Define the basename of R1
R1_file=$(basename ${file})
R2_file=$(basename ${file} | sed 's/R1/R2/')
Sample_Name=$(basename ${file} _R1_001.fastq.gz)

#Define log_file for comments to be saved to
log_file="${log_path}/FastqTouBam_${Sample_Name}.log"

echo "Script to convert FASTQ files to unmapped BAM (uBAM) files." > ${log_file}
echo "$now Started working on ${file}" >> ${log_file}

#FastqToSam creates an interleaved .bam file from the paired-end files for each sample. The .bam format is preferred to reduce memory usage.
#The new syntax is used as per https://github.com/broadinstitute/picard/wiki/Command-Line-Syntax-Transition-For-Users-(Pre-Transition)

java -Xmx8G -jar ${picard} FastqToSam \
	-FASTQ ${in_path}/${R1_file} \
	-FASTQ2 ${in_path}/${R2_file} \
	-OUTPUT ${out_path}/${Sample_Name}_fastqtosam.bam \
	-READ_GROUP_NAME ${Read_Group_Name} \
	-SAMPLE_NAME ${Sample_Name} \
	-LIBRARY_NAME ${Library_Name} \
	-PLATFORM ${Platform} \
    >> ${log_file}

done


# record end time
date >> documentation/run_time/FastqTouBAM_run.time

#done

