#!/usr/bin/env nextflow
nextflow.enable.dsl=2
nextflow.preview.recursion=true

// print help message
def helpMessage() {
    log.info """
    Usage: nextflow run jimmyliu1326/SamnSero_Nextflow --input samples.csv --outdir /path/to/output -profile standard

    I/O:
        --input PATH                    Path to a .csv containing two columns describing Sample ID and path
                                        to raw reads directory
        --outdir PATH                   Output directory path

    Sequencing info:
        --seq_platform                  Sequencing platform that generated the input data (Options: nanopore|illumina) 
                                        [Default = nanopore]
        --meta                          Optimize assembly parameters for metagenomic samples
        --taxon_name STR                Name of the target organism sequenced. Quote the string if the name contains
                                        space characters [Default = "Salmonella enterica"]
        --taxon_level STR               Taxon level of the target organism sequenced. [Default = species]
        --nanohq                        Input reads were basecalled using Guppy v5 SUP models

    Data quality check:
        --trim                          Perform read trimming
        --qc                            Perform quality check on genome assemblies
        --centrifuge PATH               Path to DIRECTORY containing Centrifuge database index (required if using --qc)

    Genome annotation:
        --annot                         Annotate genome assemblies

    GPU acceleration:
        --gpu                           Accelerate specific processes that utilize GPU computing. Must have
                                        NVIDIA Container Toolkit installed to enable GPU computing
        --medaka_batchsize              Medaka batch size (smaller value reduces memory use) [Default = 100]
        
    Slurm HPC:
        --account STR                   Slurm account name

    Other:
        --noreport                      Do not generate interactive reports
        --help                          Print pipeline usage statement
        --version                       Print workflow version
         
        """.stripIndent()
}

// validate user-supplied parameters
WorkflowMain.initialise(workflow, params, log)

// import workflows
include { nanopore } from './workflow/nanopore.nf'
include { illumina } from './workflow/illumina.nf'
include { post_asm_process } from './workflow/post_asm_process.nf'
include { insert_sample_id } from './modules/local/insert_sample_id/insert_sample_id.nf'
include { taxonkit_name2taxid } from './modules/local/taxonkit/name2taxid.nf'

// define main workflow
workflow {
    
    // read data
    if (params.input) {

        data = channel
            .fromPath(params.input, checkIfExists: true)
            .splitCsv(header: false)

    } else if (params.watchdir) {
        
        watchdir = params.watchdir+"/*/*.{fastq,fastq.gz}"
        Channel.watchPath(watchdir)
            | until { it.getSimpleName() == 'STOP' }
            | map { file ->
                id = file.getParent().getBaseName()
                tuple (id, file)
            }
            | insert_sample_id
            | set { data }

    } else {

        data = Channel.empty()
        println "${workflow.manifest.name}: No valid inputs were provided."

    }     


    // start analysis
    taxid = taxonkit_name2taxid(params.taxon_name)

    if ( params.seq_platform == "nanopore" ) {
        
        nanopore(data)
        post_asm_process(nanopore.out.assembly, nanopore.out.reads, taxid)

    } else if ( params.seq_platform == "illumina" ) {
        
        illumina(data)
        post_asm_process(illumina.out.assembly, illumina.out.reads, taxid)

    }
    
}