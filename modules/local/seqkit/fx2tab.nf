process seqkit_fx2tab {
    tag "Calculating total target read length for ${sample_id}"
    label "process_low"
    //publishDir "$params.out_dir"+"/qc/target_reads/", mode: "copy", pattern: "*.csv"

    input:
        tuple val(sample_id), path(reads)
    output:
        tuple val(sample_id), file("*.csv")
    shell:
        """
        seqkit fx2tab -nil -j ${task.cpus} ${reads} > target_reads.stats.tsv
        read_count=\$(cat target_reads.stats.tsv | wc -l)
        read_bases=\$(cat target_reads.stats.tsv | awk '{sum+=\$2} END {print sum}')
        echo ${sample_id},\$read_count,\$read_bases | sed '1iid,target_count,target_bases' > ${sample_id}.target.stats.csv
        """   
}