process rename_FASTA {
    tag "File rename for ${sample_id}"
    label "process_low"
    publishDir "${params.outdir}/assembly/${sample_id.replaceAll('_BIN_.*', '')}/bins/", mode: "copy"

    input:
        tuple val(sample_id), path(assembly)
    output:
        tuple val(sample_id), path("*.fasta")
    shell:
        """
        mv ${assembly} ${sample_id}.fasta
        """
}