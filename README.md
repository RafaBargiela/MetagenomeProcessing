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
- FastQC v0.11.8
- cutadapt v2.3
- MEGAHIT v1.1.3
- PROKKA v1.14.5
- DIAMOND v0.9.22.123
- eggNOG-mapper v2 and eggNOG database 5.0
- KRAKEN2 v2.0.8

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
Assembly is one of the most important parts porcessing metagenomic reads. All the gene annotation and prediction will depend of the accuracy of this step. There are many assemblers for metagenomes, each with different advantages but there is not a clear evidence showing any to be better than the others. For further information, I would recommend the read of the following paper about the current state of art on metagenome assembly:

- Martin Ayling, Matthew D Clark, Richard M Leggett. _New approaches for metagenome assembly with short reads_. Briefings in Bioinformatics, , bbz020, https://doi.org/10.1093/bib/bbz020

In our case, we have chosen MEGAHIT as assembler. Here we start where we left on the step before, after using _cutadapt_, using the resulting trimmed files:

- R1.trimmed.fastq.gz
- R2.trimmed.fastq.gz

We will use MEGAHIT with the following command line:
```
megahit -1  R1.trimmed.fastq.gz -2 R2.trimmed.fastq.gz -o OUT_DIR -t Nr_of_cores --k-list 21,41,61,81,99
```
Use _-t_ option only if you want to use more than one CPU cores to accelerate calculation. _--k_ option sets up the list of k-mers size, where is recommended to use odd numbers in the range 15-255 with increment <=28. Contigs of final assembly are storage in OUT_DIR on file _final.contigs.fa_.

## Gene prediction and annotation with PROKKA
Once assembly is complete we need to get the coding genes and make a first functional annotation. To do this we will use PROKKA with the results contigs file,  _final.contigs.fa_, from the previus step: 
```
prokka final.contigs.fa --outdir OUT_DIR --norrna --notrna --metagenome --addgenes --cpus Nr_of_cores
```
Again, you can accelerate the calculation adding CPU cores with the option _--cpus_. Additional options _--norna_ and _--notrna_ avoid the prediction of rRNA and tRNA genes, _--metagenome_ improve the prediction for highly fragmented genomes and _--addgenes_ is just to add gene name in the final output. Among all output files produced by _Prokka_ the most interesting are the _.tsv_ file, which is a table describing each coding region with the gene name, EC number and product description, and the fasta files with the aminoacid sequences from the predicted genes (_.faa_).





