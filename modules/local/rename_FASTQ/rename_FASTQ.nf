process rename_FASTQ {
    tag "File rename for ${sample_id}"
    label "process_low"
    maxForks 1

    input:
        tuple val(sample_id), path(fastq)
    output:
        tuple val(sample_id), path("*.{fastq,fastq.gz}")
    script:
        def ext=fastq.getExtension()
        def date = new Date()
        def timestamp = date.getTime()
        def out_fastq = ext == 'gz' ? "${timestamp}_TIME_${sample_id}.fastq.gz" : "${timestamp}_TIME_${sample_id}.fastq"
        def out_ext = ext == 'gz' ? 'fastq.gz' : 'fastq'
        """
        timestamp=\$(date +%s%3N)
        ln -s \$PWD/${fastq} \${timestamp}_TIME_${sample_id}.${out_ext}
        """
}