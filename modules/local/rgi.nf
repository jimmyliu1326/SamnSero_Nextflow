// AMR prediction with rgi
process rgi {
    tag "RGI AMR prediction for ${sample_id}"
    label "process_low"

    input:
        tuple val(sample_id), path(assembly)
    output:
        tuple val(sample_id), file("${sample_id}.tsv"), optional: true
    shell:
        """
        rgi main -i ${assembly} -o ./out -t contig --num_threads ${task.cpus}
        sed 's/\\r//g' out.txt > ${sample_id}.tsv
        sed -i '1s/\$/\tid/; 2,\$s/\$/\t${sample_id}/' ${sample_id}.tsv
        if [[ \$(cat ${sample_id}.tsv | wc -l) -lt 2 ]]; then rm ${sample_id}.tsv; fi
        """
}

process aggregate_rgi {
    tag "Aggregating RGI results"
    label "process_low"
    publishDir "$params.outdir"+"/annotations/results", mode: "copy"

    input:
        path(rgi_res)
    output:
        file("rgi_res_aggregate.tsv")
    shell:
        """
        awk 'NR == 1 || FNR > 1' *.tsv > rgi_res_aggregate.tsv
        """
}

process rgi_summary {
    tag "Summarizing RGI results"
    label "process_low"
    publishDir "$params.outdir"+"/annotations/summary", mode: "copy"

    input:
        path(rgi_res)
        file(samples)
    output:
        file("rgi_summary.tsv")
    shell:
        """
        cat ${samples} | cut -f1 -d',' > samples.list
        rgi_transpose.R ${rgi_res} samples.list rgi_summary.tsv
        """
}