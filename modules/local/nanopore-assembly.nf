// assembly methods for Nanopore workflows
process metaflye {
    tag "MetaFlye assembly on ${sample_id}"
    label "process_medium"
    publishDir "$params.outdir"+"/assembly/", mode: "copy"
    errorStrategy 'ignore'

    input:
        tuple val(sample_id), path(reads)
        val(flye_opts)
    output:
        tuple val(sample_id), file("${sample_id}.fasta"), emit: fasta
        tuple val(sample_id), file("${sample_id}.gfa"), emit: gfa
    shell:
        """
        flye --nano-raw ${reads} -t ${task.cpus} --meta --out-dir flye ${flye_opts}
        mv flye/assembly.fasta ${sample_id}.fasta
        mv flye/assembly_graph.gfa ${sample_id}.gfa
        """
}

process dragonflye {
    tag "DragonFlye assembly on ${sample_id}"
    label "process_medium"
    publishDir "$params.outdir"+"/assembly/", mode: "copy"
    errorStrategy 'ignore'

    input:
        tuple val(sample_id), path(reads)
        val(flye_opts)
    output:
        tuple val(sample_id), file("${sample_id}.fasta"), emit: fasta
        tuple val(sample_id), file("${sample_id}.gfa"), emit: gfa
    shell:
        """
        dragonflye --reads ${reads} --cpus ${task.cpus} --outdir dragonflye --ram ${task.memory.toGiga()} ${flye_opts}    
        mv dragonflye/contigs.fa ${sample_id}.fasta
        mv dragonflye/flye-unpolished.gfa ${sample_id}.gfa
        """
}