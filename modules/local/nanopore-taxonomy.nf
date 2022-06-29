// taxonomic classifiers and viz tools for Nanopore workflows
process centrifuge {
    tag "Classifying reads for ${reads.baseName}"
    label "process_medium"
    publishDir "$params.outdir"+"/qc/centrifuge/", mode: "copy"

    input:
        tuple val(sample_id), path(reads)
        path(database_dir)
    output:
        path("*.report", emit: report)
        path("*.krona", emit: krona)
        path("*.kraken.report", emit: kreport)
    shell:
        """
        db_path=\$(find -L ${database_dir} -name "*.1.cf" -not -name "._*"  | sed 's/.1.cf//')
        centrifuge -U ${reads} -S ${reads.simpleName}.out --report ${reads.simpleName}.report -x \$db_path -p ${task.cpus} --mm
        cat ${reads.simpleName}.out | cut -f1,3 > ${reads.simpleName}.krona
        centrifuge-kreport -x \$db_path ${reads.simpleName}.out > ${reads.simpleName}.kraken.report 
        """
}

process krona {
    tag "Generating Krona viz"
    label "process_low"
    publishDir "$params.outdir"+"/reports/", mode: "copy"

    input:
        path(krona_input)
    output:
        file("taxonomy_classification.html")
    shell:
        """
        ktImportTaxonomy * -o taxonomy_classification.html
        """
}