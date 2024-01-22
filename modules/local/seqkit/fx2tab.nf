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
        seqkit fx2tab -nil -j ${task.cpus} ${target_reads} > target_reads.stats.tsv
        seqkit fx2tab -nil -j ${task.cpus} ${reads} > total_reads.stats.tsv
        target_read_count=\$(cat target_reads.stats.tsv | wc -l)
        target_read_bases=\$(cat target_reads.stats.tsv | awk '{sum+=\$2} END {print sum}')
        total_read_count=\$(cat total_reads.stats.tsv | wc -l)
        total_read_bases=\$(cat total_reads.stats.tsv | awk '{sum+=\$2} END {print sum}')

        echo ${sample_id},\$target_read_count,\$target_read_bases,\$total_read_count,\$total_read_bases | \
            sed '1iid,target_count,target_bases,total_count,total_bases' > ${sample_id}.stats.csv
        """   
}