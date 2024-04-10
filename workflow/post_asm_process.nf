// import workflows
include { SEROTYPING } from '../subworkflow/serotyping.nf'
include { ANNOT } from '../subworkflow/genome_annotation.nf'
include { ASSEMBLY_QC; READ_QC } from '../subworkflow/sequence_qc.nf'
include { MG_BIN } from '../subworkflow/metagenome_binning.nf'
include { XTRACT_TARGET_CTGS } from '../subworkflow/xtract_target_ctgs.nf'

// import modules
include { combine_res } from '../modules/local/parse.nf'
include { qc_report; annot_report; qc_report_watch; qc_report_asm_watch } from '../modules/local/report.nf'

// Define a process that emits the number of input items
process countInput {
    input:
    val input

    output:
    val itemCount

    script:
    inputSize=input.size()
    println "${inputSize}"
    """
    itemCount=${inputSize}
    """
}

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
                    
                    // monitor for assembly failures
                    // for each timepoint,
                    // exit codes are written to output directory 
                    tp_dir_path = params.out_dir+"/timepoints"
                    tp_dir = new File(tp_dir_path)
                    tp_dir.mkdir()
                    asm_status = tp_dir_path+"/*/*/*/assembly.{txt}"
                    ch_asm_status = Channel.watchPath(asm_status, 'create,modify')
                    | until { f -> 
                        // println "Got: ${f}"
                        file(f).readLines().contains("0")
                    }

                    // build qc report without asm
                    ch_asm_status.map {
                        // id = file(it).getParent().getBaseName()
                        tp = file(it).getParent().getParent().getParent().getBaseName()
                        tuple( tp )
                    }
                    | join(READ_QC.out.target_res.map { 
                        timestamp = it.getSimpleName().replaceAll('target_reads_aggregate_', '')
                        tuple( timestamp, it)
                    })
                    | join(READ_QC.out.kreport)
                    | qc_report_watch

                    // build qc report with asm
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
                    | qc_report_asm_watch

                } else {

                    qc_report(SEROTYPING.out, ASSEMBLY_QC.out.checkm_res, ASSEMBLY_QC.out.quast_res, READ_QC.out.target_res, READ_QC.out.kreport)

                }           
            }

        } else {

            // combine results into a master file
            combine_res(SEROTYPING.out, [], [])

        }

        
}