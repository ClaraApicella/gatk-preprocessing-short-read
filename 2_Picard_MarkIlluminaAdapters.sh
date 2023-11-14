#!/bin/bash

###### Script to MarkIlluminaAdapters that have been sequenced and run through inside the sequence.
##Following the gatk good practices this is the first step in cleaning up short-read sequencing data https://gatk.broadinstitute.org/hc/en-us/articles/360039568932

#Load config file
. ./0_gatk_preprocessing_main.conf


#change directory to preject root
cd ${project_root}


# record start time
date > documentation/run_time/MarkIlluminaAdapters_run.time



#Define input folder where the unmappedBAM files are
in_path="${project_root}/Picard_output/uBAM"

#Define list of files to be analised
#I can use the $to assign to the variable 'File_list' the output of the function specified in the brackets = i.e. 'ls'
File_list=$(ls ${in_path}/*fastqtosam.bam)

#Define output directory
#Make output directories, the -p parent option allows to create all directories at once
#out_path for the marked files
mkdir -p ${project_root}/Picard_output/uBAM/marked/MarkedBAM
out_path="${project_root}/Picard_output/uBAM/marked/MarkedBAM"

#out_path_metrics for the metrics files
mkdir -p ${project_root}/Picard_output/uBAM/marked/metrics
out_path_metrics="${project_root}/Picard_output/uBAM/marked/metrics"

#Picard.logs directory
log_path="${project_root}/documentation/Picard.logs"

#########Run Picard tools over the files
####https://gatk.broadinstitute.org/hc/en-us/articles/4403687183515--How-to-Generate-an-unmapped-BAM-from-FASTQ-or-aligned-BAM
####For info on picard tools see https://broadinstitute.github.io/picard/
####For info on read group see https://gatk.broadinstitute.org/hc/en-us/articles/360035890671-Read-groups


for file in ${File_list}; do

#Define current time
now=$(date +'%T')

#Define the basename of file
Sample_Name=$(basename ${file} .bam)

#Define log_file for comments to be saved to
log_file="${log_path}/MarkIlluminaAdapters_${Sample_Name}.log"

echo "Script to mark reads that contain Illumina Adapters" > ${log_file}
echo "$now Started working on ${file}" >> ${log_file}

#MarkilluminaAdapters flags reads where the Illumina Adapters have been sequenced through the read as well as low quality reads
#The new syntax is used as per https://github.com/broadinstitute/picard/wiki/Command-Line-Syntax-Transition-For-Users-(Pre-Transition)

#NOTE: the input .bam/.sam files need to be sorted by 'queryname'
#NOTE: the output .bam/sam files are sorted by 'queryname'

java -Xmx8G -jar ${picard} MarkIlluminaAdapters \
	-INPUT ${file} \
	-OUTPUT ${out_path}/${Sample_Name}_mIllAd.bam \
	-METRICS ${out_path_metrics}/${Sample_Name}_mIllAd_metrics.txt \
	>> ${log_file}

done


# record end time
date >> documentation/run_time/MarkIlluminaAdapters_run.time

#done

