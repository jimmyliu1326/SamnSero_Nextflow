// import modules
include { medaka } from '../modules/local/nanopore-polish.nf'
include { sistr; aggregate_sistr } from '../modules/local/sistr.nf'

workflow SEROTYPING {
    take: assembly
    main:
        sistr(assembly)
        aggregate_sistr(sistr.out.collect().map { it[1] })
    emit:
        aggregate_sistr.out
}