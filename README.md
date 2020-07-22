# Processing Metagenomic sequencing reads
A pipeline for assembly, annotation and taxonomic classification of metagenomes after sequencing.

## Index
- Quality control have using _fastqc_ and adapter trimming using _cutadapt_.
- Assembling the reads using MEGAHIT.
- Gene prediction and annotation with PROKKA.
- Additional functional annotation using DIAMOND with the eggNOG database.
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
- eggNOG-mapper v2 and eggNOG database v5.0
- KRAKEN2 v2.0.8
- MaxBin v2.2.6

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

## Step 3: Gene prediction and annotation with PROKKA
Once assembly is complete we need to get the coding genes and make a first functional annotation. To do this we will use PROKKA with the results contigs file,  _final.contigs.fa_, from the previus step: 
```
prokka final.contigs.fa --outdir OUT_DIR --norrna --notrna --metagenome --addgenes --cpus Nr_of_cores
```
Again, you can accelerate the calculation adding CPU cores with the option _--cpus_. Additional options _--norna_ and _--notrna_ avoid the prediction of rRNA and tRNA genes, _--metagenome_ improve the prediction for highly fragmented genomes and _--addgenes_ is just to add gene name in the final output. Among all output files produced by _Prokka_ the most interesting are the _.tsv_ file, which is a table describing each coding region with the gene name, EC number and product description, and the fasta files with the aminoacid sequences from the predicted genes (_.faa_).

## Step 4: Additional functional annotation using DIAMOND with the eggNOG database
Since _Prokka_ annotation could result a bit insufficient we complement the functional annotation using the eggNOG database, which combines the functional information of different databases (COG, arCOG, Pfam,...). _eggNOG-mapper_ can do the task directly, but if we split the search by using _DIAMOND_ we accelerate the process since _DIAMOND_ is much faster. Therefore, we combine the use of _DIAMOND_ with the eggNOG diamond database, created during the installation of _eggNOG-mapper_, to make an annotation of our genes based on the eggNOG database.

So, first step then is to launch diamond, for what we need to have located the aminoacids fasta file created by _Prokka_ and the eggNOG diamond database created on _eggNOG-mapper_ installation (usually: _eggnog-mapper/data/eggnog_proteins.dmnd_).
```
diamond blastp -d eggnog_proteins.dmnd -q PROKKA_xxxx.faa --threads Nr_of_cores --out diamond_output_file --outfmt 6 -t /tmp --max-target-seqs 1
```
Here there are some options to take into account. First, _-threads_ is to set the number of CPU cores to perform the calculation. _-out_ sets the output name file, which we will call from now on _diamond.hits.txt_. _--outfmt_ and _--max-target-seqs_ are _blastp_ options to set the output format (6 corresponds to tabular format) and the number of matching hits in the output (here we set 1 to get just the best hit). Finally, _-t_ is to set a directory for temporal files.

Next step is to use _eggMapper_ using the _DIAMOND_ output on _diamond.hits.txt_, but first we need to transform this output into a file suitable to use by _eggMapper_. To this end we developed a small script in Perl, _Diamond2eggMapper.pl_:
```
Diamond2eggMapper.pl diamond.hits.txt > eggMapper_input_file
```
In the first step using _DIAMOND_ we matched the our target genes with its closest target on eggNOG, getting the hits IDs. Then, the resulting output is adapted in order use it by _eggMapper_ and the final step is to run _eggMapper_ to add the full annotation and description corresponding to each of these hits, using the option _annotate_hits_table_:
```
emapper.py --annotate_hits_table eggMapper_input_file -o eggMapper_output_file
```
Finally, we can combine _PROKKA_ annotations with the additional annotations we just created using the following script:
```
CombinePROKKAeggMapper.pl PROKKA_xxxx.tsv eggMapper_output_file > Final_annotation_file
```
Look that here we use the tabular output from PROKKA _.tsv_.

## Step 5: Taxonomic classification of metagenomic reads
There are some different programs to classify into a lineage raw reads or assembled contigs produced by metagenomics sequencing. Some of then are based on searching marking genes into the dataset and classify then according to a database, like the case of GrafM (http://geronimp.github.io/graftM). However, most of the programs are based on _k-mers_, splitting the target sequences into smaller fragments of _k_ length and then process these _k-mers_ according to their different algorithms. For instance, _Kaiju_ (https://github.com/bioinformatics-centre/kaiju) is based on Maximium Exact Matching (MEM), where target sequences are split on small _k-mers_ and match directly against the sequences from reference database, assigning the taxonomy of the hit where the target fragment got higher numer of exact matches. However, currently one of the most cited programs for classification of metagenomic reads are _Kraken_(http://ccb.jhu.edu/software/kraken/) and its new version _Kraken2_(https://ccb.jhu.edu/software/kraken2/), which we will use here. It uses _k-mers_-based algorithm, mapping every target sequence _k-mers_ over the taxonomic tree of all the genomes of the reference database, assigning a taxonomic label according to the Lowest Common Ancestor (LCA) containing that _k-mer_.

### 5.1: Classification using Kraken2
In order to run Kraken2 you first need to create a reference database against which we will match our sequences. In our case, we will create the database based on the NCBI RefSeq of Bacteria and Archaea. First, we need to download both taxonomies in a common database folder:
```
kraken2-build --download-library bacteria --db OurDatabaseName
kraken2-build --download-library archaea --db OurDatabaseName
```
For additional information, we could add custom sequences to our database using the _--add-to-library_ command, using a fasta format file. Once the library is created have to build the database:
```
 kraken2-build --build --db OurDatabaseName --threads Nr_of_cores
```
Now we are ready to fun _Kraken2_ against our RefSeq database. For a straigh use of the _Kraken2_ use the following command line:
```
kraken2 --threads Nr_of_cores --db OurDatabaseName --output OutputName --report Output2Name --use-names Fasta_Input_file
```
Option _--use-names_ add the scientific names of the assigned taxons to the final output, while _--report_ offers a tab delimited output alternative to the starndard output assigned on _--output_. Regard that final argument is the input file in fasta format, which could be the raw reads or assembled contigs.

### 5.2: Improving classification by binning reads with MaxBin
When using marking genes based algorithms (GraftM,...) only reads matching those marking genes (i.e., 16S rRNA genes) are classified, but _k-mers_-based algorithms try to classified the 100% of the resulting reads from sequencing (Kraken2, ...). In this case, sometimes straight classification of reads can return a high number of reads that were not assigned to any taxonomy. If the percentage of classified sequences is not higher than 70%, then you could try extra strategies which could help you to rise up the number of classified sequences. 

One of this strategies could be binning assembled contigs and raw reads in order to get bins  that we use after for classification instead the raw reads. This strategy tries to recover individual genomes, what could make easier the classification. We can do this using MaxBin. This program clusters reads and assembled contigs into bins, each in theory consisting into contigs from one species.

To run MaxBin we will need the Initiall _R*.fastq.gz_ files for reads and the file with assembled contigs by MegaHit,  _final.contigs.fa_. 
```
run_MaxBin.pl -contig final.contigs.fa -out OutputDirectory -reads R1.fastq.gz -reads2 R2.fastq.gz -thread Nr_of_cores
```
Each resulting bin will be in a fasta file on the Output directory. We can concatenate all bins in a single fasta file:
```
cat OutputDirectory/*.fasta > All.bins.fasta
```
Now we can use this single file to run again _Kraken2_ and check if we get a better classification ratio:

```
kraken2 --threads Nr_of_cores --db OurDatabaseName --output OutputName --report Output2Name --use-names All.bins.fasta
```





