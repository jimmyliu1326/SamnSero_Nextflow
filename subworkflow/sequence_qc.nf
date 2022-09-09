// import modules
include { checkm } from '../modules/local/checkm.nf'
include { quast; aggregate_quast } from '../modules/local/quast.nf'
include { fastqc; multiqc } from '../modules/local/fastqc.nf'
include { nanocomp } from '../modules/local/nanopore-base.nf'

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

workflow READ_QC {
    take: reads
    main:
        centrifuge_db=file(params.centrifuge, checkIfExists: true)

        centrifuge(reads, centrifuge_db)

        if ( !params.noreport ) {
            
            centrifuge.out.krona \
                | collect \
                | krona
                
        }

        // run fastqc and multiqc
        if (params.seq_platform == "illumina" ) {
            fastqc(reads)
            read_qc = multiqc(fastqc.out.collect())
        } else {
            read_qc = nanocomp(reads.map{ it[1] }.collect())
        }
        
        
    emit:
        kreport = centrifuge.out.kreport
        read_qc = read_qc
}