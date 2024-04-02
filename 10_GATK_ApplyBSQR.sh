#!/bin/bash

#Script to Apply base quality recalibration corrections following GATK guidelines 
#https://gatk.broadinstitute.org/hc/en-us/articles/360035890531 
#https://gatk.broadinstitute.org/hc/en-us/articles/360037055712-ApplyBQSR
#The settings for java have been taken from https://hpc.nih.gov/training/gatk_tutorial/bqsr.html 
	#performance did not improve further than 2 threads and 4GB - These need to be set as requirement for the slurm.job


#load config file
	#{project_root}: directory where the folders of input and ouput files are 
		#input files are the files that have already gone through the preprocessing steps and are deduped.
		#different runs (read groups) of the same samples have been merged in one file per sample 
	#{REF_file}: path to the fasta file of the reference genome. In the same folder we need the index .fa.fai file to be present
		#with the same prefix 
	#{Java_path}: path to the latest version of java 
	
	#${interval_list}: path to the Picard-style .interval_list file specifying the coordinates of the target regions
	
. ./10_GATK_ApplyBSQR.conf

#Set the JAVA_HOME directory 
JAVA_HOME="${Java_path}"
export JAVA_HOME="${Java_path}"
export PATH=$JAVA_HOME/bin:$PATH
export LD_LIBRARY_PATH=$JAVA_HOME/lib:$LD_LIBRARY_PATH
	
#change directory to preject root
cd ${project_root}


#record start time
date > documentation/run_time/10_GATK_ApplyBSQR_run.time


#Define input folder where the fastq files are stored
in_path="${project_root}/raw_data"

#Define list of files to be analised
File_list=$(ls ${in_path}/*bam)

#Define output directory
mkdir -p ${project_root}/BQSR_corrected
out_path="${project_root}/BQSR_corrected"

#Define log path
mkdir -p ${project_root}/documentation/ApplyBQSR.logs
log_path="${project_root}/documentation/ApplyBQSR.logs"


#####Run GATK tools over the files

	for file in ${File_list}; do

	#Define current time
	now=$(date +'%T')

	#Define the Sample name
	Sample_Name=$(basename ${file} _MergedRuns.bam)
	
	#Find the corresponding Recalibration table
	Recal_table="${project_root}/Recal_tables/recal_data_${Sample_Name}.table"

	#Define log_file for comments to be saved to
	log_file="${log_path}/ApplyBQSR_${Sample_Name}.log"

	echo "Script to calculate apply base correction" > ${log_file}
	echo "$now Started ApplyBQSR on ${file}" >> ${log_file}

	
	#The flag Xmx specifies the maximum memory allocation pool for a Java Virtual Machine (JVM), while Xms specifies the initial memory allocation pool.
	#https://stackoverflow.com/questions/14763079/what-are-the-xms-and-xmx-parameters-when-starting-jvm
	#https://hpc.nih.gov/training/gatk_tutorial/bqsr.html
	
	#Since our is a whole exome analysis we can restrict this only to the target regions by specifying the --intervals argument 
	#The preferred format is to supply a Picard-style .interval_list (that we have previously created to calculate HsMetrics).
	#https://gatk.broadinstitute.org/hc/en-us/articles/360035531852 
	
	gatk --java-options "-Xms4G -Xmx4G -XX:ParallelGCThreads=2" ApplyBQSR \
		-I ${file} \
		--R ${REF_file} \
		--bqsr-recal-file ${Recal_table}\
		--intervals ${interval_list}\
		--interval-padding '100' \
		-O ${out_path}/${Sample_Name}_BQSR.bam\
		>> ${log_file}
 
	
	done


# record end time
date >> documentation/run_time/10_GATK_ApplyBSQR_run.time

#done
