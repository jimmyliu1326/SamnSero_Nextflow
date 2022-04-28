// import modules
include { checkm } from '../modules/local/checkm.nf'
include { quast; aggregate_quast } from '../modules/local/quast.nf'

workflow QC {
    take: assembly
    main:
        checkm(assembly.collect())
        quast(assembly)
        aggregate_quast(quast.out.collect())
    emit:
        checkm_res = checkm.out
        quast_res = aggregate_quast.out
}