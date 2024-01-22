process insert_sample_id {
    tag "Inserting ${sample_id} to FASTQ header"
    label "process_low"

    input:
        tuple val(sample_id), path(reads)
    output:
        path('*.fastq')
    script:
        def ext = reads.getExtension()
        """
        if [[ $ext == "gz" ]]; then
            zcat ${reads} | sed '1~4 s/\$/ samnsero_id=${sample_id}/g' > ${sample_id}.${task.index}.rn.fastq
        else
            sed '1~4 s/\$/ samnsero_id=${sample_id}/g' ${reads} > ${sample_id}.${task.index}.rn.fastq
        fi
        """
}