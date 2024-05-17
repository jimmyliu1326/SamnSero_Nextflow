process target_reads_xtract {
    tag "Xtracting target organism reads for ${sample_id}"
    label "process_low"
    // publishDir "$params.out_dir"+"/qc/target_reads/", mode: "copy", pattern: "*.fastq.gz"

    input:
        tuple val(sample_id), path(krona), val(taxon_id), path(reads)
    output:
        tuple val(sample_id), file("*.fastq.gz")
    shell:
        """
        cat ${krona} | grep ${taxon_id} | cut -f1 > target_reads.txt
        cat ${reads} | seqkit grep -f target_reads.txt -j ${task.cpus} -rp - -o ${sample_id}.target.fastq.gz
        """   
}