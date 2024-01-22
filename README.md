[![Circleci](https://circleci.com/gh/jimmyliu1326/SamnSero_Nextflow.svg?style=svg)](https://app.circleci.com/pipelines/github/jimmyliu1326/SamnSero_Nextflow)

# SamnSero (Nextflow)

The nextflow pipeline processes raw Nanopore sequencing reads for *Salmonella enterica*. Different modules can be optionally invoked to perform genome annotation and quality control checks. Optionally, interactive reports can be generated in HTML format to view data quality metrics and genome annotations.

## Installation

```bash
# Install pre-requisites
 - Nextflow >= 21.0
 - Docker or Singularity
 - Git

# Get the latest version of the pipeline
ver=$(git ls-remote -t https://github.com/jimmyliu1326/SamnSero_Nextflow.git | cut -f3 -d'/' | sort -r | head -n 1)

# Install the latest version of SamnSero
nextflow pull -hub github jimmyliu1326/SamnSero_Nextflow -r $ver
```

## Getting Started

To initiate a `SamnSero` run, you must first prepare a **headerless** `samples.csv` with two columns that indicate sample IDs and paths to **DIRECTORIES** containing .FASTQ or .FASTQ.GZ files

Example `samples.csv`

```
Sample_1,/path/to/data/Sample_1/
Sample_2,/path/to/data/Sample_2/
Sample_3,/path/to/data/Sample_3/
```

Given the `samples.csv` above, your data directory should be set up like the following:

```
/path/to/data/
├── Sample_1
│   └── Sample_1.fastq.gz
├── Sample_2
│   └── Sample_2.fastq.gz
└── Sample_3
    ├── Sample_3a.fastq
    └── Sample_3b.fastq
```

*Note:*
* The sequencing data for each sample must be placed within a unique subdirectory
* The names of the sample subdirectories do not have to match the sample ID listed in the `samples.csv`
* You can have multiple .FASTQ files associated with a single sample. The pipeline will aggregate all .FASTQ files within the same directory before proceeding (for Nanopore data only)

Once you have set up the data directory as described and created the `samples.csv`, you are ready to run the pipeline.

## Pipeline Usage

The pipeline executes process in Docker containers by default. Singularity containers and process management by Slurm are also supported. See below how to run the pipeline using different container platforms.

**Docker (Default)**

```bash
nextflow run jimmyliu1326/SamnSero_Nextflow -latest --input samples.csv --out_dir results
```

**Singularity**

```bash
nextflow run jimmyliu1326/SamnSero_Nextflow -latest --input samples.csv --out_dir results -profile singularity
```

**Slurm + Singularity**

```bash
nextflow run jimmyliu1326/SamnSero_Nextflow -latest --input samples.csv --out_dir results --account my-slurm-account -profile slurm,singularity 
```

Below is the complete list of pipeline options available:

```
    I/O:
        --input PATH                    Path to a .csv containing two columns describing Sample ID and path
                                        to raw reads directory
        --outdir PATH                   Output directory path

    Sequencing info:
        --seq_platform STR              Sequencing platform that generated the input data (Options: nanopore|illumina) 
                                        [Default = nanopore]
        --meta                          Optimize assembly parameters for metagenomic samples
        --taxon_name STR                Name of the target organism sequenced. [Default = "Salmonella enterica"]
        --taxon_level STR               Taxon level of the target organism specified. [Default = species]
        --nanohq                        Input Nanopore reads were basecalled using SUP models

    Data quality check:
        --trim                          Perform adapter and barcode trimming on raw reads
        --qc                            Quality check input reads and genome assemblies
        --centrifuge PATH               Path to DIRECTORY containing Centrifuge database index (required if using --qc)

    Genome annotation:
        --annot                         Annotate genome assemblies

    GPU acceleration:
        --gpu                           Accelerate specific processes that utilize GPU computing. Must have
                                        NVIDIA Container Toolkit installed to enable GPU computing
        --medaka_batchsize INT          Medaka batch size (smaller value reduces memory use) [Default = 100]
        
    Slurm HPC:
        --account STR                   Slurm account name (required if running in Slurm HPC)

    Other:
        --noreport                      Do not generate interactive reports
        --help                          Print pipeline usage statement
        --version                       Print workflow version
```
