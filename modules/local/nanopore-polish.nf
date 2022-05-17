// post-assembly polishing for Nanopore workflows
process medaka {
    tag "Assembly polishing for ${reads.simpleName}"
    label "process_medium"
    publishDir "$params.outdir"+"/assembly", mode: "copy"

    input:
        tuple val(sample_id), path(assembly), path(reads)
    output:
        tuple val(sample_id), file("${reads.simpleName}.fasta")
    shell:
        """
        medaka_consensus -i ${reads} -d ${assembly} -o . -t ${task.cpus}
        mv consensus.fasta ${reads.simpleName}.fasta
        """
}

process medaka_gpu {
    tag "Assembly polishing for ${reads.simpleName}"
    label "process_medium"
    maxForks 1
    publishDir "$params.outdir"+"/assembly", mode: "copy"

    input:
        tuple val(sample_id), path(assembly), path(reads)
    output:
        tuple val(sample_id), file("${reads.simpleName}.fasta")
    shell:
        """
        medaka_consensus -i ${reads} -d ${assembly} -o . -t ${task.cpus}
        mv consensus.fasta ${reads.simpleName}.fasta
        """
}