// genetic risk factor prediction
process checkm {
    tag "Checking genome completness and contamination"
    label "process_medium"
    publishDir "$params.outdir"+"/qc/", mode: "copy"

    input:
        file(assemblies)
    output:
        file("checkm_res_aggregate.tsv")
    shell:
         """
        checkm taxonomy_wf --tab_table \
            -t ${task.cpus} \
            -x fasta \
            -f checkm_res_aggregate.tsv \
            species "${params.species}" \
            . \
            .
        sed -i 's/^Bin Id/id/g' checkm_res_aggregate.tsv
        """
}