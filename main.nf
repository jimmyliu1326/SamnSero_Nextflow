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
include { post_asm_process as post_asm_process_r; post_asm_process as post_asm_process_asm } from './workflow/post_asm_process.nf'
include { rename_FASTQ } from './modules/local/rename_FASTQ/rename_FASTQ.nf'
include { fastq_check } from './modules/local/fastq_check/fastq_check.nf'
include { taxonkit_name2taxid } from './modules/local/taxonkit/name2taxid.nf'
include { rename_FASTA } from './modules/local/rename_FASTA/rename_FASTA.nf'

// define main workflow
workflow {
    
    // read data
    if (params.input) {

        data = channel
            .fromPath(params.input, checkIfExists: true)
            .splitCsv(header: false)
            .branch{ id,path ->
                reads: file(path).isDirectory()
                asm: ( ! file(path).isDirectory() ) & ['.fa', '.fasta', '.fna'].any { path.endsWith(it) }
            }
        
        rename_FASTA(data.asm)

    } else if (params.watchdir) {
        
        // check if max_cpus is sufficient for analysis
        if ( params.watch_cpus.intdiv(32) == 0 ) {
            log.info "${workflow.manifest.name}: Require at least 32 watch_cpus to use --watchdir"
            System.exit(1)
        }
        // check if max_cpus is multiple of 32
        if ( params.watch_cpus % 32 != 0 ) {
            log.info "${workflow.manifest.name}: watch_cpus must be multiples of 32"
            System.exit(1)
        }

        // check watch mode is valid
        params.watch_mode.tokenize(',').each {
            if ( ! it.matches('create|modify|delete') ) {
                log.info "${workflow.manifest.name}: '$it' is an invalid value for --watch_mode. Valid values: create/modify/delete"
                System.exit(1)
            }
        }

        // remove / at the end of watchdir path
        watchpath = params.watchdir.endsWith('/') ? params.watchdir.substring(0, params.watchdir.length() - 1) : params.watchdir
        // define watch file pattern
        watchdir = watchpath+"/**/*.{fastq,fastq.gz}"
        Channel.watchPath(watchdir, params.watch_mode)
            | until { it.getSimpleName() == 'STOP' }
            | filter { it.getParent().getParent().getBaseName() =~ 'pass' } // only keep fastq files written to pass subfolders e.g. fastq_pass            
            | map { file ->
                id = file.getParent().getBaseName()
                tuple (id, file)
            }
            | fastq_check
            | rename_FASTQ
            | map { it[1] }
            | set { data }

    } else {

        data = Channel.empty()
        println "${workflow.manifest.name}: No valid inputs were provided."

    }     


    // start analysis
    taxid = taxonkit_name2taxid(params.taxon_name)

    if ( params.seq_platform == "nanopore" ) {
        
        nanopore(data.reads)
        post_asm_process_r(nanopore.out.assembly, nanopore.out.reads, taxid, false)

    } else if ( params.seq_platform == "illumina" ) {
        
        illumina(data.reads)
        post_asm_process_r(illumina.out.assembly, illumina.out.reads, taxid, false)

    }

    // // process genome assembly directly
    post_asm_process_asm(rename_FASTA.out, data.asm.map { id,path -> [id, [] ] }, taxid, true)
    
}