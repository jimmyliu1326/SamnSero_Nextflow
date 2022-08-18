// import modules
include { flye; dragonflye } from '../modules/local/nanopore-assembly.nf'
include { medaka; medaka_gpu } from '../modules/local/nanopore-polish.nf'

workflow ASSEMBLY {
    take: reads
    main:
        // define assembly opts for target wgs and metagenomics
        flye_opts=""
        if (params.meta) { flye_opts = flye_opts + "--depth 0 --opts '--meta'" }
        if( params.nanohq ) { flye_opts = flye_opts + " --nanohq" }
        
        // run assembly workflow
        dragonflye(reads, flye_opts)
        
        if (params.gpu) {

            dragonflye.out \
                | join(reads) \
                | medaka_gpu

            assembly_out = medaka_gpu.out

        } else {
            
            dragonflye.out \
                | join(reads) \
                | medaka

            assembly_out = medaka.out
        }
        
    emit:
        assembly_out
}