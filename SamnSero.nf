#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// define global var
pipeline_name = workflow.manifest.name

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

def versionPrint() {
    log.info """
        $pipeline_name v${workflow.manifest.version}
    """.stripIndent()
}

// check params
if (params.help) {
    helpMessage()
    exit 0
}

if (params.version) {
    versionPrint()
    exit 0
}

if ( params.qc == true & !(params.taxon_level ==~ '(species|kingdom|phylum|class|order|family|genus|domain)') ) {
    error pipeline_name+": The taxon_level parameter contains invalid values"
}

if ( !(params.seq_platform ==~ '(nanopore|illumina)') ) {
    error pipeline_name+": The seq_platform parameter contains invalid values"
}

if ( params.qc == true & params.taxon_name == true ) {
    error pipeline_name+": The taxon_name parameter is empty"
}

if ( !params.outdir ) { error pipeline_name+": Missing --outdir parameter" }
if ( !params.input ) { error pipeline_name+": Missing --input parameter" }

// print log info
log.info """\
         ========================================
         S A M N S E R O   P I P E L I N E  v${workflow.manifest.version}
         ========================================
         input               : ${params.input}
         outdir              : ${params.outdir}
         seq_platform        : ${params.seq_platform}
         taxon_level         : ${params.taxon_level}
         taxon_name          : ${params.taxon_name}
         trim                : ${params.trim}
         nanohq              : ${params.nanohq}
         quality check       : ${params.qc}
         annotation          : ${params.annot}
         meta                : ${params.meta}
         gpu                 : ${params.gpu}
         noreport            : ${params.noreport}
         medaka_batchsize    : ${params.medaka_batchsize}
         """
         .stripIndent()

// import workflows
include { nanopore } from './workflow/nanopore.nf'
include { illumina } from './workflow/illumina.nf'
include { post_asm_process } from './workflow/post_asm_process.nf'

// define main workflow
workflow {
    
    // read data
    data = channel
        .fromPath(params.input, checkIfExists: true)
        .splitCsv(header: false)

    // start analysis
    if ( params.seq_platform == "nanopore" ) {

        nanopore(data)
        post_asm_process(nanopore.out.assembly, nanopore.out.reads)

    } else if ( params.seq_platform == "illumina" ) {
        
        illumina(data)
        post_asm_process(illumina.out.assembly, illumina.out.reads)

    }
    
}