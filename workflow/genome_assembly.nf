// import modules
include { flye } from '../modules/local/nanopore-assembly.nf'
include { medaka } from '../modules/local/nanopore-polish.nf'

workflow ASSEMBLY {
    take: reads
    main:
        flye(reads)
        medaka(reads, flye.out)
    emit:
        medaka.out
}