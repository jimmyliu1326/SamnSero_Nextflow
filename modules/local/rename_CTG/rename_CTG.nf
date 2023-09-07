process rename_CTG {
    tag "Appending sample ID to contigs for ${sample_id}"
    label "process_low"

    input:
        tuple val(sample_id), path(assembly)
    output:
        tuple val(sample_id), path("*.fasta")
    shell:
        """
        sed "s/>/>${sample_id}C/g" ${assembly} > ${sample_id}.rn.fasta
        """
}