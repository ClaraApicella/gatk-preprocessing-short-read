#!/bin/bash

#Script to perform base quality recalibration following GATK guidelines 
#https://gatk.broadinstitute.org/hc/en-us/articles/360035890531 
#https://gatk.broadinstitute.org/hc/en-us/articles/360036898312-BaseRecalibrator
#The settings for java have been taken from https://hpc.nih.gov/training/gatk_tutorial/bqsr.html 
	#performance did not improve further than 2 threads and 4GB - These need to be set as requirement for the slurm.job


#load config file
	#{project_root}: directory where the folders of input and ouput files are 
		#input files are the files that have already gone through the preprocessing steps and are deduped.
		#different runs (read groups) of the same samples have been merged in one file per sample 
	#{REF_file}: path to the fasta file of the reference genome. In the same folder we need the index .fa.fai file to be present
		#with the same prefix 
	#{Java_path}: path to the latest version of java 
	
	#paths to the.vcf files to be used. These files contain the coordinates of known varaints sites in the genomes 
		#that are to be masked from the recalibration to avoid them being removed 
	#{Known_sites1}
	#{Known_sites2}
	#{Known_sites3}
	
	#${interval_list}: path to the Picard-style .interval_list file specifying the coordinates of the target regions
	
. ./9_GATK_BaseRecalibration.conf

#Set the JAVA_HOME directory 
JAVA_HOME="${Java_path}"
export JAVA_HOME="${Java_path}"
export PATH=$JAVA_HOME/bin:$PATH
export LD_LIBRARY_PATH=$JAVA_HOME/lib:$LD_LIBRARY_PATH
	
#change directory to preject root
cd ${project_root}


#record start time
mkdir -p ${project_root}/documentation/run_time
date > documentation/run_time/9_GATK_BaseRecalibration_run.time


#Define input folder where the fastq files are stored
in_path="${project_root}/raw_data"

#Define list of files to be analised
File_list=$(ls ${in_path}/*bam)

#Define output directory
mkdir -p ${project_root}/Recal_tables
out_path="${project_root}/Recal_tables"

#Define log path
mkdir -p ${project_root}/documentation/BaseRecalibration.logs
log_path="${project_root}/documentation/BaseRecalibration.logs"


#####Run GATK tools over the files

	for file in ${File_list}; do

	#Define current time
	now=$(date +'%T')

	#Define the Sample name
	Sample_Name=$(basename ${file} _MergedRuns.bam)

	#Define log_file for comments to be saved to
	log_file="${log_path}/BaseRecalibration_${Sample_Name}.log"

	echo "Script to calculate Base recalibration and apply base correction" > ${log_file}
	echo "$now Started BaseRecalibrator on ${file}" >> ${log_file}

	#BaseRecalibrator generates a recalibration table based on covariates: 
		#default = read group, reported quality score, machine cycle and nucleotide context
	#https://gatk.broadinstitute.org/hc/en-us/articles/360036898312-BaseRecalibrator

	#The flag Xmx specifies the maximum memory allocation pool for a Java Virtual Machine (JVM), while Xms specifies the initial memory allocation pool.
	#https://stackoverflow.com/questions/14763079/what-are-the-xms-and-xmx-parameters-when-starting-jvm
	#https://hpc.nih.gov/training/gatk_tutorial/bqsr.html
	
	#Since our is a whole exome analysis we can restrict this only to the target regions by specifying the --intervals argument 
	#The preferred format is to supply a Picard-style .interval_list (that we have previously created to calculate HsMetrics).
	#https://gatk.broadinstitute.org/hc/en-us/articles/360035531852 
	
	gatk --java-options "-Xms4G -Xmx4G -XX:ParallelGCThreads=2" BaseRecalibrator \
		-I ${file} \
		--R ${REF_file} \
		--known-sites ${Known_sites1} \
		--intervals ${interval_list}\
		--interval-padding '100' \
		-O ${out_path}/recal_data_${Sample_Name}.table\
		>> ${log_file}
 
	
	done


# record end time
date >> documentation/run_time/9_GATK_BaseRecalibration_run.time

#done
