#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// post-assembly polishing for Nanopore workflows
process medaka {
    tag "Assembly polishing for ${sample_id}"
    label "process_med"
    publishDir "$params.outdir/${sample_id}"

    input:
        tuple val(sample_id), path(reads)
        tuple val(sample_id), path(assembly)
    output:
        tuple val(sample_id), file("assembly/consensus.fa")
    shell:
        """
        medaka_consensus -i ${reads} -d ${assembly} -o assembly -t {task.cpus}
        """
}