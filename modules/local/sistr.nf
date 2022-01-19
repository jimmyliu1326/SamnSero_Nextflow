#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// in-silico serotyping using SISTR
process sistr {
    tag "SISTR Serotyping for ${assembly.baseName}"
    label "process_low"
    publishDir "$params.outdir"+"/sistr_res", mode: "copy"

    input:
        path(assembly)
    output:
        file("${assembly.baseName}.csv")
    shell:
        """
        sistr -i ${assembly} ${assembly.baseName} -o ${assembly.baseName}.csv -t ${task.cpus} -f csv --qc
        """   
}

process aggregate_sistr {
    tag "Aggregating SISTR results"
    label "process_low"
    publishDir "$params.outdir", mode: "copy"

    input:
        path(sistr_res)
    output:
        file("sistr_res_aggregate.csv")
    shell:
        """
        awk 'NR == 1 || FNR > 1' ${sistr_res.join(" ")} > sistr_res_aggregate.csv
        """
}