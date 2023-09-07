process seqkit_split {
    tag "Splitting concatenated FASTQ by Sample ID"
    label "process_low"

    input:
        path(reads)
    output:
        path('*.fastq.gz')
    script:
        """
        seqkit split -i --id-regexp "samnsero_id=(\\S+)" \
            -O . --force -e .gz -j ${task.cpus} \
            ${reads}
        """
}