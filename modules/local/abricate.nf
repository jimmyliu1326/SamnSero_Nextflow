// genetic risk factor prediction
process abricate {
    tag "Abricate ${db} prediction for ${assembly.simpleName}"
    label "process_low"

    input:
        tuple val(sample_id), path(assembly), val(db)
    output:
        tuple val(db), file("${db}/${assembly.simpleName}.tsv")
    shell:
        """
        mkdir ${db}
        abricate --nopath --threads ${task.cpus} --db ${db} ${assembly} > ${db}/${assembly.simpleName}.tsv
        sed -i 's/.fasta//g' ${db}/${assembly.simpleName}.tsv
        sed -i 's/#FILE/id/g' ${db}/${assembly.simpleName}.tsv
        """
}

process makeblastdb {
    tag "Creating BLAST database for ${db_name}"
    label "process_low"

    input:
        tuple val(db_name), path(db_fasta)
    output:
        path(db_name, type: "dir")
    shell:
        """
        makeblastdb -in ${db_fasta} -dbtype nucl -title ${db_name} -out ${db_name}/sequences
        """   
}

process abricate_custom {
    tag "Abricate ${db} prediction for ${assembly.simpleName}"
    label "process_low"

    input:
        tuple val(sample_id), path(assembly), path(db)
    output:
        tuple val("${db.baseName}"), file("${db.baseName}/${assembly.simpleName}.tsv")
    shell:
        """
        abricate --nopath --threads ${task.cpus} --datadir . --db ${db.baseName} ${assembly} > ${db}/${assembly.simpleName}.tsv
        """
}

process abricate_summary {
    tag "Generate Abricate summary for ${db}"
    label "process_low"
    publishDir "$params.outdir", mode: "copy"

    input:
        tuple val(db), path(assembly)
    output:
        path("annotations/results/${db}_res_aggregate.tsv", emit: aggregate_res, optional: true)
        path("annotations/summary/${db}_summary.tsv", emit: summary, optional: true)
    shell:
        """
        mkdir -p annotations/results/ annotations/summary/
        awk 'NR == 1 || FNR > 1' *.tsv > annotations/results/${db}_res_aggregate.tsv
        abricate --summary *.tsv | sed 's/#FILE/id/g' | sed 's/.tsv//g' > annotations/summary/${db}_summary.tsv

        if [[ \$(cat annotations/results/${db}_res_aggregate.tsv | wc -l) -lt 2 ]]; then rm -r annotations/; fi
        """   
}