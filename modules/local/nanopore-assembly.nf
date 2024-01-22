// assembly methods for Nanopore workflows
process metaflye {
    tag "MetaFlye assembly on ${sample_id}"
    label "process_medium"
    publishDir "$params.out_dir"+"/assembly/${sample_id}", mode: "copy", pattern: "*.{log,txt,gfa,fasta}"

    input:
        tuple val(sample_id), path(reads)
        val(flye_opts)
    output:
        tuple val(sample_id), path("${sample_id}.fasta"), emit: fasta
        tuple val(sample_id), path("${sample_id}.gfa"), emit: gfa
        tuple val(sample_id), path("flye.log"), emit: flye_log
        tuple val(sample_id), path("assembly_info.txt"), optional: true, emit: info_txt
    shell:
        """
        flye ${flye_opts} ${reads} -t ${task.cpus} --meta --keep-haplotypes --out-dir .
        mv assembly.fasta ${sample_id}.fasta
        mv assembly_graph.gfa ${sample_id}.gfa
        """
}

process dragonflye {
    tag "DragonFlye assembly on ${sample_id}"
    label "process_medium"
    publishDir "$params.out_dir"+"/assembly/${sample_id}", mode: "copy", pattern: "*.{log,txt,gfa}"

    input:
        tuple val(sample_id), path(reads)
        val(flye_opts)
    output:
        tuple val(sample_id), path("${sample_id}.fasta"), emit: fasta
        tuple val(sample_id), path("${sample_id}.gfa"), emit: gfa
        tuple val(sample_id), path("dragonflye.log"), emit: dragonflye_log
        tuple val(sample_id), path("flye-info.txt"), optional: true, emit: info_txt
    script:
        """
        dragonflye --reads ${reads} --cpus ${task.cpus} --outdir . --force --ram ${task.memory.toGiga()} ${flye_opts}    
        mv contigs.fa ${sample_id}.fasta
        mv flye-unpolished.gfa ${sample_id}.gfa
        """
}