// genetic risk factor prediction
process quast {
    tag "Computing assembly statistics for ${assembly.baseName}"
    label "process_low"

    input:
        path(assembly)
    output:
        file("${assembly.baseName}.tsv")
    shell:
        """
        quast.py --fast -o . -t ${task.cpus} ${assembly}
        mv transposed_report.tsv ${assembly.baseName}.tsv
        """   
}

process aggregate_quast {
    tag "Aggregating QUAST results"
    label "process_low"

    input:
        path(quast_res)
    output:
        file("quast_res_aggregate.tsv")
    shell:
        """
        awk 'NR == 1 || FNR > 1' *.tsv > quast_res_aggregate.tsv
        sed -i 's/^Assembly/id/g' quast_res_aggregate.tsv
        """
}