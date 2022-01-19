#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// post-assembly polishing for Nanopore workflows
process medaka {
    tag "Assembly polishing for ${reads.baseName}"
    label "process_med"
    publishDir "$params.outdir", mode: "copy"

    input:
        path(reads)
        path(assembly)
    output:
        file("assembly/${reads.baseName}.fasta")
    shell:
        """
        medaka_consensus -i ${reads} -d ${assembly} -o assembly -t ${task.cpus}
        mv assembly/consensus.fasta assembly/${reads.baseName}.fasta
        """
}