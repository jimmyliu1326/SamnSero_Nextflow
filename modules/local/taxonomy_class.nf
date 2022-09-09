// taxonomic classifiers and viz tools for Nanopore workflows
process centrifuge {
    tag "Classifying reads for ${sample_id}"
    label "process_medium"
    publishDir "$params.outdir"+"/qc/centrifuge/", mode: "copy"

    input:
        tuple val(sample_id), path(reads)
        path(database_dir)
    output:
        path("*.report", emit: report)
        path("*.krona", emit: krona)
        path("*.kraken.report"), emit: kreport
    shell:
        """
        db_path=\$(find -L ${database_dir} -name "*.1.cf" -not -name "._*"  | sed 's/.1.cf//')

        if [[ ${params.seq_platform} == "illumina" ]]; then
            input="-1 ${reads[0]} -2 ${reads[1]}"
        else
            input="-U ${reads}"
        fi

        centrifuge \$input -S ${sample_id}.out --report ${sample_id}.report -x \$db_path -p ${task.cpus} --mm
        cat ${sample_id}.out | cut -f1,3 > ${sample_id}.krona
        centrifuge-kreport -x \$db_path ${sample_id}.out > ${sample_id}.kraken.report 
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