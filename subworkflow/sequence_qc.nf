// import modules
include { checkm } from '../modules/local/checkm.nf'
include { quast; aggregate_quast } from '../modules/local/quast.nf'

workflow ASSEMBLY_QC {
    take: 
        assembly
        reads
    main:
        assembly \
            | map { it[1] } \
            | collect \
            | checkm

        assembly \
            | join(reads) \
            | quast

        quast.out \
            | map { it[1] } \
            | collect \
            | aggregate_quast

    emit:
        checkm_res = checkm.out
        quast_res = aggregate_quast.out
}

// import modules
include { centrifuge; krona } from '../modules/local/taxonomy_class.nf'
include { taxonkit_name2taxid } from '../modules/local/taxonkit/name2taxid.nf'
include { target_reads_xtract } from '../modules/local/target_reads/xtract.nf'
include { target_reads_aggregate } from '../modules/local/target_reads/aggregate.nf'
include { seqkit_fx2tab } from '../modules/local/seqkit/fx2tab.nf'
include { fastqc; multiqc } from '../modules/local/fastqc.nf'
include { nanocomp } from '../modules/local/nanopore-base.nf'

workflow READ_QC {
    take: reads
    main:
        centrifuge_db=file(params.centrifuge, checkIfExists: true)

        centrifuge(reads, centrifuge_db)

        if ( !params.noreport ) {
            
            centrifuge.out.krona 
                | collect
                | map { it[1] }
                | krona
                
        }

        // calculate target bases sequenced
        taxon_id = taxonkit_name2taxid(params.taxon_name)

        centrifuge.out.krona
            | combine(taxon_id)
            | join(reads)
            | target_reads_xtract
            | seqkit_fx2tab
            | map { it[1] }
            | collect
            | target_reads_aggregate
            
        // run fastqc and multiqc
        if (params.seq_platform == "illumina" ) {
            fastqc(reads)
            read_qc_report = multiqc(fastqc.out.collect())
        } else {
            read_qc_report = nanocomp(reads.map{ it[1] }.collect())
        }
        
        
    emit:
        kreport = centrifuge.out.kreport.map{ it[1] }
        target_res = target_reads_aggregate.out
}