// import modules
include { checkm; checkm_single; aggregate_checkm_watch; aggregate_checkm } from '../modules/local/checkm.nf'
include { quast; aggregate_quast; aggregate_quast_watch } from '../modules/local/quast.nf'

workflow ASSEMBLY_QC {
    take: 
        assembly
        reads
    main:
        // CheckM
        if ( params.watchdir ) {

            assembly
                | checkm_single
                | map { it[1] }
                | set { checkm_res }

            aggregate_checkm_watch.scan(checkm_res)
                | set { aggregate_checkm }

        } else {

            assembly 
                | checkm_single
                | map { it[1] }
                | collect
                | aggregate_checkm
                | set { aggregate_checkm }

        }        


        // QUAST
        if ( params.meta != 'meta' ) {
            assembly
                | map { bin_id, path ->
                    id = bin_id.replaceAll("_BIN_.*", "")
                    tuple (id, bin_id, path)
                }
                | join(reads)
                | map { tuple(it[1], it[2], it[3]) }
                | set { quast_input }
        } else {
            assembly
                | join(reads)
                | set { quast_input }
        }
        
        quast(quast_input)

        if ( params.watchdir ) {

            quast.out
                | map { it[1] }
                | set { quast_res }
            aggregate_quast_watch.scan(quast_res)
                | set { aggregate_quast }

        } else {
            
            quast.out
                | map { it[1] }
                | collect
                | aggregate_quast
                | set { aggregate_quast }

        }
        

    emit:
        checkm_res = aggregate_checkm
        quast_res = aggregate_quast
}

// import modules
include { centrifuge; krona; aggregate_krona_watch; aggregate_kreport_watch; aggregate_krona_split; aggregate_kreport_split } from '../modules/local/taxonomy_class.nf'
include { target_reads_xtract } from '../modules/local/target_reads/xtract.nf'
include { target_reads_aggregate; target_reads_aggregate_watch } from '../modules/local/target_reads/aggregate.nf'
include { seqkit_fx2tab } from '../modules/local/seqkit/fx2tab.nf'
include { fastqc; multiqc } from '../modules/local/fastqc.nf'
include { nanocomp } from '../modules/local/nanopore-base.nf'

workflow READ_QC {
    take: 
        reads
        taxid
    main:
        centrifuge_db=file(params.centrifuge, checkIfExists: true)
        centrifuge(reads, centrifuge_db)
        

        if ( params.watchdir ) {
            
            aggregate_kreport_watch.scan(centrifuge.out.kreport.map{ it[1] })
            aggregate_kreport_split(aggregate_kreport_watch.out)
            kreport = aggregate_kreport_split.out.kreport

            // create Krona report
            aggregate_krona_watch.scan(centrifuge.out.krona.map{ it[1] })
                | aggregate_krona_split
                | krona

            // calculate target bases sequenced
            target_stats = centrifuge.out.krona
                | combine(taxid)
                | join(reads)
                | target_reads_xtract
                | seqkit_fx2tab
                | map { it[1] }
            target_res = target_reads_aggregate_watch.scan(target_stats)

        } else {

            kreport = centrifuge.out.kreport.map{ it[1] }.collect() // collect all centrifuge reports into a list

            if ( !params.noreport ) {
            
                // create Krona report
                centrifuge.out.krona 
                    | collect
                    | map { it[1] }
                    | krona
                
            }

            // calculate target bases sequenced
            centrifuge.out.krona
                | combine(taxid)
                | join(reads)
                | target_reads_xtract
                | seqkit_fx2tab
                | map { it[1] }
                | collect
                | target_reads_aggregate
                | set { target_res }
            
            // run fastqc and multiqc
            if (params.seq_platform == "illumina" ) {
                fastqc(reads)
                read_qc_report = multiqc(fastqc.out.collect())
            } else {
                read_qc_report = nanocomp(reads.map{ it[1] }.collect())
            }

        }
        
        
    emit:
        kreport = kreport
        target_res = target_res
}