// in-silico serotyping using SISTR
process sistr {
    tag "SISTR serotyping for ${assembly.baseName}"
    label "process_low"

    input:
        tuple val(sample_id), path(assembly)
    output:
        tuple val(sample_id), file("${assembly.simpleName}.csv")
    shell:
        """
        sistr -i ${assembly} ${assembly.simpleName} -o ${assembly.simpleName}.csv -t ${task.cpus} -f csv --qc
        """   
}

process aggregate_sistr {
    tag "Aggregating serotyping results"
    label "process_low"

    input:
        path(sistr_res)
    output:
        file("sistr_res_aggregate.csv")
    shell:
        """
        awk 'NR == 1 || FNR > 1' *.csv > sistr_res_aggregate.csv
        sed -i 's/,genome,/,id,/g' sistr_res_aggregate.csv
        """
}