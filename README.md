# MetagenomeProcessing
A pipeline for assembly, annotation and taxonomic classification of metagenomes after sequencing.

## Index
- Quality control have been performed using _fastqc_ and adapter trimming using _cutadapt_, discarding those reads with average quality under 20 or shorter than20 bps
- Assembly have been performed using MEGAHIT
- Gene prediction and annotation have been peformed using PROKKA
- Additional annotation was added using emapper and DIAMOND with the eggNOG database
- Taxonomic classification

## Initial files
Basically, we will start from the final reads files resulting from the sequencing process. We will assume that we have two files for each metagenome from a __paired__ analysis:
- R1.fastq.gz
- R2.fastq.gz

## Dependencies
- FastQC

## Step 1: Quality control and trimming
For quality control we are going to use the FastQC toolkit. This is not essential for the rest of the pipeline but could give additional information about the quality of the sequencin process and the length of the reads. This could be helpful in order to choose the parameters to make the trimming. 
