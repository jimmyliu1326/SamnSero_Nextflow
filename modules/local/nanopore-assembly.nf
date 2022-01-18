#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// assembly methods for Nanopore workflows
process flye {
    tag "Flye assembly on ${sample_id}"
    label "process_med"

    input:
        tuple val(sample_id), path(reads)
    output:
        tuple val(sample_id), file("flye/assembly.fasta")
    shell:
        """
        flye --nano-raw ${reads} -t ${task.cpus} -i 2 -g 4.8m --out-dir flye
        """
}