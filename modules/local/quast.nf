// genetic risk factor prediction
process quast {
    tag "Computing assembly statistics for ${assembly.simpleName}"
    label "process_low"

    input:
        tuple val(sample_id), path(assembly), path(reads)
    output:
        tuple val(sample_id), file("${assembly.simpleName}.tsv")
    shell:
        """
        quast.py \
            -o . \
            -t ${task.cpus} \
            --nanopore ${reads} \
            --no-plots \
            --no-html \
            --no-icarus \
            --no-snps \
            --no-gc \
            --no-sv \
            ${assembly}
        
        mv transposed_report.tsv ${assembly.simpleName}.tsv
        """
}

process aggregate_quast {
    tag "Aggregating QUAST results"
    label "process_low"
    publishDir "$params.outdir"+"/qc/", mode: "copy"

    input:
        path(quast_res)
    output:
        file("quast_res_aggregate.tsv")
    shell:
        """
        awk 'NR == 1 || FNR > 1' *.tsv > quast_res_aggregate.tsv
        sed -i 's/^Assembly/id/g' quast_res_aggregate.tsv
        """
}