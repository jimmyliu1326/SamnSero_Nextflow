// import modules
include { flye; dragonflye } from '../modules/local/nanopore-assembly.nf'
include { medaka; medaka_gpu } from '../modules/local/nanopore-polish.nf'
include { shovill } from '../modules/local/illumina-assembly.nf'

workflow ASSEMBLY_nanopore {
    take: reads
    main:
        // define assembly opts for target wgs and metagenomics
        flye_opts=""
        if (params.meta) { flye_opts = flye_opts + "--depth 0 --opts '--meta'" }
        if( params.nanohq ) { flye_opts = flye_opts + " --nanohq" }
        
        // run assembly workflow
        dragonflye(reads, flye_opts)
        
        if (params.gpu) {

            dragonflye.out.fasta \
                | join(reads) \
                | medaka_gpu

            assembly_out = medaka_gpu.out

        } else {
            
            dragonflye.out.fasta \
                | join(reads) \
                | medaka

            assembly_out = medaka.out
        }
        
    emit:
        assembly_out
}

workflow ASSEMBLY_illumina {
    take: reads

    main:
        // define assembly opts for target wgs and metagenomics
        shovill_opts=""
        if (params.meta) { shovill_opts = shovill_opts + "--opts '--meta'" }
        
        // run assembly workflow
        assembly_out = shovill(reads, shovill_opts)
        
    emit:
        assembly_out
}