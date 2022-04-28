#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// define global var
pipeline_name = "SamnSero"

// print help message
def helpMessage() {
    log.info """
        Usage: nextflow run SamnSero.nf --input samples.csv --outdir /path/to/output

        Required arguments:
         --input                       Path to a .csv containing two columns describing Sample ID and path to raw reads directory
         --outdir                      Output directory path

        Optional arguments:
        --annot                        Annotate resulting genomes
        --qc                           Perform quality check of resulting genomes
        --notrim                       Skip adaptor trimming by Porechop
        --help                         Print pipeline usage statement
        """.stripIndent()
}

// check params
if (params.help) {
    helpMessage()
    exit 0
}

if( !params.outdir ) { error pipeline_name+": Missing --outdir parameter" }
if( !params.input ) { error pipeline_name+": Missing --input parameter" }

// print log info
log.info """\
         ==================================
         S A M N S E R O   P I P E L I N E    
         ==================================
         input               : ${params.input}
         outdir              : ${params.outdir}
         disable trimming    : ${params.notrim}
         quality check       : ${params.qc}
         annotation          : ${params.annot}
         custom annot db     : ${params.custom_db}
         """
         .stripIndent()

// import modules
include { porechop; combine } from './modules/local/nanopore-base.nf'
include { combine_res } from './modules/local/parse.nf'
include { ASSEMBLY } from './workflow/genome_assembly.nf'
include { SEROTYPING } from './workflow/serotyping.nf'
include { ANNOT } from './workflow/genome_annotation.nf'
include { QC } from './workflow/genome_qc.nf'
// define main workflow
workflow {
    // read data
    data = channel
        .fromPath(params.input, checkIfExists: true)
        .splitCsv(header: false)
    
    // analysis start
    combine(data)
    if ( params.trim ) { 
        porechop(data)
        ASSEMBLY(porechop.out)
    } else {
        ASSEMBLY(combine.out)
    }    
    
    SEROTYPING(ASSEMBLY.out)

    if ( params.annot ) { ANNOT(ASSEMBLY.out) }

    if ( params.qc ) { 
        QC(ASSEMBLY.out) 
        results = QC.out.checkm_res.concat(QC.out.quast_res, SEROTYPING.out).collect()
    } else {
        results = SEROTYPING.out
    }

    // combine results into a master file
    combine_res(results)
}