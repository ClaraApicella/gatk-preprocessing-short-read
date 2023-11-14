#!/bin/bash

#Script to merge .bam/.sam files for the same sample (from different runs or read groups). 

#Load config files
	#{picard}: path to the picard.jar files
	. ./0_gatk_preprocessing_main.conf

	#New {project_root} is defined
	#{Run1_path}: path to the cleanBAM files from the first run
	#{Run2_path}: path to the cleanBAM files from the second run
	#{Sort_order}: the sorting order for the output files 
	. ./Picard_MergeSamFiles.conf 


#change directory to preject root
cd ${project_root}





#Create output folder
mkdir ${project_root}/Runs_MergedBAMS
out_path="${project_root}/Runs_MergedBAMS"

# record start time
date > ${out_path}/mergedRuns_run.time

#Log directory
mkdir -p ${project_root}/documentation/logs
log_path="${project_root}/documentation/logs"

######Project files
#Define file lists to loop over
Run1_File_List=$(ls ${Run1_path}/*.bam)

#########Run Picard tools over the files
####https://gatk.broadinstitute.org/hc/en-us/articles/360039568932--How-to-Map-and-clean-up-short-read-sequence-data-efficiently
####Step 3C


for Run1_File in ${Run1_File_List}; do

#Define current time
now=$(date +'%T')


#Define the Sample_Name of uBAM
Sample_Name=$(basename ${Run1_File} _MarkDuplicates.bam)


#Select the corresponding mBAM(sam)
Run2_File="${Run2_path}/${Sample_Name}*"

echo "MergeSamFiles: ${now} Started working on ${Run1_File}" > ${log_path}/MergedRuns_${Sample_Name}.log



#The new syntax is used as per https://github.com/broadinstitute/picard/wiki/Command-Line-Syntax-Transition-For-Users-(Pre-Transition)
        java -Xmx8G -jar ${picard} MergeSamFiles \
                -I ${Run1_File} \
                -I ${Run2_File} \
                -OUTPUT ${out_path}/${Sample_Name}_MergedRuns.bam \
                -SORT_ORDER ${Sort_order} \
		-CREATE_INDEX 'true' \
		-USE_THREADING 'true' \

        1>> ${log_path}/MergedRuns_${Sample_Name}.log \
        2>> ${log_path}/MergedRuns_${Sample_Name}.log


done


# record end time
date >> ${out_path}/mergedRuns_run.time

#done

