// import modules
include { porechop; combine; nanoq; combine_watch } from '../modules/local/nanopore-base.nf'
include { rename_FASTQ } from '../modules/local/rename_FASTQ/rename_FASTQ.nf'
include { seqkit_split } from '../modules/local/seqkit/split.nf'

// import subworkflow
include { ASSEMBLY_nanopore } from '../subworkflow/genome_assembly.nf'

// define nanopore workflow
workflow nanopore {
    
    take: data

    main:
        
        // combine reads
        if ( params.watchdir ) {
            
            combine_watch.scan(data)
                | seqkit_split
                | flatten
                | map { file ->
                    // id = file.getName().replaceAll('.*\\d+\\.part_', '').replaceAll('.fastq.gz', '')
                    id = file.getName().replaceAll('\\.part_', '_TIME_').replaceAll('.fastq.gz', '')
                    tuple(id, file)
                }
                | rename_FASTQ
                | set { combined_reads }

        } else {

            combine(data)
                | set { combined_reads }

        }
        

        // trimming and assembly
        if ( params.trim ) { 
            
            reads = porechop(combined_reads)

        } else {
            
            reads = combined_reads

        }

        nanoq(reads)
        ASSEMBLY_nanopore(nanoq.out)
        
    emit:
        assembly = ASSEMBLY_nanopore.out
        reads = nanoq.out
}