#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// define global var
pipeline_name = "SamnSero"
version = "1.0"

// print help message
def helpMessage() {
    log.info """
        Usage: nextflow run jimmyliu1326/SamnSero_Nextflow --input samples.csv --outdir /path/to/output

        Required arguments:
        --input PATH                    Path to a .csv containing two columns describing Sample ID and path
                                        to raw reads directory
        --outdir PATH                   Output directory path

        Optional arguments:
        --annot                         Annotate genome assemblies using Abricate
        --custom_db PATH                Path to a headerless .csv that lists custom databases (.FASTA) to
                                        search against for genome annotation instead of default Abricate
                                        databases (card, vfdb, plasmidfinder). The .csv should contain two
                                        columns describing database name and path to FASTA.
        --qc                            Perform quality check on genome assemblies.
        --centrifuge                   Path to DIRECTORY containing Centrifuge database index (required if using --qc)
        --nanohq                        Input reads were basecalled using Guppy v5 SUP models
        --notrim                        Skip adaptor trimming by Porechop
        --gpu                           Accelerate specific processes that utilize GPU computing. Must have
                                        NVIDIA Container Toolkit installed to enable GPU computing.
        --help                          Print pipeline usage statement
        --version                       Print workflow version
        """.stripIndent()
}

def versionPrint() {
    log.info """
        $pipeline_name v$version
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

if( !params.outdir ) { error pipeline_name+": Missing --outdir parameter" }
if( !params.input ) { error pipeline_name+": Missing --input parameter" }
if( params.qc ) { 
    db_dir = new File(params.centrifuge)
    assert db_dir.exists() : pipeline_name+": Directory path to Centrifuge database cannot be found."
}

// print log info
log.info """\
         ========================================
         S A M N S E R O   P I P E L I N E  v${version}
         ========================================
         input               : ${params.input}
         outdir              : ${params.outdir}
         disable trimming    : ${params.notrim}
         nanohq              : ${params.nanohq}
         quality check       : ${params.qc}
         annotation          : ${params.annot}
         custom annot db     : ${params.custom_db}
         gpu                 : ${params.gpu}
         """
         .stripIndent()

// import modules
include { porechop; combine } from './modules/local/nanopore-base.nf'
include { combine_res } from './modules/local/parse.nf'
include { qc_report; annot_report } from './modules/local/report.nf'
// import workflows
include { ASSEMBLY } from './workflow/genome_assembly.nf'
include { SEROTYPING } from './workflow/serotyping.nf'
include { ANNOT } from './workflow/genome_annotation.nf'
include { ASSEMBLY_QC; READ_QC } from './workflow/sequence_qc.nf'
// define main workflow
workflow {
    // read data
    data = channel
        .fromPath(params.input, checkIfExists: true)
        .splitCsv(header: false)
    
    // analysis start
    combine(data)

    // trimming and assembly
    if ( params.trim ) { 
        
        porechop(data)
        
        ASSEMBLY(porechop.out)

    } else {
        
        ASSEMBLY(combine.out)

    }    
    // in-silico serotyping
    SEROTYPING(ASSEMBLY.out)

    // genome annotation
    if ( params.annot ) { 
        
        ANNOT(ASSEMBLY.out)
        
        annot_report(SEROTYPING.out, ANNOT.out.collect())

    }

    // sequence QC
    if ( params.qc ) { 
        
        if ( params.trim ) {
            
            READ_QC(porechop.out)

            ASSEMBLY_QC(ASSEMBLY.out, porechop.out)
        
        } else {
            
            READ_QC(combine.out)

            ASSEMBLY_QC(ASSEMBLY.out, combine.out)

        }

        results = ASSEMBLY_QC.out.checkm_res.concat(ASSEMBLY_QC.out.quast_res, SEROTYPING.out).collect()

        qc_report(SEROTYPING.out, ASSEMBLY_QC.out.checkm_res, ASSEMBLY_QC.out.quast_res)

    } else {
        
        results = SEROTYPING.out

    }

    // combine results into a master file
    combine_res(results)
}