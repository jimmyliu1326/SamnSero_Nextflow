 // set nanohq param value for dragonflye
if( params.nanohq ) { nanohq = "--nanohq" } else { nanohq = '' }

// assembly methods for Nanopore workflows
process flye {
    tag "Flye assembly on ${reads.simpleName}"
    label "process_medium"

    input:
        tuple val(sample_id), path(reads)
    output:
        tuple val(sample_id), file("flye/${reads.simpleName}.fasta")
    shell:
        """
        flye --nano-raw ${reads} -t ${task.cpus} -i 2 -g 4.8m --out-dir flye
        mv flye/assembly.fasta flye/${reads.simpleName}.fasta
        """
}

process dragonflye {
    tag "DragonFlye assembly on ${reads.simpleName}"
    label "process_medium"

    input:
        tuple val(sample_id), path(reads)
    output:
        tuple val(sample_id), file("dragonflye/${reads.simpleName}.fasta")
    shell:
        """
        dragonflye --reads ${reads} --cpus ${task.cpus} --gsize 4.8m --outdir dragonflye ${nanohq}
        mv dragonflye/contigs.fa dragonflye/${reads.simpleName}.fasta
        """
}