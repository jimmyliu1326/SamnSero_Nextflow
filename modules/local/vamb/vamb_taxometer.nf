process vamb_taxometer {
    tag "Metagenomic binning using VAMB"
    label "process_medium"

    input:
        tuple val(sample_id), path(reference), path(bam), path(taxonomy)
    output:
        path("*/*.csv")
    script:
        def args = params.gpu ? '--cuda' : ''
        """
        vamb taxometer \
            --bam *.bam \
            --taxonomy ${taxonomy} \
            --outdir ${sample_id} \
            --fasta ${reference} \
            -p ${task.cpus} \
            -pt 32 \
            ${args}
        """
}