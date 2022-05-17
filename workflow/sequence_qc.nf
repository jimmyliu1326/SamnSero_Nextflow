// import modules
include { checkm } from '../modules/local/checkm.nf'
include { quast; aggregate_quast } from '../modules/local/quast.nf'

workflow ASSEMBLY_QC {
    take: 
        assembly
        reads
    main:
        checkm(assembly.collect())
        quast(assembly.join(reads))
        aggregate_quast(quast.out.collect())
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
        krona(centrifuge.out.krona.collect())
    emit:
        centrifuge_res = centrifuge.out.kreport
}