// post-assembly polishing for Nanopore workflows
process medaka {
    tag "Assembly polishing for ${sample_id}"
    label "process_medium"
    publishDir "${params.out_dir}/assembly/${sample_id}", mode: "copy"

    input:
        tuple val(sample_id), path(assembly), path(reads)
    output:
        tuple val(sample_id), file("${sample_id}.fasta")
    script:
        def timestamp = sample_id.replaceAll('_TIME_.*', '')
        def id = sample_id.replaceAll('.*_TIME_', '')
        """
        medaka_consensus -i ${reads} -d ${assembly} -o . -t ${task.cpus}
        mv consensus.fasta ${sample_id}.fasta
        """
}

process medaka_gpu {
    tag "GPU-accelerated Assembly polishing for ${sample_id}"
    label "process_medium"
    maxForks 1
    publishDir "${params.out_dir}/assembly/${sample_id}", mode: "copy"

    input:
        tuple val(sample_id), path(assembly), path(reads)
    output:
        tuple val(sample_id), file("${sample_id}.fasta")
    script:
        def timestamp = sample_id.replaceAll('_TIME_.*', '')
        def id = sample_id.replaceAll('.*_TIME_', '')
        """
        medaka_consensus -i ${reads} -d ${assembly} -o . -t ${task.cpus} -b ${params.medaka_batchsize}
        mv consensus.fasta ${sample_id}.fasta
        """
}