[![Circleci](https://circleci.com/gh/jimmyliu1326/SamnSero_Nextflow.svg?style=svg)](https://app.circleci.com/pipelines/github/jimmyliu1326/SamnSero_Nextflow)

# SamnSero (Nextflow)


The nextflow pipeline processes raw Nanopore sequencing reads for *Salmonella enterica*. Different modules can be optionally invoked to perform genome annotation and quality control checks. Optionally, interactive reports can be generated in HTML format to view genome assembly/raw read quality metrics and genome annotations.

## Installation

```bash
# Install pre-requisites
 - Nextflow >= 21.0
 - Docker
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
* You can have multiple .FASTA files associated with a single sample. The pipeline will aggregate all .FASTQ files within the same directory before proceeding

Once you have set up the data directory as described and created the `samples.csv`, you are ready to run the pipeline.

Here is a standard command line call to the `SamnSero` pipeline:

```bash
nextflow run jimmyliu1326/SamnSero_Nextflow --input samples.csv --outdir results
```

## Pipeline Usage Details

Below is the complete list of pipeline options available:

```
Required arguments:
    --input PATH                   Path to a .csv containing two columns describing Sample ID and path
                                   to raw reads directory
    --outdir PATH                  Output directory path

Optional arguments:
    --annot                        Annotate genome assemblies using Abricate
    --taxon_name STR               Name of the target organism sequenced. Quote the string if the name contains
                                   space characters [Default: "Salmonella enterica"]
    --taxon_level STR              Taxon level of the target organism sequenced. [Default: species]
    --qc                           Perform quality check on genome assemblies
    --centrifuge PATH              Path to DIRECTORY containing Centrifuge database index (required if using
                                   --qc)
    --nanohq                       Input reads were basecalled using Guppy v5 SUP models
    --notrim                       Skip adaptor trimming by Porechop
    --gpu                          Accelerate specific processes that utilize GPU computing. Must have NVIDIA
                                   Container Toolkit installed to enable GPU computing, otherwise use CPU.
    --noreport                     Do not generate interactive reports
    --help                         Print pipeline usage statement
```