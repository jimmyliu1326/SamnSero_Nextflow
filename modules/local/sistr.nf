#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// in-silico serotyping using SISTR
process sistr {
    tag "SISTR Serotyping for ${sample_id}"
    label "process_low"
    publishDir "$params.outdir"+"/sistr_res"

    input:
        tuple val(sample_id), path(assembly)
    output:
        tuple val(sample_id), file("${sample}.csv")
    shell:
        """
        sistr -i ${assembly} ${sample_id} -o ${sample}.csv -t ${task.cpus} -f csv --qc
        """   
}

process aggregate_sistr {
    tag "Aggregating SISTR results"
    label "process_low"
    publishDir "$params.outdir"

    input:
        path("*")
    output:
        "sistr_res_aggregate.tsv"
    shell:
        """
        awk 'NR == 1 || FNR > 1' *.csv > sistr_res_aggregate.csv
        """
}