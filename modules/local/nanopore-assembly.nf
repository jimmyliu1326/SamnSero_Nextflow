#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// assembly methods for Nanopore workflows
process flye {
    tag "Flye assembly on ${reads.baseName}"
    label "process_med"

    input:
        path(reads)
    output:
        file("flye/${reads.baseName}.fasta")
    shell:
        """
        flye --nano-raw ${reads} -t ${task.cpus} -i 2 -g 4.8m --out-dir flye
        mv flye/assembly.fasta flye/${reads.baseName}.fasta
        """
}