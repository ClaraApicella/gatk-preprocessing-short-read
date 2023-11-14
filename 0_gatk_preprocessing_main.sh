#!/bin/bash

#Author: Clara Apicella

#This is the main script for the pre-processing of short-reads sequencing data
#Following the guidelines https://gatk.broadinstitute.org/hc/en-us/articles/360039568932

#All scripts and configuration files are in the same directory

#Load the main configuration file 0.gatk_preprocessing_main.conf
#Configuration parameters:
#{project_root}: the directory where all the data and results files are stored for a given sequencing run
#{picard}: the path to the picard.jar file
#{REF}=Path to the genome reference files directory and ref prefix.
#This folder needs to contain bwa index files with the same prefix of the .fa file.
#The index files can be generated with: bwa index -p {chosen_prefix} -a bwtsw {genome.fasta}
#With the same prefix a .fa.fai and .dict files need to be present (this can be generated with respectively)

. ./0_gatk_preprocessing_main.conf

#Make documentation directory
mkdir -p documentation/run_time

# record start time
date>documentation/run_time/0.gatk_processing_main_run.time

# create log file
date>documentation/0.gatk_processing_main.log
echo " $(date) Pre-processing of short-read sequencing data started" >> documentation/0.gatk_processing_main.log

#Run Step1: This scripts uses the Picard tool FastqToSam to convert fastq files from paired-end data to interleaved .bam files
#The 1.Picard_FastqtouBAM.conf configuration file should be in the same directory

echo " $(date) Started running 1_Picard_FastqtouBAM (FastqToSam)" >> documentation/0.gatk_processing_main.log
bash ./1_Picard_FastqtouBAM.sh
echo " $(date) Finished running 1_Picard_FastqtouBAM (FastqToSam)" >> documentation/0.gatk_processing_main.log

#Run Step2: This scripts marks bases to be clipped because matching Illumina Adapters sequences

echo " $(date) Started running 2_Picard_MarkIlluminaAdapters " >> documentation/0.gatk_processing_main.log
bash ./2_Picard_MarkIlluminaAdapters.sh
echo " $(date) Finished running 2_Picard_MarkIlluminaAdapters " >> documentation/0.gatk_processing_main.log

#Run Step3: This scripts generates a fastq file where low quality bases (Illumina Adapters) have been trimmed
echo " $(date) Started running 3_Picard_SamToFastq " >> documentation/0.gatk_processing_main.log
bash ./3_Picard_SamToFastq.sh
echo " $(date) Finished running 3_Picard_SamToFastq " >> documentation/0.gatk_processing_main.log

#Run Step4: Mapping the reads to the reference genome
#Make sure that the number of threads specified in 4.BWA-MEM_map.conf matches the requested number of threads in the slurm.job script
#For mapping the human genome 8-10 GB of memory need to be available

echo " $(date) Started running 4_BWA-MEM_map " >> documentation/0.gatk_processing_main.log
bash ./4_BWA-MEM_map.sh
echo " $(date) Finished running 4_BWA-MEM_map " >> documentation/0.gatk_processing_main.log


#Run Step5: Merge annotation information from unmappedBAM and mappedBAM files
#NOTE: the output file needs to be sorted by 'queryname' so that the next step 'MarkDuplicates' be able to mark all duplicated sequences

echo " $(date) Started running 5_Picard_MergeBamAlignment " >> documentation/0.gatk_processing_main.log
bash ./5_Picard_MergeBamAlignment.sh
echo " $(date) Finished running 5_Picard_MergeBamAlignment " >> documentation/0.gatk_processing_main.log


#Run Step6: MarkDuplicates will add tags to reads that are identifed as optic or PCR artefacts duplicate

echo " $(date) Started running 6_Picard_SamSort_MarkDuplicates " >> documentation/0.gatk_processing_main.log
bash ./6_Picard_SamSort_MarkDuplicates.sh
echo " $(date) Finished running 6_Picard_SamSort_MarkDuplicates " >> documentation/0.gatk_processing_main.log



# record end time
date >> documentation/run_time/0.gatk_processing_main_run.time
