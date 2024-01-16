process checkm {
    tag "Checking genome completness and contamination"
    label "process_medium"
    publishDir "$params.out_dir"+"/qc/", mode: "copy"

    input:
        path(assemblies)
    output:
        path("checkm_res_aggregate.tsv")
    script:
        def ext = assemblies[0].getExtension()
         """
        checkm taxonomy_wf --tab_table \
            -t ${task.cpus} \
            -x ${ext} \
            -f checkm_res_aggregate.tsv \
            ${params.taxon_level} "${params.taxon_name}" \
            . \
            .
        sed -i 's/^Bin Id/id/g' checkm_res_aggregate.tsv
        """
}

process checkm_single {
    tag "Checking genome completness and contamination for ${sample_id}"
    label "process_low"

    input:
        tuple val(sample_id), path(assemblies)
    output:
        tuple val(sample_id), path("${sample_id}.tsv")
    script:
        def ext = assemblies[0].getExtension()
         """
        checkm taxonomy_wf --tab_table \
            -t ${task.cpus} \
            -x ${ext} \
            -f ${sample_id}.tsv \
            ${params.taxon_level} "${params.taxon_name}" \
            . \
            .
        """
}

process aggregate_checkm {
    tag "Aggregating CheckM results"
    label "process_low"
    publishDir "$params.out_dir"+"/qc/", mode: "copy"

    input:
        path(quast_res)
    output:
        file("checkm_res_aggregate.tsv")
    shell:
        """
        awk 'NR == 1 || FNR > 1' *.tsv > checkm_res_aggregate.tsv
        sed -i 's/^Bin Id/id/g' checkm_res_aggregate.tsv
        """
}

process aggregate_checkm_watch {
    tag "Aggregating CheckM results"
    label "process_low"
    publishDir "${params.out_dir}/timepoints/${res.first().getBaseName().replaceAll('_TIME_.*', '')}/checkm", mode: 'copy', saveAs: { "checkm_res_aggregate.csv" }
    maxForks 1

    input:
        path(res)
    output:
        file("checkm_res_aggregate_${res.first().getBaseName().replaceAll('_TIME_.*', '')}.tsv")
    script:
        def new_res = res.first()
        def timestamp = new_res.getBaseName().replaceAll('_TIME_.*', '')
        def cumulative_res = task.index != 1 ? res.last() : ''
        """
        sed -i 's/^Bin Id/id/g' ${new_res}
        awk 'NR == 1 || FNR > 1' ${new_res} ${cumulative_res} > checkm_res_aggregate_${timestamp}.tsv
        """
}