process samtools_view {
    tag "Sam2Bam for ${sample_id}"
    label "process_low"

    input:
        tuple val(sample_id), path(sam)
    output:
        tuple val(sample_id), path("*.bam")
    shell:
        """
        samtools view -b -F 3584 --threads ${task.cpus} ${sam} | samtools sort > ${sample_id}.bam
        """
}