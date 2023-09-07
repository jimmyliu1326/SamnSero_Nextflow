// in-silico serotyping using SISTR
process sistr {
    tag "SISTR serotyping for ${sample_id}"
    label "process_low"

    input:
        tuple val(sample_id), path(assembly)
    output:
        tuple val(sample_id), file("${sample_id}.csv")
    shell:
        """
        sistr -i ${assembly} ${sample_id} -o ${sample_id}.csv -t ${task.cpus} -f csv --qc
        """   
}

process aggregate_sistr {
    tag "Aggregating serotyping results"
    label "process_low"

    input:
        path(sistr_res)
    output:
        file("sistr_res_aggregate.csv")
    shell:
        """
        awk 'NR == 1 || FNR > 1' *.csv > sistr_res_aggregate.csv
        sed -i 's/,genome,/,id,/g' sistr_res_aggregate.csv
        """
}

process aggregate_sistr_watch {
    tag "Aggregating serotyping results"
    label "process_low"
    publishDir "${params.outdir}/timepoints/${res.first().getBaseName().replaceAll('_TIME_.*', '')}/sistr", mode: 'copy', saveAs: { "sistr_res_aggregate.csv" }
    maxForks 1

    input:
        path(res)
    output:
        file("sistr_res_aggregate_${res.first().getBaseName().replaceAll('_TIME_.*', '')}.csv")
    script:
        def new_res = res.first()
        def timestamp = new_res.getBaseName().replaceAll('_TIME_.*', '')
        def cumulative_res = task.index != 1 ? res.last() : ''
        """
        sed -i 's/,genome,/,id,/g' ${new_res}
        awk 'NR == 1 || FNR > 1' ${new_res} ${cumulative_res} > sistr_res_aggregate_${timestamp}.csv
        """
}