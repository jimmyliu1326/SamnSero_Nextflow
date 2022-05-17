// import modules
include { flye; dragonflye } from '../modules/local/nanopore-assembly.nf'
include { medaka; medaka_gpu } from '../modules/local/nanopore-polish.nf'

workflow ASSEMBLY {
    take: reads
    main:
        dragonflye(reads)
        if (params.gpu) {
            medaka_gpu(dragonflye.out.join(reads))
            assembly_out = medaka_gpu.out
        } else {
            medaka(dragonflye.out.join(reads))
            assembly_out = medaka.out
        }
        
    emit:
        assembly_out
}