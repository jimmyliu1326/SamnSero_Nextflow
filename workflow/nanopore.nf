// import modules
include { porechop; combine; nanoq } from '../modules/local/nanopore-base.nf'

// import subworkflow
include { ASSEMBLY_nanopore } from '../subworkflow/genome_assembly.nf'

// define nanopore workflow
workflow nanopore {
    
    take: data

    main:
        
        // analysis start
        combine(data)

        // trimming and assembly
        if ( params.trim ) { 
            
            reads = porechop(combine.out)

        } else {
            
            reads = combine.out           

        }

        nanoq(reads)

        ASSEMBLY_nanopore(nanoq.out)
        
    emit:
        assembly = ASSEMBLY_nanopore.out
        reads = nanoq.out
}