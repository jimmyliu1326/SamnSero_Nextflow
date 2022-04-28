// genetic risk factor prediction
process abricate {
    tag "Abricate ${db} prediction for ${assembly.simpleName}"
    label "process_low"
    publishDir "$params.outdir"+"/abricate", mode: "copy"

    input:
        tuple path(assembly), val(db)
    output:
        tuple val(db), file("${db}/${assembly.simpleName}.tab")
    shell:
        """
        mkdir ${db}
        abricate --nopath --threads ${task.cpus} --db ${db} ${assembly} > ${db}/${assembly.simpleName}.tab
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
    publishDir "$params.outdir"+"/abricate", mode: "copy"

    input:
        tuple path(assembly), path(db)
    output:
        tuple val("${db.baseName}"), file("${db.baseName}/${assembly.simpleName}.tab")
    shell:
        """
        abricate --nopath --threads ${task.cpus} --datadir . --db ${db.baseName} ${assembly} > ${db}/${assembly.simpleName}.tab
        """   
}

process abricate_summary {
    tag "Generate Abricate summary for ${db}"
    label "process_low"
    publishDir "$params.outdir"+"/abricate", mode: "copy"

    input:
        tuple val(db), path(assembly)
    output:
        file("${db}_summary.tab")
    shell:
        """
        abricate --summary *.tab > ${db}_summary.tab
        """   
}