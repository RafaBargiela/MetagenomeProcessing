# MetagenomeProcessing
A pipeline for assembly, annotation and taxonomic classification of metagenomes after sequencing.

## Index
- Quality control have been performed using _fastqc_ and adapter trimming using _cutadapt_, discarding those reads with average quality under 20 or shorter than20 bps
- Assembly have been performed using MEGAHIT
- Gene prediction and annotation have been peformed using PROKKA
- Additional annotation was added using emapper and DIAMOND with the eggNOG database
- Taxonomic classification

## Initial files

## Dependencies

## Step 1: Quality control and trimming
