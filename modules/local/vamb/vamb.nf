process vamb {
    tag "Metagenomic binning using VAMB"
    label "process_medium"

    input:
        path(bam)
        path(reference)
    output:
        path("vamb/bins/*", type: 'dir')
    script:
        def args = params.gpu ? '--cuda' : ''
        """
        vamb --bam *.bam --outdir vamb --fasta ${reference} --minfasta ${params.min_binsize} -o C -p ${task.cpus} ${args}
        """
}