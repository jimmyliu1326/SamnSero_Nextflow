process mafft {
    tag "CRISPR ${crispr_id} MSA"
    label "process_low"
    publishDir "$params.outdir"+"/annotations/crisprs/msa/", mode: "copy"

    input:
        tuple val(crispr_id), path(crispr_fa)
    output:
        path("CRISPR_${crispr_id}.aln")
    shell:
        """
        cat *.fa > crispr_${crispr_id}.fa
        mafft --maxiterate 1000 --thread ${task.cpus} crispr_${crispr_id}.fa > CRISPR_${crispr_id}.aln
        """
}