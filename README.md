[![Circleci](https://circleci.com/gh/jimmyliu1326/SamnSero_Nextflow.svg?style=svg)](https://app.circleci.com/pipelines/github/jimmyliu1326/SamnSero_Nextflow)

# SamnSero: Bacterial Genomics for Nanopore Sequencing

`SamnSero` was developed to streamline the analysis of Nanopore sequencing data from bacterial isolates and metagenomic samples. The workflow serves three primary purposes:
- [Long read (meta-)genome assembly](https://github.com/jimmyliu1326/SamnSero_Nextflow?tab=readme-ov-file#meta-genome-assembly)
- [Data quality assessment and control](https://github.com/jimmyliu1326/SamnSero_Nextflow?tab=readme-ov-file#data-quality-assessment-and-control)
- Post-assembly analysis e.g. Typing and annotation

Originally designed as a post-run analysis tool, it has since evolved to leverage the live basecalling feature of Oxford Nanopore Technologies (ONT) to deliver real-time data processing. Motivated by the need to reduce time to genomics results and bring greater transparency to sequencing experiments, users can now execute the pipeline in parallel with their sequencing experiments to monitor read quality, genome assembly quality, taxonomic abundance and typing results as a function of time (Note: for typing, only *Salmonella* *in silico* serotyping is supported at the moment!).

![workflow](https://github.com/jimmyliu1326/SamnSero_Nextflow/blob/main/assets/SamnSero_workflow.png?raw=true)

## Installation

The pipeline can either be run directly from the command line or EPI2ME.

#### Command line interface

For command line execution, use the workflow management feature of `Nextflow` to install `SamnSero`
```bash
# Install pre-requisites
 - Nextflow >= 23.0
 - Docker or Singularity
 - Git

# Get the latest release tag of the pipeline
ver=$(git ls-remote -t https://github.com/jimmyliu1326/SamnSero_Nextflow.git | cut -f3 -d'/' | sort -r | head -n 1)

# Install the latest version of SamnSero
nextflow pull -hub github jimmyliu1326/SamnSero_Nextflow -r $ver

# Print pipeline help to validate installation
nextflow run jimmyliu1326/SamnSero_Nextflow -r $ver --help
```

#### Graphical interface (EPI2ME)

For more user-friendly graphical interfaces, we recommend installing the pipeline in [EPI2ME](https://labs.epi2me.io/quickstart/). After clicking on `Import Workflow` in the application, enter the full URL to this GitHub repository when prompted:

> https://github.com/jimmyliu1326/SamnSero_Nextflow

![epi2me-install](https://github.com/jimmyliu1326/SamnSero_Nextflow/blob/main/assets/epi2me_install.png?raw=true)

## Getting started with post-run analysis

Required Parameters:

- `--input`: comma-delimited sample sheet 
- `-profile`: `docker`/`singularity`/`slurm` or a combination of multiple profiles delimiting the values by comma

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

Once you have set up the data directory as described and created the `samples.csv`, you are ready to run the pipeline!

## Getting started with real-time analysis

Required Parameters:

- `--watchdir`: directory to where FASTQ files are deposited in real-time
- `-profile`: `docker`/`singularity`/`slurm` or a combination of multiple profiles delimiting the values by comma

The pipeline assumes `watchdir` follows the nested output directory structure of ONT basecallers: `[run_id]/**/[qscore_pass_fail]/[barcode_arrangement]/`

The FASTQ data can be deeply nested in as many directories as possible under the `[run_id]` parent directory. The pipeline by default performs a recursive search for FASTQ data in `watchdir`. FASTQ data can be uncompressed or gzip compressed.

An example `watchdir` directory structure should resemble the following:

```
/path/to/watchdir/
├── ANY_NUMBER_OF_SUBDIRECTORIES/
│   ├── pod5/
│   ├── fastq_fail/
└── └── fastq_pass/
        ├── barcode01/
        │   ├── batch01.fastq.gz
        │   └── batch02.fastq.gz
        ├── barcode02/
        │   └── batch03.fastq.gz
        └── barcode03/
            └── batch04.fastq.gz
```

The pipeline by default monitors for the creation or modification of FASTQ data passing quality filter i.e. written to the `pass` or `fastq_pass` folder. The file monitoring behavior of the pipeline can be amended using `--watch_mode` which supports three file event types: `create`, `modify`, `delete`. The default value for `watch_mode` is `create,modify`.

For real-time analysis, the pipeline internally attempts to optimize the resource allocation by limiting the resource consumption of compute-heavy processes. The optimization helps to guarantee access to real-time feedback in the form of technical reports by ensuring that there are always resources to spare for data summary and results reporting. The resource optimization is dependent on the value of `watch_cpus` which specifies the maximum available CPU cores available for analysis. The recommended `watch_cpus` for real-time analysis is 64 or greater.

## Pipeline Usage

The pipeline executes process in Docker containers by default. Singularity containers and process management by Slurm are also supported. See below how to run the pipeline using different containerization technologies.

**Docker (Default)**

 Without specifying a profile, Docker containers are used by default.

```bash
nextflow run jimmyliu1326/SamnSero_Nextflow -r [vers] --input samples.csv --out_dir results
```

**Singularity** 

Add `-profile singularity` to use Singularity containers.

```bash
nextflow run jimmyliu1326/SamnSero_Nextflow -r [vers] --input samples.csv --out_dir results -profile singularity
```

**Slurm + Singularity**

For environments with Slurm support, append `-profile singularity` and specify your Slurm account using the `--account` parameter.

```bash
nextflow run jimmyliu1326/SamnSero_Nextflow -r [vers] --input samples.csv --out_dir results --account my-slurm-account -profile slurm,singularity 
```

## (Meta-)Genome assembly

Both ONT long-read and Illumina paired-end short read genome assemblies are supported which can be toggled using `--seq_platform nanopore/illumina`. 

For metagenomic data, use `--meta on` to generate metagenome assembled genomes (MAGs). Post-assembly contig binning is currently under active development. We are actively working towards resolving strain-level haplotypes and reconstruct genomes of individual strains which would enable the decomposition of mixed populations of the same species.

There is currently no plans to support hybrid genome assembly.

## Data quality assessment and control

Sequencing data quality assessment and control can be invoked by the `--qc` option.

The sequencing data QA/QC involves the following modules:

- nanoq: Read quality/length filtering
- centrifuge: Taxonomic classification
- krona: Visualization of microbial composition
- QUAST: Genome assembly statistics summary
- CheckM: Single copy marker gene analysis
- nanocomp: Raw read summary statistics report

To use the `--qc` option, a pre-downloaded Centrifuge database is required, which can be downloaded from [here](https://genome-idx.s3.amazonaws.com/centrifuge/p_compressed%2Bh%2Bv.tar.gz). 

After downloading the tar file, it needs to be decompressed into a directory, the path of which needs to supplied via the `--centrifuge` option along with `--qc`.
