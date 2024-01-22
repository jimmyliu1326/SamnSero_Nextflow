// import workflows
include { SEROTYPING } from '../subworkflow/serotyping.nf'
include { ANNOT } from '../subworkflow/genome_annotation.nf'
include { ASSEMBLY_QC; READ_QC } from '../subworkflow/sequence_qc.nf'
include { MG_BIN } from '../subworkflow/metagenome_binning.nf'
include { XTRACT_TARGET_CTGS } from '../subworkflow/xtract_target_ctgs.nf'

// import modules
include { combine_res } from '../modules/local/parse.nf'
include { qc_report; annot_report; qc_report_watch } from '../modules/local/report.nf'

workflow post_asm_process {

    take: in_assembly
          reads
          taxid

    main:
        
        // perform metagenomic binning
        if ( params.meta != 'off' ) {
            
            if ( !params.disable_binning ) { // bin contigs
                
                MG_BIN(in_assembly, reads)
                
                if ( params.meta == 'targeted' ) {
                    
                    assembly = MG_BIN.out.target_bins

                } else {

                    assembly = MG_BIN.out.bins

                }
            } else { // run if binning is disabled

                assembly = in_assembly

                if ( params.meta == "targeted" ) {

                    assembly = XTRACT_TARGET_CTGS(in_assembly, reads, taxid) 

                }

            }
            

        } else {

            assembly = in_assembly

        }

        // in-silico serotyping
        SEROTYPING(assembly)

        // genome annotation
        if ( params.annot ) { 
            
            ANNOT(assembly)
            
            if ( !params.noreport) {

                annot_report(SEROTYPING.out, ANNOT.out)
            
            }

        }

        // run sequence QC
        if ( params.qc ) { 
                
            READ_QC(reads, taxid)
            ASSEMBLY_QC(assembly, reads)

            combine_res(
                SEROTYPING.out,
                ASSEMBLY_QC.out.checkm_res,
                ASSEMBLY_QC.out.quast_res
            )            

            if ( !params.noreport ) {
                
                if ( params.watchdir ) {
                    
                    SEROTYPING.out.map { 
                        timestamp = it.getSimpleName().replaceAll('sistr_res_aggregate_', '')
                        tuple( timestamp, it)
                    }
                    | join(ASSEMBLY_QC.out.checkm_res.map { 
                        timestamp = it.getSimpleName().replaceAll('checkm_res_aggregate_', '')
                        tuple( timestamp, it)
                    })
                    | join(ASSEMBLY_QC.out.quast_res.map { 
                        timestamp = it.getSimpleName().replaceAll('quast_res_aggregate_', '')
                        tuple( timestamp, it)
                    })
                    | join(READ_QC.out.target_res.map { 
                        timestamp = it.getSimpleName().replaceAll('target_reads_aggregate_', '')
                        tuple( timestamp, it)
                    })
                    | join(READ_QC.out.kreport)
                    | qc_report_watch

                } else {

                    qc_report(SEROTYPING.out, ASSEMBLY_QC.out.checkm_res, ASSEMBLY_QC.out.quast_res, READ_QC.out.target_res, READ_QC.out.kreport)

                }           
            }

        } else {

            // combine results into a master file
            combine_res(SEROTYPING.out, [], [])

        }

        
}