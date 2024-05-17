// import modules
include { metaflye; dragonflye; flye } from '../modules/local/nanopore-assembly.nf'
include { medaka; medaka_gpu } from '../modules/local/nanopore-polish.nf'
include { shovill } from '../modules/local/illumina-assembly.nf'
include { rename_FASTA } from '../modules/local/rename_FASTA/rename_FASTA.nf'

workflow ASSEMBLY_nanopore {
    take: reads
    main:
        // define assembly opts for target wgs and metagenomics
        flye_opts=""

        // only perform assemblies on samples with >N reads
        asm_reads = reads.filter{ it[1].countFastq() >= params.min_tr }
        
        // run assembly workflow
        if ( params.meta != 'off' ) {
            
            if( params.nanohq ) { flye_opts = flye_opts + " --nano-hq" } else { flye_opts = flye_opts + " --nano-raw" }
            metaflye(asm_reads, flye_opts)
            assembly_out = metaflye.out.fasta
            
        } else {
            
            flye_opts = params.gsize ? flye_opts + " -g ${params.gsize} --asm-coverage ${params.asm_cov}" : flye_opts
            flye(asm_reads, flye_opts)
            
            if (!params.nopolish) {
                // split assemblies by contig count
                assembly = flye.out.fasta.branch { id, fasta ->
                    small: fasta.countFasta() <= 30
                    large: fasta.countFasta() > 30
                }
                // assembly.small.view { "$it is small" }
                // assembly.large.view { "$it is large" }
                // polish those with low contig count
                if (params.gpu) {

                    assembly.small
                        | join(asm_reads)
                        | medaka_gpu
                        | set { polished_asm }

                    } else {
                        
                        assembly.small
                            | join(asm_reads)
                            | medaka
                            | set { polished_asm }

                    }
                    // skip polishing for highly fragmented assemblies
                    rename_FASTA(assembly.large)
                    assembly_out = Channel.empty().mix(assembly.large, polished_asm)
                } else {
                    rename_FASTA(flye.out.fasta)
                    assembly_out = rename_FASTA.out
                }            
        }
               
    emit: assembly_out
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