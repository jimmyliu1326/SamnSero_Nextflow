process minimap2_map_ont {
    tag "Aligning ${sample_id} reads to reference"
    label "process_medium"

    input:
        tuple val(sample_id), path(reads)
        path(reference)
    output:
        tuple val(sample_id), path("*.sam")
    shell:
        """
        minimap2 -ax map-ont \
            -t ${task.cpus} \
            ${reference} ${reads} > ${sample_id}.sam 
        """
}

process minimap2_map_ont_asm {
    tag "Aligning ${sample_id} reads to reference"
    label "process_medium"

    input:
        tuple val(sample_id), path(reads), path(reference)
    output:
        tuple val(sample_id), path("*.sam")
    shell:
        """
        minimap2 -ax map-ont \
            -t ${task.cpus} \
            ${reference} ${reads} > ${sample_id}.sam 
        """
}