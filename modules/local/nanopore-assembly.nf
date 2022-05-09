 // set nanohq param value for dragonflye
if( params.nanohq ) { nanohq = "--nanohq" } else { nanohq = '' }

// assembly methods for Nanopore workflows
process flye {
    tag "Flye assembly on ${reads.baseName}"
    label "process_medium"

    input:
        path(reads)
    output:
        file("flye/${reads.baseName}.fasta")
    shell:
        """
        flye --nano-raw ${reads} -t ${task.cpus} -i 2 -g 4.8m --out-dir flye
        mv flye/assembly.fasta flye/${reads.baseName}.fasta
        """
}

process dragonflye {
    tag "DragonFlye assembly on ${reads.baseName}"
    label "process_medium"

    input:
        path(reads)
    output:
        file("dragonflye/${reads.baseName}.fasta")
    shell:
        """
        dragonflye --reads ${reads} --cpus ${task.cpus} --gsize 4.8m --outdir dragonflye ${nanohq}
        mv dragonflye/contigs.fa dragonflye/${reads.baseName}.fasta
        """
}