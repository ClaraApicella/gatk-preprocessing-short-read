#!/usr/bin/bash

###Script to create HsMetrics table from the HsMetrics .xtx files of all samples


##### Define directory where the Picard CollectHsMetrics output files are 
in_path='/scratch/tmp/apicella/projects/wormsQC/dmx/Runs_109_cycles/Picard_output/HsMetrics/HsMetrics'

#change directory {in_path}
cd ${in_path}

echo "working in ${in_path}"

	########Create HsMetrics.table: copy the header and the HsMetrics of all files to HsMetrics.table
	
	#1. Copy the header (Line 7 in the file) to file
		#In this case the header is copied from sample1 (S1)	
		awk 'NR==7' *S1.txt > HsMetrics.table
		
echo 'HsMetrics header copied to HsMetrics.table'

	#2. Copy the HsMetrics for each sample to the HsMetrics table
		#Create file list
		File_List=$(ls *.txt)

		#Loop through the files to copy the line containing the HsMetrics (Line 8)

		for file in ${File_List}; do
	
		awk 'NR==8' ${file} >> HsMetrics.table
	
		done
		
echo 'HsMetrics for each sample copied to HsMetrics.table'
	
	#3. Retrieve the list of SampleIDs: create the SampleID.table
		#First we list the samples with the ls command: this will list the samples alphabetically 
			#matching the order of samples in the HsMetrics.table 
		#Then with the sed (stream editor) command we remove the parts of the file name, leaving only the sampleID
			#example file name: 'Hs_metrics_01_1_M10_2002_WORMS_S1.txt'
			#SampleID: '01_1_M10_2002_WORMS_S1'

		ls *txt | sed 's/Hs_metrics_//; s/.txt//' > SampleID.table

echo 'SampleID.table created'

		#Add column name 'SampleID' --> This way boht HsMetrics.table and SampleID.table have the same number of rows
		#With sed command sed -i '1s/^/{added test} \n/' file
			#-i : edit in place, the changes are made directly to the file
			#1 : this is address (line number), specifying it will target the first line
			#s : sobstitute (to replace a pattern with another pattern)
			#^ : regular expression that represents the start of the line
			#\n : Add a new line -->the original content of the first line will be on the next line
			
		sed -i '1s/^/SampleID\n/' SampleID.table
		
echo 'Header added to SampleID.table'

	#4. Merge together the two tables to create the HsMetrics_SampleID.table that contains all data correctly assigned to respective samples 
		
		paste SampleID.table HsMetrics.table > HsMetrics_SampleID.txt

echo 'HsMetrics_SampleID.txt created'	
	
		rm SampleID.table
		rm HsMetrics.table
#done
	
