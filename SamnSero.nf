#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// define global var
pipeline_name = "SamnSero"
version = "1.5.3"

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
        --qc                            Perform quality check on genome assemblies
        --taxon_name STR                Name of the target organism sequenced. Quote the string if the name contains
                                        space characters [Default: "Salmonella enterica"]
        --taxon_level STR               Taxon level of the target organism sequenced. [Default: species]
        --centrifuge PATH               Path to DIRECTORY containing Centrifuge database index (required if using --qc)
        --nanohq                        Input reads were basecalled using Guppy v5 SUP models
        --notrim                        Skip adaptor trimming by Porechop
        --gpu                           Accelerate specific processes that utilize GPU computing. Must have
                                        NVIDIA Container Toolkit installed to enable GPU computing
        --noreport                      Do not generate interactive reports
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

if ( params.qc & !(params.taxon_level ==~ '(species|kingdom|class|order|genus|domain)') ) {
    error pipeline_name+": The taxon_level parameter contains invalid value"
}

if ( params.qc & params.taxon_name == true ) {
    error pipeline_name+": The taxon_name parameter is empty"
}

if( !params.outdir ) { error pipeline_name+": Missing --outdir parameter" }
if( !params.input ) { error pipeline_name+": Missing --input parameter" }

// print log info
log.info """\
         ========================================
         S A M N S E R O   P I P E L I N E  v${version}
         ========================================
         input               : ${params.input}
         outdir              : ${params.outdir}
         taxon_level         : ${params.taxon_level}
         taxon_name          : ${params.taxon_name}
         disable trimming    : ${params.notrim}
         nanohq              : ${params.nanohq}
         quality check       : ${params.qc}
         annotation          : ${params.annot}
         gpu                 : ${params.gpu}
         noreport            : ${params.noreport}
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
        
        if ( !params.noreport) {

            annot_report(SEROTYPING.out, ANNOT.out)
        
        }

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

        results = ASSEMBLY_QC.out.checkm_res \
                    | concat(ASSEMBLY_QC.out.quast_res, SEROTYPING.out) \
                    | collect

        if ( !params.noreport ) {
            
            qc_report(SEROTYPING.out, ASSEMBLY_QC.out.checkm_res, ASSEMBLY_QC.out.quast_res, READ_QC.out.kreport.collect())
            
        }
        

    } else {
        
        results = SEROTYPING.out

    }

    // combine results into a master file
    combine_res(results)
}