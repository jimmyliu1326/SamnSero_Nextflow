process seqkit_grep {
    tag "Searching for ${params.taxon_name} ctgs in ${sample_id}"
    label "process_low"
    publishDir "$params.out_dir"+"/assembly/${sample_id}", mode: "copy", pattern: "*.fasta", saveAs: { "${sample_id}.${taxon_name}.replaceAll(' ', '_').fasta" }

    input:
        tuple val(sample_id), path(genome, stageAs: "?/*")
        tuple val(sample_id), path(class_res)
    output:
        tuple val(sample_id), path("*.fasta")
    script:
        """
        cat ${genome} | \
            seqkit grep \
            -j ${task.cpus} \
            -f ${class_res} \
            > ${sample_id}.fasta
        """
}