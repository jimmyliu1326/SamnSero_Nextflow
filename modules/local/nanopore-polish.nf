// post-assembly polishing for Nanopore workflows
process medaka {
    tag "Assembly polishing for ${sample_id}"
    label "process_medium"

    input:
        tuple val(sample_id), path(assembly), path(reads)
    output:
        tuple val(sample_id), file("${sample_id}.fasta")
    script:
        def args = task.ext.args ?: ''
        """
        medaka_consensus -i ${reads} -d ${assembly} -o . -t ${task.cpus} ${args}
        mv consensus.fasta ${sample_id}.fasta
        """
}

process medaka_gpu {
    tag "GPU-accelerated Assembly polishing for ${sample_id}"
    label "process_medium"
    // maxForks 1

    input:
        tuple val(sample_id), path(assembly), path(reads)
    output:
        tuple val(sample_id), file("${sample_id}.fasta")
    script:
        def args = task.ext.args ?: ''
        """
        medaka_consensus -i ${reads} -d ${assembly} -o . -t ${task.cpus} -b ${params.medaka_batchsize} ${args}
        mv consensus.fasta ${sample_id}.fasta
        """
}