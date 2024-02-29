process combine_res {
    tag "Generate master result file"
    label "process_low"
    publishDir "$params.out_dir", mode: "copy"

    input:
        path(sistr_res)
        path(checkm_res)
        path(quast_res)
    output:
        file("*.csv")
    script:
        def date = new Date()
        def timestamp = date.format("yyyyMMdd_HHmm")
        """
        samnsero_combine.R * > analysis_results_${timestamp}.csv
        sed -i 's/\$/,${workflow.manifest.name},${workflow.manifest.version}/g' analysis_results_${timestamp}.csv
        sed -i '1 s/,${workflow.manifest.name},${workflow.manifest.version}/,software,software_version/' analysis_results_${timestamp}.csv
            
        """
}