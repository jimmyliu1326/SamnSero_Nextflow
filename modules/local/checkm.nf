// genetic risk factor prediction
process checkm {
    tag "Checking genome completness and contamination"
    label "process_medium"

    input:
        file(assemblies)
    output:
        file("checkm_summary.tsv")
    shell:
         """
        checkm taxonomy_wf --tab_table \
            -t ${task.cpus} \
            -x fasta \
            -f checkm_summary.tsv \
            genus Salmonella \
            . \
            .
        sed -i 's/^Bin Id/id/g' checkm_summary.tsv
        """
}