process target_reads_aggregate {
    tag "Aggregating target reads statistics"
    label "process_low"
    // publishDir "$params.out_dir"+"/qc/target_reads/", mode: "copy", pattern: "*.csv"

    input:
        path(target_reads_stats)
    output:
        file("*.csv")
    shell:
        """
        awk 'NR == 1 || FNR > 1' *.csv > target_reads_aggregate.csv
        """
}

process target_reads_aggregate_watch {
    tag "Aggregating Target DNA results"
    label "process_low"
    maxForks 1
    publishDir "${params.out_dir}/report_data/target/", mode: 'copy'

    input:
        path(res)
    output:
        file("target_reads_aggregate_${res.first().getBaseName().replaceAll('_TIME_.*', '')}.csv")
    script:
        def new_res = res.first()
        def timestamp = new_res.getBaseName().replaceAll('_TIME_.*', '')
        def cumulative_res = task.index != 1 ? res.last() : ''
        """
        awk 'NR == 1 || FNR > 1' ${new_res} ${cumulative_res} > target_reads_aggregate_${timestamp}.csv
        """
}