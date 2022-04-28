// in-silico serotyping using SISTR
process combine_res {
    tag "Generate master result file"
    label "process_low"
    publishDir "$params.outdir", mode: "copy"

    input:
        path(results)
    output:
        file("analysis_results.csv")
    shell:
        """
        cat * > analysis_results.csv
        """   
}