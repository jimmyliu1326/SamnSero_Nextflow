process rename_FASTQ {
    tag "File rename for ${sample_id}"
    label "process_low"

    input:
        tuple val(sample_id), path(fastq)
    output:
        tuple val(sample_id), path("*.{fastq,fastq.gz}")
    script:
        def ext=fastq.getExtension()
        def out_fastq=ext == 'gz' ? "${sample_id}.fastq.gz" : "${sample_id}.fastq"
        """
        mv ${fastq} ${out_fastq}
        """
}