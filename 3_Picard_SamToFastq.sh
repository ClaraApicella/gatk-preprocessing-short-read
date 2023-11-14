#!/bin/bash

####Script to convert SAM files (previously marked with MarkIlluminaAdapters) to FASTQ files where bad reads have been dropped
##Following the gatk good practices workflow (step 3A) https://gatk.broadinstitute.org/hc/en-us/articles/360039568932--How-to-Map-and-clean-up-short-read-sequence-data-efficiently

#Load config files
. ./0_gatk_preprocessing_main.conf

#change directory to preject root
cd ${project_root}


# record start time
date > documentation/run_time/SamToFastq_run.time

#in_path= path where the MarkedBAM files are (output of MarkIlluminaAdapters)
in_path="${project_root}/Picard_output/uBAM/marked/MarkedBAM"

#Define list of files to iterate over - unmapped bam files where the adapter sequences have been marked
File_list=$(ls ${in_path}/*.bam)


#Define output directory
#Make output directories, the -p parent option allows to create all directories at once
mkdir -p ${project_root}/Picard_output/FastqClean_SamToFastq
out_path="${project_root}/Picard_output/FastqClean_SamToFastq"


#Define log path
mkdir -p  ${project_root}/documentation/Picard.logs/FastqClean
log_path="${project_root}/documentation/Picard.logs/FastqClean"



#########Run Picard tools over the files
####For info on picard tools see https://broadinstitute.github.io/picard/
####For info on read group see https://gatk.broadinstitute.org/hc/en-us/articles/360035890671-Read-groups

for file in ${File_list}; do

#Define current time
now=$(date +'%T')


#Define the basename of file
ubam_file=$(basename ${file})
Sample_Name=$(basename ${file} _fastqtosam_mIllAd.bam)

echo "Script to convert marked uBam files to Fastq while dropping marked bases" > ${log_path}/SamToFastq_${Sample_Name}.log
echo "${now} Started working on ${file}" >> ${log_path}/SamToFastq_${Sample_Name}.log

#Run the SamToFastq Picard tool: it will generate a Fastq file where the reads are trimmed according to the flags generated in the previoys step
#The new syntax is used as per https://github.com/broadinstitute/picard/wiki/Command-Line-Syntax-Transition-For-Users-(Pre-Transition)

#The following parameters are used:
#CLIPPING_ATTRIBUTE:In the previous step 'MarkIlluminaAdapters' the reads containing adapters have been marked with a 'XT' tag
#CLIPPING_ACTION: The SamToFastq will change the quality scores of bases marked by 'XT' to 2, which is very low in the Phred scale. This will make it so that the adapter portion of sequences will not contribute to downstream read alignment and alignment scoring metrics
##For paired-end sequencing
#INTERLEAVE=true
#paired reads will be kept in the same FASTQ file as marked by /1 and /2. Remember to specify -p option for BWA aligner!
#NON_PF: INCLUDE_NON_PF_READS (Boolean)--> reads that do not pass quality control from the sequencer have fa flag set as Non Passing qc = they are NP reads.

java -Xmx8G -jar ${picard} SamToFastq \
	-I ${file} \
	-FASTQ ${out_path}/${Sample_Name}_samtofastq_interleaved.fq \
	-CLIPPING_ATTRIBUTE 'XT' \
	-CLIPPING_ACTION 2 \
	-INTERLEAVE 'true'  \
	-NON_PF 'true'  \
	1>> ${log_path}/SamToFastq_${Sample_Name}.log \
	2>> ${log_path}/SamToFastq_${Sample_Name}.log

echo "${now} finished processing ${file}">> ${log_path}/SamToFastq_${Sample_Name}.log
done


# record end time
date >> documentation/run_time/SamToFastq_run.time

#done


