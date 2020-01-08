# MetagenomeProcessing
A pipeline for assembly, annotation and taxonomic classification of metagenomes after sequencing.

## Index
- Quality control have using _fastqc_ and adapter trimming using _cutadapt_.
- Assembling the reads using MEGAHIT.
- Gene prediction and annotation with PROKKA.
- Additional functional annotation was added using emapper and DIAMOND with the eggNOG database.
- Taxonomic classification of metagenomic reads.

## Initial files
Basically, we will start from the final reads files resulting from the sequencing process. We will assume that we have two files for each metagenome from a __paired__ analysis:
- R1.fastq.gz
- R2.fastq.gz

## Dependencies
- FastQC
- cutadapt
- MEGAHIT
- PROKKA
- emapper and eggNOG database (storing the DIAMOND version)
- KRAKEN2

## Step 1: Quality control and trimming
For quality control we are going to use the _FastQC_ toolkit. This is not essential for the rest of the pipeline but could give additional information about the quality of the sequencing process and the length of the reads. This could be helpful in order to choose the parameters to make the trimming. 

```
fastqc -o $OUT_DIR R1.fastq.gz R2.fastq.gz
```
Inside the $OUT_DIR directory you will find an .html file which will open on the browser a summary about your reads. Now, the second and most important part is to trim the __adapter__ from the reads using _cutadapt_. In our case we will remove the adapter ligated on the 3' end in both paired reads, that's because we use -a and -A options, followed by the adapter sequence to trim. Also, we going to discard those bases with __quality lower than 20__ using -q option over both paired reads (-q 20,20). Also, we will use -m option to remove those reads with __length smaller than 20 bases__. So, final commands would be like following:

```
cutadapt -q 20,20 -m 20 -a AGTCAA -A AGTCAA -o R1.trimmed.fastq.gz -p R2.trimmed.fastq.gz R1.fastq.gz R2.fastq.gz > $report
```
Report produced by the program will be saved on $report file. If you want, you could run _FastQC_ again over the trimmed files to check the differences:

```
fastqc -o $OUT_DIR R1.trimmed.fastq.gz -p R2.trimmed.fastq.gz
```

## Step 2: Assembling the reads using MEGAHIT
Assembly is one of the most important parts porcessing metagenomic reads. All the gene annotation and prediction will depend of the accuarcy of this step. There are many assemblers for metagenomes, each with different advantages but there is not a clear evidence showing any to be better than the others. For further information, I would recommend the read of the following paper about the current state of art on metagenome assembly:

- Martin Ayling, Matthew D Clark, Richard M Leggett. _New approaches for metagenome assembly with short reads_. Briefings in Bioinformatics, , bbz020, https://doi.org/10.1093/bib/bbz020

In our case, we have chosen MEGAHIT as assembler. Here we start where we left on the step before, after using cutadapt, using the resulting trimmed files:

- R1.trimmed.fastq.gz
- R2.trimmed.fastq.gz



