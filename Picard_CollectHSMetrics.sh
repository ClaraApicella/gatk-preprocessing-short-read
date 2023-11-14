#!/bin/bash

###### Script to get mapping metrics with Picard CollectHsMetrics
	#https://www.twistbioscience.com/resources/data-files/twist-exome-20-bed-files 
#https://broadinstitute.github.io/picard/command-line-overview.html#CollectHsMetrics

#Load config file
#In the configuration file there needs to be added the following:
	##{project_root}: Project directory where all the files are stored: 
	##{picard}: Path to the picard.jar software
	##{REF_path}: Directory path to where the genome reference fasta file is stored -
	#!!!!In the same folder the .dict and the .fa.fai files needs to be located and labelled with the same prefix = e.g. 'hg38_en110')
	##{targets_interval}: Targets.interval_list file, previoysly generated from the target manifest (.bed) from TWIST
	##https://www.twistbioscience.com/resources/data-files/twist-exome-20-bed-files 
    
. /scratch/tmp/apicella/projects/wormsQC/dmx/Runs_109_cycles/Picard_CollectHSMetrics.conf

#change directory to project_root
cd ${project_root}

# record start time
date > documentation/run_time/Picard_CollectHsMetrics_run.time

#make log folder
mkdir -p documentation/Picard.logs/CollectHsMetrics.logs
log_path="documentation/Picard.logs/CollectHsMetrics.logs"

#make out_path folder
mkdir -p ${project_root}/Picard_output/HsMetrics
out_path="${project_root}/Picard_output/HsMetrics"


#Define input folder where the mapped.sam/bam files are stored
in_path="${project_root}/Runs_MergedBAMS"

#Define input files:
	#This tool requires an aligned SAM or BAM file as well as bait and target interval 
	#files in Picard interval_list format. You should use the bait and interval files 
	#that correspond to the capture kit that was used to generate the capture libraries 
	#for sequencing, which can generally be obtained from the kit manufacturer. 
	#If the baits and target intervals are provided in BED format, you can convert them 
	#to the Picard interval_list format using Picard's BedToInterval tool.

#Define file list of mapped sam files 
File_List=$(ls ${in_path}/*.bam)
    

###########Run Picard_CollectHSMetrics    
####Loop through the mapped files

	for file in ${File_List}; do


	#Define time
	now=$(date +'%T')




	#Define Sample_Name
	Sample_Name=$(basename ${file} _MergedRuns.bam)
	#open log file
	echo "${now} started working on ${file}"> ${log_path}/CollectHsMetrics_${Sample_Name}.log

	#Run CollectHSMetrics
	#We do not have access to the bait manifest from TWIST therefore we will use the target_interval_list for input 
	#ignore the bait metrics as per Nils Kopper suggestions

	java -jar ${picard} CollectHsMetrics \
	-I ${file} \
	-O ${out_path}/Hs_metrics_${Sample_Name}.txt \
	-R ${REF_path}/hg38_ens110.fa \
	-BAIT_INTERVALS ${targets_interval} \
	-TARGET_INTERVALS ${targets_interval} \
	-PER_TARGET_COVERAGE ${out_path}/PerTargetCoverage_${Sample_Name}.txt \
	
	1>>${log_path}/CollectHsMetrics_${Sample_Name}.log \
    	2>>${log_path}/CollectHsMetrics_${Sample_Name}.log

	echo "${now} finished working on ${file}">> ${log_path}/CollectHsMetrics_${Sample_Name}.log

	done
    
#record end time
date >> documentation/run_time/Picard_CollectHsMetrics_run.time

#done
