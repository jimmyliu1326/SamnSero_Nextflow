// import modules
include { flye; dragonflye } from '../modules/local/nanopore-assembly.nf'
include { medaka } from '../modules/local/nanopore-polish.nf'

workflow ASSEMBLY {
    take: reads
    main:
        dragonflye(reads)
        medaka(reads, dragonflye.out)
    emit:
        medaka.out
}