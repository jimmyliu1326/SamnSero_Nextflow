// import modules
include { metaflye; dragonflye } from '../modules/local/nanopore-assembly.nf'
include { medaka; medaka_gpu } from '../modules/local/nanopore-polish.nf'
include { shovill } from '../modules/local/illumina-assembly.nf'

workflow ASSEMBLY_nanopore {
    take: reads
    main:
        // define assembly opts for target wgs and metagenomics
        flye_opts=""
        
        // run assembly workflow
        if ( params.meta != 'off' ) {
            
            if( params.nanohq ) { flye_opts = flye_opts + " --nano-hq" }
            metaflye(reads, flye_opts)
            assembly_out = metaflye.out.fasta
            
        } else {
            
            if( params.nanohq ) { flye_opts = flye_opts + " --nanohq" }
            dragonflye(reads, flye_opts)
            assembly = dragonflye.out.fasta

            if (params.gpu) {

                assembly
                    | join(reads)
                    | medaka_gpu
                    | set { assembly_out }

            } else {
                
                assembly
                    | join(reads)
                    | medaka
                    | set { assembly_out }

            }

        }
               
    emit:
        assembly_out
}

workflow ASSEMBLY_illumina {
    take: reads
    main:
        // define assembly opts for target wgs and metagenomics
        shovill_opts=""
        if (params.meta != 'off') { shovill_opts = shovill_opts + "--opts '--meta'" }
        // run assembly workflow
        assembly_out = shovill(reads, shovill_opts)
        
    emit:
        assembly_out
}