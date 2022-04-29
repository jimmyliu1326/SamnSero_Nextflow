// in-silico serotyping using SISTR
process qc_report {
    tag "Generating QC Report"
    label "process_low"
    publishDir "reports/", mode: "copy"

    input:
        path(sistr_res)
        path(checkm_res)
        path(quast_res)
    output:
        file("qc_report.html")
    shell:
        """
        cp /src/* .
        Rscript -e 'rmarkdown::render("qc_report.Rmd")' ${checkm_res} ${quast_res}  ${sistr_res}
        """   
}

process annot_report {
    tag "Generating Genome Annotation Report"
    label "process_low"
    publishDir "reports/", mode: "copy"

    input:
        path(sistr_res)
        path(annot_res)
    output:
        file("annot_report.html")
    shell:
        """
        cp /src/* .
        Rscript -e 'rmarkdown::render("annot_report.Rmd")' ${sistr_res} .
        """
}