process combine_res {
    tag "Generate master result file"
    label "process_low"
    publishDir "$params.outdir", mode: "copy"

    input:
        path(sistr_res)
        path(checkm_res)
        path(quast_res)
    output:
        file("analysis_results.csv")
    shell:
        """
        samnsero_combine.R * > analysis_results.csv
        """
}