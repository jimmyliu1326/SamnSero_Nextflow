// import subworkflow
include { ASSEMBLY_illumina } from '../subworkflow/genome_assembly.nf'
include { fastp } from '../modules/local/illumina-trim.nf'

// define nanopore workflow
workflow illumina {
    
    take: data

    main:
        
        // parse data 
        data
            | map { 
                id = it[0]
                path = file(it[1], checkIfExists: true).listFiles().toList()
                return tuple(id, path)
                }
            | set { data_pe }

        // trimming and assembly
        fastp_opts=""
        if ( !params.trim ) { fastp_opts = fastp_opts + "-A" }
            
        fastp(data_pe, fastp_opts)

        ASSEMBLY_illumina(fastp.out)
        
    emit:
        assembly = ASSEMBLY_illumina.out
        reads = fastp.out
}