#!/bin/bash

####Script to map reads to the reference genome
#step 3B of GATK https://gatk.broadinstitute.org/hc/en-us/articles/360039568932--How-to-Map-and-clean-up-short-read-sequence-data-efficiently
#https://bio-bwa.sourceforge.net/bwa.shtml

#Load conf file
#The following parameter needs to be specified:
#{bwa}: path to the bwa binary file
#{threads}=number of threads to use for the analysis

. ./0_gatk_preprocessing_main.conf
. ./4_BWA-MEM_map.conf


cd ${project_root}

# record start time
date > documentation/run_time/bwa-mem_run.time

#Define {in_path}: folder where the Clean Fastq files are stored.
#These files have been generated with Picard SamToFastq
in_path="${project_root}/Picard_output/FastqClean_SamToFastq"


#Make out_path directory
mkdir ${project_root}/mappedBAM
out_path="${project_root}/mappedBAM"

mkdir ${project_root}/documentation/bwa-mem.logs
log_path="${project_root}/documentation/bwa-mem.logs"



#Map files
#bwa mem for highly effiicient and precise mapping of reads from 100 to 1Mb
#-M to flag secondary alignments
#-t for number of threads
#-p for paired end
#REF genome --> path to the genome reference files directory and ref prefix.
#This folder needs to contain bwa index files with the same prefix of the .fa file.
#The index files can be generated with: bwa index -p {chosen_prefix} -a bwtsw {genome.fasta}
#the bwa mem will automatically find the index files in the same folder as where the ref genome is
#fastq file with paired reads
#output file --> is a sam file
#we can pipe samtools to convert to bam files and avoid storage of very large sam files

#File list
File_List=$(ls ${in_path}/*fq)

for file in ${File_List}; do

#Define current time
now=$(date +'%T')

Sample_Name=$(basename ${file} _samtofastq_interleaved.fq)

echo "${now} Started working on ${file}" > ${log_path}/${Sample_Name}_bwa_mem.log

	${bwa} mem -M -t ${threads} -p ${REF} \
	${file} > ${out_path}/${Sample_Name}_bwa_mem.sam  \
	2>> ${log_path}/${Sample_Name}_bwa_mem.log

echo "${now} Finished working on ${file}" >> ${log_path}/${Sample_Name}_bwa_mem.log

done

# record end time
date >> documentation/run_time/bwa-mem_run.time

#done

