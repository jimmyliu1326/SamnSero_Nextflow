#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// basic processes for Nanopore workflows
process combine {
    tag "Combining Fastq files for ${sample_id}"
    label "process_low"

    input:
        tuple val(sample_id), path(reads)
    output:
        file("${sample_id}.{fastq,fastq.gz}")
    shell:
        """
        sample=\$(ls ${reads} | head -n 1)
        if [[ \${sample##*.} == "gz" ]]; then
            cat ${reads}/*.fastq.gz > ${sample_id}.fastq.gz
        else
            cat ${reads}/*.fastq > ${sample_id}.fastq
        fi
        """
}

process porechop {
    tag "Adaptor trimming on ${reads.baseName}"
    label "process_high"

    input:
        path(reads)
    output:
        file("${reads.baseName}_trimmed.fastq")
    shell:
        """
        porechop -t ${task.cpus} -i ${reads} -o ${reads.baseName}_trimmed.fastq
        """
}