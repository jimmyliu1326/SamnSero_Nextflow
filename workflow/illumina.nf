// import subworkflow
include { ASSEMBLY_illumina } from '../subworkflow/genome_assembly.nf'
include { fastp } from '../modules/local/illumina-trim.nf'

// define nanopore workflow
workflow illumina {
    
    take: data

    main:
        
        // parse data
        // get fastq dir column from input csv
        fq_dirs = data.map{ file(it[1]) }

        // create a tuple of R1/R2 fastq files grouped by sample ID
        fq_dirs.flatMap{ 
            file = file(it, checkIfExists: true)
                .listFiles()
            }
            .filter{ it.name =~ /.fastq*/ }
            .map{ tuple file(it.getParent()), it}
            .groupTuple()
            // join the tuples by FASTQ directories
            .join(data.map{ tuple file(it[1]), it[0] }, by: 0)
            .map{ tuple it[2], it[1] }
            .set { data_pe }
        

        // trimming and assembly
        fastp_opts=""
        if ( !params.trim ) { fastp_opts = fastp_opts + "-A" }
            
        fastp(data_pe, fastp_opts)

        ASSEMBLY_illumina(fastp.out)
        
    emit:
        assembly = ASSEMBLY_illumina.out
        reads = fastp.out
}