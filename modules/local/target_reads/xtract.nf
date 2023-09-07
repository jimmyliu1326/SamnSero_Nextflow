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
        seqkit grep -j ${task.cpus} -f target_reads.txt ${reads} > ${sample_id}.target.fastq.gz
        """   
}