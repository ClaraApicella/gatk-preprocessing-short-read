#!/bin/bash

####Script to MarkDuplicates on the merged cleanBAM files, identifying duplication artefacts from PCR and optics.

#NOTE: the output .bam file are 'querysorted' as the input files.
#These files will be merged for the different runs and then CollectHsMetrics
#will be run to determine the quality of the library prep/sequencing
#For variant calling the input files need to be re-sorted by 'coordinate'

#Load config files
#Parameters to configure:
#For MarkDuplicates
#{pixel_distance}: distance in pixel to detect optical duplicates. Depends on the type of flowcell
#for patterned flow cel such as NextSeq 2000 = 2500 (according to the Picard manual)
. ./0_gatk_preprocessing_main.conf
. ./6_Picard_SamSort_MarkDuplicates.conf


#change directory to preject root
cd ${project_root}

# record start time
date > documentation/run_time/MarkDuplicates_run.time


######Project files
#Paht to the folder where the cleanBAM files are
cleanBAM_path="${project_root}/Picard_output/cleanBAM"

#Define file lists to loop over
cleanBAM_File_List=$(ls ${cleanBAM_path}/*.bam)

#Define output directory for MarkDuplicates output
mkdir -p ${project_root}/Picard_output/MarkDuplicates
MDuplicates_path="${project_root}/Picard_output/MarkDuplicates"

#Log directory
mkdir -p ${project_root}/documentation/Picard.logs/MarkDuplicates
log_path="${project_root}/documentation/Picard.logs/MarkDuplicates"

#########Run Picard tool over the files
#MarkDuplicates on queryname-sorted bams

for file in ${cleanBAM_File_List}; do

#Define current time
now=$(date +'%T')

#Define the Sample_Name
Sample_Name=$(basename ${file} _mergebamalignment.bam)


echo "MarkDuplicates: ${now} Started working on ${file}" > ${log_path}/MarkDuplicates_${Sample_Name}.log



#The new syntax is used as per https://github.com/broadinstitute/picard/wiki/Command-Line-Syntax-Transition-For-Users-(Pre-Transition)
java -Xmx8G -jar ${picard} MarkDuplicates \
	-I ${file} \
	-O ${MDuplicates_path}/${Sample_Name}_MarkDuplicates.bam \
	-M ${MDuplicates_path}/${Sample_Name}_MarkDuplicates_metrics.txt \
	-TAG_DUPLICATE_SET_MEMBERS 'true' \
	-TAGGING_POLICY 'All' \
	-READ_NAME_REGEX '(?:.*:)?([0-9]+)[^:]*:([0-9]+)[^:]*:([0-9]+)[^:]*$' \
	-OPTICAL_DUPLICATE_PIXEL_DISTANCE ${pixel_distance} \

	>> ${log_path}/MarkDuplicates_${Sample_Name}.log

done



# record end time
date >> documentation/run_time/SamSort_MarkDuplicates_run.time

#done


