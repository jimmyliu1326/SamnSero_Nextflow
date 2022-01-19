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
         """
         .stripIndent()

// import modules
include { combine; porechop } from './modules/local/nanopore-base.nf'
include { flye } from './modules/local/nanopore-assembly.nf'
include { medaka } from './modules/local/nanopore-polish.nf'
include { sistr; aggregate_sistr } from './modules/local/sistr.nf'

// define workflow
workflow {
    // read data
    data = channel.fromPath(params.input, checkIfExists: true).splitCsv(header: false)

    // workflow start
    combine(data)
    if (params.notrim) {
        flye(combine.out)
    } else { 
        porechop(combine.out) | flye
    }
    medaka(combine.out, flye.out)
    sistr(medaka.out)
    aggregate_sistr(sistr.out.collect()) 
}