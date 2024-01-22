// in-silico serotyping using SISTR
process qc_report {
    tag "Generating QC Report"
    label "process_low"
    publishDir "$params.out_dir"+"/reports/", mode: "copy"
    errorStrategy 'ignore'

    input:
        path(sistr_res)
        path(checkm_res)
        path(quast_res)
        path(target_res)
        path(kreport)
    output:
        file("qc_report.html")
    shell:
        """
        mkdir kreport && mv *.kraken.report kreport/

        Rscript -e 'rmarkdown::render("/R/qc_report.Rmd", output_dir=getwd(), knit_root_dir=getwd())' ${checkm_res} ${quast_res} ${sistr_res} ${target_res} kreport/
        """   
}

process annot_report {
    tag "Generating Genome Annotation Report"
    label "process_low"
    publishDir "$params.out_dir"+"/reports/", mode: "copy"
    errorStrategy 'ignore'

    input:
        path(sistr_res)
        path(annot_res)
    output:
        file("annot_report.html")
    shell:
        """
        mkdir -p annotations/results/ annotations/summary/

        for x in vfdb mob_suite rgi; do
            if test -f \${x}_summary.tsv; then mv \${x}_summary.tsv annotations/summary; fi
            if test -f \${x}_res_aggregate.tsv; then mv \${x}_res_aggregate.tsv annotations/results; fi
        done

        Rscript -e 'rmarkdown::render("/R/annot_report.Rmd", output_dir=getwd(), knit_root_dir=getwd())' ${sistr_res} annotations
        """
}

// in-silico serotyping using SISTR
process qc_report_watch {
    tag "Generating QC Report"
    label "process_low"
    publishDir "$params.out_dir", mode: "copy"

    input:
        tuple val(timestamp), path(sistr_res), path(checkm_res), path(quast_res), path(target_res), path(kreport)
    output:
        file("qc_report.html")
    shell:
        """
        mkdir kreport && mv *.kraken.report kreport/

        Rscript -e 'rmarkdown::render("/R/qc_report.Rmd", output_dir=getwd(), knit_root_dir=getwd())' ${checkm_res} ${quast_res} ${sistr_res} ${target_res} kreport/
        """   
}
