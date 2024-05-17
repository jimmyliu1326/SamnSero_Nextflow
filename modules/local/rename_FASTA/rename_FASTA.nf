process rename_FASTA {
    tag "File rename for ${sample_id}"
    label "process_low"
    publishDir "${params.out_dir}/assembly/${sample_id.replaceAll('_BIN_.*', '')}/bins/", mode: "copy"

    input:
        tuple val(sample_id), path(assembly, stageAs: "input.fasta") 
    output:
        tuple val(sample_id), path("*.fasta")
    shell:
        """
        mv input.fasta ${sample_id}.fasta
        """
}