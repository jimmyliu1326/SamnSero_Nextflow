// genetic risk factor prediction
process quast {
    tag "Computing assembly statistics for ${sample_id}"
    label "process_low"

    input:
        tuple val(sample_id), path(assembly), path(reads)
    output:
        tuple val(sample_id), file("${sample_id}.tsv")
    script:
        def input_reads = (params.seq_platform == 'illumina') ? "-1 ${reads[0]} -2 ${reads[1]}" : "--nanopore ${reads}"
        """
        quast.py \
            -o . \
            -t ${task.cpus} \
            ${input_reads} \
            --no-plots \
            --no-html \
            --no-icarus \
            --no-snps \
            --no-gc \
            --no-sv \
            ${assembly}
        
        cat transposed_report.tsv | awk 'BEGIN{OFS="\t"} NR==2{\$1="${sample_id}"}1' > ${sample_id}.tsv
        """
}

process aggregate_quast {
    tag "Aggregating QUAST results"
    label "process_low"
    publishDir "$params.out_dir"+"/qc/", mode: "copy"

    input:
        path(quast_res)
    output:
        file("quast_res_aggregate.tsv")
    shell:
        """
        awk 'NR == 1 || FNR > 1' *.tsv > quast_res_aggregate.tsv
        sed -i 's/^Assembly/id/g' quast_res_aggregate.tsv
        """
}

process aggregate_quast_watch {
    tag "Aggregating QUAST results"
    label "process_low"
    publishDir "${params.out_dir}/timepoints/${res.first().getBaseName().replaceAll('_TIME_.*', '')}/quast", mode: 'copy', saveAs: { "quast_res_aggregate.csv" }
    maxForks 1

    input:
        path(res)
    output:
        path("quast_res_aggregate_${res.first().getBaseName().replaceAll('_TIME_.*', '')}.tsv")
    script:
        def new_res = res.first()
        def timestamp = new_res.getBaseName().replaceAll('_TIME_.*', '')
        def cumulative_res = task.index != 1 ? res.last() : ''
        """
        sed -i 's/^Assembly/id/g' ${new_res}
        awk 'NR == 1 || FNR > 1' ${new_res} ${cumulative_res} > quast_res_aggregate_${timestamp}.tsv
        """
}