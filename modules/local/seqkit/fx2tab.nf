process seqkit_fx2tab {
    tag "Calculating total target read length for ${sample_id}"
    label "process_low"
    //publishDir "$params.out_dir"+"/qc/target_reads/", mode: "copy", pattern: "*.csv"

    input:
        tuple val(sample_id), path(target_reads), path(reads)
    output:
        tuple val(sample_id), file("*.csv")
    shell:
        """
        seqkit stats -T -j ${task.cpus} ${target_reads} > target_reads.stats.tsv
        seqkit stats -T -j ${task.cpus} ${reads} > total_reads.stats.tsv
        target_read_count=\$(tail -n +2 target_reads.stats.tsv | cut -f4)
        target_read_bases=\$(tail -n +2 target_reads.stats.tsv | cut -f5)
        total_read_count=\$(tail -n +2 total_reads.stats.tsv | cut -f4)
        total_read_bases=\$(tail -n +2 total_reads.stats.tsv | cut -f5)

        echo ${sample_id},\$target_read_count,\$target_read_bases,\$total_read_count,\$total_read_bases | \
            sed '1iid,target_count,target_bases,total_count,total_bases' > ${sample_id}.stats.csv
        """   
}