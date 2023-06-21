process target_reads_aggregate {
    tag "Aggregating target reads statistics"
    label "process_low"
    publishDir "$params.outdir"+"/qc/target_reads/", mode: "copy", pattern: "*.csv"

    input:
        path(target_reads_stats)
    output:
        file("*.csv")
    shell:
        """
        awk 'NR == 1 || FNR > 1' *.csv > target_reads_aggregate.csv
        """
}