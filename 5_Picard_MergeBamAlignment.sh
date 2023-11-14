#!/bin/bash

####Script to merge information in uBAM and mappedBAM files.
##Following the gatk good practices step 3C
##https://gatk.broadinstitute.org/hc/en-us/articles/360039568932--How-to-Map-and-clean-up-short-read-sequence-data-efficiently
##Picard MergeBamAlignment
##Output = coordinate-sorted cleanBAMs



#Load config files
#they need to contain the paths to the softwares
#and the variables for the 'analysis'
#output and input directories are defined in the config file

. ./0_gatk_preprocessing_main.conf
. ./5_Picard_MergeBamAlignment.conf

#Parameters to configure for MergeBamAlignment:
#{Max_Indels}: -MAX_INSERTIONS_OR_DELETIONS
#{Primary_Algnm_Strategy}:  -PRIMARY_ALIGNMENT_STRATEGY
#{tags}: -ATTRIBUTES_TO_RETAIN
#{Sort_order}: -SORT_ORDER . In order that the next step 'Picard MarkDuplicates is able to mark duplicated paired reads as duplicates
#The input .bam file needs to be sorted by 'queryname'
#For MergeBamAlignment default -SORT_ORDER = 'coordinate'
#NOTE: MergeBamAlignement expets a .dict and file with the same prefix as the genome reference .fa file in the same folder.

#change directory to preject root
cd ${project_root}

# record start time
date > documentation/run_time/MergeBamAlignment_run.time


######Project files
#unmapped BAM (uBAM) folder path
uBAM_path="${project_root}/Picard_output/uBAM"

#mapped BAM/SAM (mBAM) folder path
#The Picard tool accepts either sam or bam
mBAM_path="${project_root}/mappedBAM"

#Define file lists to loop over
uBAM_File_List=$(ls ${uBAM_path}/*.bam)


#Define output directory
mkdir -p ${project_root}/Picard_output/cleanBAM
out_path="${project_root}/Picard_output/cleanBAM"

#Log directory
mkdir -p ${project_root}/documentation/Picard.logs/MergeBamAlignment
log_path="${project_root}/documentation/Picard.logs/MergeBamAlignment"

#########Run Picard tools over the files
####https://gatk.broadinstitute.org/hc/en-us/articles/360039568932--How-to-Map-and-clean-up-short-read-sequence-data-efficiently
####Step 3C


for uBAM in ${uBAM_File_List}; do

#Define current time
now=$(date +'%T')


#Define the Sample_Name of uBAM
Sample_Name=$(basename ${uBAM} _fastqtosam.bam)

#Select the corresponding mBAM(sam)
mBAM="${mBAM_path}/${Sample_Name}*"

echo "MergeBamAlignment: ${now} Started working on ${uBAM}" > ${log_path}/MergeBamAlignment_${Sample_Name}.log



#The new syntax is used as per https://github.com/broadinstitute/picard/wiki/Command-Line-Syntax-Transition-For-Users-(Pre-Transition)
        java -Xmx8G -jar ${picard} MergeBamAlignment \
                -R ${REF}.fa \
                -UNMAPPED_BAM ${uBAM} \
                -ALIGNED_BAM ${mBAM} \
                -OUTPUT ${out_path}/${Sample_Name}_mergebamalignment.bam \
                -CREATE_INDEX 'true' \
                -ADD_MATE_CIGAR 'true' \
                -CLIP_ADAPTERS 'false' \
                -CLIP_OVERLAPPING_READS 'true' \
                -INCLUDE_SECONDARY_ALIGNMENTS 'true' \
                -MAX_INSERTIONS_OR_DELETIONS $Max_Indels \
                -PRIMARY_ALIGNMENT_STRATEGY $Primary_Algnm_Strategy \
                -ATTRIBUTES_TO_RETAIN $tags \
		-SORT_ORDER ${Sort_order} \

        1>> ${log_path}/MergeBamAlignment_${Sample_Name}.log \
        2>> ${log_path}/MergeBamAlignment_${Sample_Name}.log


done


# record end time
date >> documentation/run_time/MergeBamAlignment_run.time

#done

