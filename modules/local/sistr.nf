// in-silico serotyping using SISTR
process sistr {
    tag "SISTR Serotyping for ${assembly.baseName}"
    label "process_low"

    input:
        path(assembly)
    output:
        file("${assembly.simpleName}.csv")
    shell:
        """
        sistr -i ${assembly} ${assembly.simpleName} -o ${assembly.simpleName}.csv -t ${task.cpus} -f csv --qc
        """   
}

process aggregate_sistr {
    tag "Aggregating QUAST results"
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