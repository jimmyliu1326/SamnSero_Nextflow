process shovill {
    tag "Shovill assembly on ${sample_id}"
    label "process_medium"
    publishDir "$params.out_dir"+"/assembly/", mode: "copy"
    errorStrategy 'ignore'

    input:
        tuple val(sample_id), path(reads)
        val(opts)
    output:
        tuple val(sample_id), path("${sample_id}.fasta")
    shell:
        """
        shovill --R1 ${reads[0]} \
            --R2 ${reads[1]} \
            --cpus ${task.cpus} \
            --out_dir shovill \
            --ram ${task.memory.toGiga()} \
            ${opts} 
        mv shovill/contigs.fa ${sample_id}.fasta
        """
}