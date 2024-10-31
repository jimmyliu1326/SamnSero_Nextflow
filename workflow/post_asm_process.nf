// import workflows
include { SEROTYPING } from '../subworkflow/serotyping.nf'
include { ANNOT } from '../subworkflow/genome_annotation.nf'
include { ASSEMBLY_QC; READ_QC } from '../subworkflow/sequence_qc.nf'
include { MG_BIN } from '../subworkflow/metagenome_binning.nf'
include { XTRACT_TARGET_CTGS } from '../subworkflow/xtract_target_ctgs.nf'

// import modules
include { combine_res } from '../modules/local/parse.nf'
include { qc_report; annot_report; report_res_aggregate; qc_report_watch } from '../modules/local/report.nf'
include { nanocomp_dir } from '../modules/local/nanopore-base.nf'

workflow post_asm_process {

    take: ch_assembly // Path: assembly path
          reads       // Path: filtered raw read path
          taxid       // String: NCBI Taxonomy ID
          asm_only    // Boolean: whether input only contains genome assemblies

    main:
        
        // perform metagenomic binning
        // if ( params.meta != 'off' ) { 
            
            // if ( !params.watchdir) { // currently do not support contig binning in real-time

            // if ( !params.disable_binning ) { // bin contigs
                
            //     MG_BIN(ch_assembly, reads)
                
            //     if ( params.meta == 'targeted' ) {
                    
            //         assembly = MG_BIN.out.target_bins

            //     } else {

            //         assembly = MG_BIN.out.bins

            //     }

            // } else { // run if binning is disabled

                

            // }

        // } else {

        //     assembly = ch_assembly

        // }

        // For targeted metagenomics mode, extract
        // target contigs for downstream typing and annotation
        assembly = ch_assembly

        if ( params.meta == "targeted" ) {
            assembly = XTRACT_TARGET_CTGS(ch_assembly, reads, taxid)
                .filter { id, asm -> 
                    asm.countFasta() >= 1
                }
        }

        // in silico serotyping
        SEROTYPING(assembly)

        // genome annotation
        if ( params.annot  ) { 
            
            if ( !params.watchdir) { // currently do not support genome annotation in real-time
                ANNOT(assembly)
            
                if ( !params.noreport) {

                    annot_report(SEROTYPING.out, ANNOT.out)
                
                }
            }

        }

        // run sequence QC
        if ( params.qc ) { 
                
            if (!asm_only) { READ_QC(reads, taxid) }
            ASSEMBLY_QC(assembly, reads)

            if ( !params.noreport ) {
                
                if ( params.watchdir ) {
                    

                    // report_res = Channel.empty()
                    //     .mix(READ_QC.out.target_res, ASSEMBLY_QC.out.checkm_res, ASSEMBLY_QC.out.quast_res, READ_QC.out.kreport.map{ it[1] }, SEROTYPING.out)
                    // report_res_cum = report_res_aggregate.scan(report_res)

                    report_data_path = params.out_dir+"/report_data"
                    report_data_dir = new File(report_data_path)
                    report_data_dir.mkdir()
                    report_data_files = report_data_path+"/**/*.{tsv,csv,fastq.gz}"
                    report_data = Channel.watchPath(report_data_files, 'create,modify')
                    report_data
                        | branch {
                            qc: it.getExtension() =~ 'sv'
                            fastq: it.getExtension() =~ 'gz'
                        }
                        | set { ch_report_data }
                    
                    ch_report_data.qc
                        | map { f -> 
                            // println "Got: ${f}"
                            f.getParent().getParent()
                        }
                        | qc_report_watch
                    
                    ch_report_data.fastq
                        | map { f -> 
                            // println "Got: ${f}"
                            f.getParent()
                        }
                        | combine(Channel.fromPath(workflow.workDir))
                        | nanocomp_dir

                    // monitor for assembly failures
                    // for each timepoint,
                    // exit codes are written to output directory 
                    // tp_dir_path = params.out_dir+"/timepoints"
                    // tp_dir = new File(tp_dir_path)
                    // tp_dir.mkdir()
                    // asm_status = tp_dir_path+"/*/*/*/assembly.{txt}"
                    // ch_asm_status = Channel.watchPath(asm_status, 'create,modify')
                    // | until { f -> 
                    //     // println "Got: ${f}"
                    //     file(f).readLines().contains("0")
                    // }

                    // // build qc report without asm
                    // ch_asm_status.map {
                    //     // id = file(it).getParent().getBaseName()
                    //     tp = file(it).getParent().getParent().getParent().getBaseName()
                    //     tuple( tp )
                    // }
                    // | join(READ_QC.out.target_res.map { 
                    //     timestamp = it.getSimpleName().replaceAll('target_reads_aggregate_', '')
                    //     tuple( timestamp, it)
                    // })
                    // | join(READ_QC.out.kreport)
                    // | qc_report_watch

                    // build qc report with asm
                    // SEROTYPING.out.map { 
                    //     timestamp = it.getSimpleName().replaceAll('sistr_res_aggregate_', '')
                    //     tuple( timestamp, it)
                    // }
                    // | join(ASSEMBLY_QC.out.checkm_res.map { 
                    //     timestamp = it.getSimpleName().replaceAll('checkm_res_aggregate_', '')
                    //     tuple( timestamp, it)
                    // })
                    // | join(ASSEMBLY_QC.out.quast_res.map { 
                    //     timestamp = it.getSimpleName().replaceAll('quast_res_aggregate_', '')
                    //     tuple( timestamp, it)
                    // })
                    // | join(READ_QC.out.target_res.map { 
                    //     timestamp = it.getSimpleName().replaceAll('target_reads_aggregate_', '')
                    //     tuple( timestamp, it)
                    // })
                    // | join(READ_QC.out.kreport)
                    // | qc_report_asm_watch

                } else {

                    if (!asm_only) {
                        qc_report(SEROTYPING.out, ASSEMBLY_QC.out.checkm_res, ASSEMBLY_QC.out.quast_res, READ_QC.out.target_res, READ_QC.out.kreport)
                    }    
                    
                }           
            }

            combine_res(
                SEROTYPING.out,
                ASSEMBLY_QC.out.checkm_res,
                ASSEMBLY_QC.out.quast_res
            )

        } else {

            // combine results into a master file
            combine_res(SEROTYPING.out, [], [])

        }

        
}