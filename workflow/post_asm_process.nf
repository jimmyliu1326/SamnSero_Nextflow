// import workflows
include { SEROTYPING } from '../subworkflow/serotyping.nf'
include { ANNOT } from '../subworkflow/genome_annotation.nf'
include { ASSEMBLY_QC; READ_QC } from '../subworkflow/sequence_qc.nf'

// import modules
include { combine_res } from '../modules/local/parse.nf'
include { qc_report; annot_report } from '../modules/local/report.nf'

workflow post_asm_process {

    take: assembly
          reads

    main:
        
        // in-silico serotyping
        SEROTYPING(assembly)

        // genome annotation
        if ( params.annot ) { 
            
            ANNOT(assembly)
            
            if ( !params.noreport) {

                annot_report(SEROTYPING.out, ANNOT.out)
            
            }

        }

        // assembly QC
        if ( params.qc ) { 
                
            READ_QC(reads)

            ASSEMBLY_QC(assembly, reads)

            results = ASSEMBLY_QC.out.checkm_res
                        | concat(ASSEMBLY_QC.out.quast_res, SEROTYPING.out)
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