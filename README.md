# gatk-preprocessing-short-read
Bash pipeline to perform pre-processing of short-read sequencing data following gatk-guidelines:
(Broad Institute: https://gatk.broadinstitute.org/hc/en-us/articles/360039568932--How-to-Map-and-clean-up-short-read-sequence-data-efficiently).

The bash scripts 1-6 concatenate Picard tools to perform the pre-rpocessing (quality control and filtering) of short-read Next Generation Sequencing data (pair-end).
This generates a cleanBAM file for each sample.

In this file:
-adapter sequences have been flagged
-low quality reads are flagged
-reads have been mapped to the reference genome
-duplicated sequences due to PCR or optical artefacts are flagged

This pipeline was used to process Whole exome sequencing data produced with the TWIST kit for library prep and enrichment of exomes. 
Picard_CollectHsMetrics.sh/conf allows to apply the Picard tool from the Broad Institute to calculate quality metrics relative to the Hybridisation Step (Hybrid selection).
Bash_CreateHsMetricsTable.sh collates the HsMetrics for all samples in one table that can be used for downstream analyses. 

Picard_MergeSamFiles.sh/conf allows to apply the Picard tool from the Broad Institute to merge the pre-processed clean-data obtained from different runs/flow-cells for any given sample. 
The output .bam file is sorted by coordinate, to be used in downstream steps for germline variant calling. 
