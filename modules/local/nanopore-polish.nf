// post-assembly polishing for Nanopore workflows
process medaka {
    tag "Assembly polishing for ${reads.baseName}"
    label "process_med"
    publishDir "$params.outdir"+"/assembly", mode: "copy"

    input:
        path(reads)
        path(assembly)
    output:
        file("${reads.baseName}.fasta")
    shell:
        """
        medaka_consensus -i ${reads} -d ${assembly} -o . -t ${task.cpus}
        mv consensus.fasta ${reads.baseName}.fasta
        """
}