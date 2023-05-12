// post-assembly polishing for Nanopore workflows
process medaka {
    tag "Assembly polishing for ${sample_id}"
    label "process_medium"
    publishDir "$params.outdir"+"/assembly", mode: "copy"

    input:
        tuple val(sample_id), path(assembly), path(reads)
    output:
        tuple val(sample_id), file("${sample_id}.fasta")
    shell:
        """
        medaka_consensus -i ${reads} -d ${assembly} -o . -t ${task.cpus}
        mv consensus.fasta ${sample_id}.fasta
        """
}

process medaka_gpu {
    tag "Assembly polishing for ${sample_id}"
    label "process_medium"
    maxForks 1
    publishDir "$params.outdir"+"/assembly", mode: "copy"

    input:
        tuple val(sample_id), path(assembly), path(reads)
    output:
        tuple val(sample_id), file("${sample_id}.fasta")
    shell:
        """
        medaka_consensus -i ${reads} -d ${assembly} -o . -t ${task.cpus} -b ${params.medaka_batchsize}
        mv consensus.fasta ${sample_id}.fasta
        """
}