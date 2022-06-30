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
include { centrifuge; krona } from '../modules/local/nanopore-taxonomy.nf'

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
        
    emit:
        kreport = centrifuge.out.kreport
}