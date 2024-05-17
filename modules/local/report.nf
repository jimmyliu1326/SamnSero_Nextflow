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
        Rscript -e 'rmarkdown::render("/R/qc_report.Rmd", output_dir=getwd(), knit_root_dir=getwd(), params=list(checkm="${checkm_res}", quast="${quast_res}", typing="${sistr_res}", kreport="kreport", target="${target_res}"))'
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

process qc_report_watch {
    tag "Generating QC Report"
    label "process_low"
    publishDir "$params.out_dir", mode: "copy"
    maxForks 1
    errorStrategy 'ignore'

    input:
        path(dir_l)
    output:
        file("qc_report.html")
    script:
        def latest = dir_l.first()
        """
        # mkdir -p ${latest}/kreport
        # ids=\$(find -L \$PWD/${latest} -maxdepth 1 -type f -name '*.kraken.report' | sed 's/.*_TIME_//g' | sed 's/.kraken.report//g' | sort -u)
        # for i in in \$ids; do f=\$(find -L \$PWD/${latest} -maxdepth 1 -type f -name "*\${i}.kraken.report" | sort -r | head -n1); ln -s \$f ${latest}/kreport/\$(basename \$f); done
        # cp \$(find -L \$PWD/${latest} -maxdepth 1 -type f -name '*.kraken.report') ${latest}/kreport
        export target_res="\$(find -L ${dir_l}/target -maxdepth 1 -name 'target_reads_aggregate_*' | sort -r | head -n1)"
        if test -z \$target_res; then export target_res=NULL; fi
        export sistr_res="\$(find -L \$PWD/${dir_l}/sistr -maxdepth 1 -name 'sistr_res_aggregate_*' | sort -r | head -n1)"
        if test -z \$sistr_res; then export sistr_res=NULL; fi
        export checkm_res="\$(find -L \$PWD/${dir_l}/checkm -maxdepth 1 -name 'checkm_res_aggregate_*' | sort -r | head -n1)"
        if test -z \$checkm_res; then export checkm_res=NULL; fi
        export quast_res="\$(find -L \$PWD/${dir_l}/quast -maxdepth 1 -name 'quast_res_aggregate_*' | sort -r | head -n1)"
        if test -z \$quast_res; then export quast_res=NULL; fi
        Rscript -e 'rmarkdown::render("/R/qc_report.Rmd", output_dir=getwd(), knit_root_dir=getwd(), params=list(kreport="${dir_l}/kreport", checkm=Sys.getenv("checkm_res"), quast=Sys.getenv("quast_res"), typing=Sys.getenv("sistr_res"), target=Sys.getenv("target_res")))'
        """   
}

process report_res_aggregate {
    tag "Aggregating all results"
    label "process_low"
    maxForks 1

    input:
        path(res)
    output:
        path("latest_${task.index}/")
    script:
        cumulative_res = task.index != 1 ? res.last() : ''
        """
        mkdir -p latest_${task.index}/
        if test ${task.index} -ne 1; then cp -r ${cumulative_res}/* latest_${task.index}/; fi
        cp \$(find -L . -type f -maxdepth 1) latest_${task.index}/
        """
}

