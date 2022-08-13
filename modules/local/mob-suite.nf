// plasmid prediction with mob-suite
process mob_suite {
    tag "Plasmid prediction for ${assembly.simpleName}"
    label "process_medium"

    input:
        tuple val(sample_id), path(assembly)
    output:
        tuple val(sample_id), file("${assembly.simpleName}.mobtyper"), optional: true
    shell:
        """
        mob_recon --infile ${assembly} --outdir results --num_threads ${task.cpus}
        if test -f results/mobtyper_results.txt; then
            echo contig \$(cat results/contig_report.txt | grep plasmid | cut -f5) | sed 's/ /\\n/g' > results/contigs.list
            paste results/mobtyper_results.txt results/contigs.list > ${assembly.simpleName}.mobtyper
            sed -i 's/^sample_id/id/g' ${assembly.simpleName}.mobtyper
        fi
        """
}

process aggregate_mob_suite {
    tag "Aggregating MOB-Suite results"
    label "process_medium"
    publishDir "$params.outdir"+"/annotations/results", mode: "copy"

    input:
        path(mob_suite_res)
    output:
        file("mob_suite_res_aggregate.tsv")
    shell:
        """
        awk 'NR == 1 || FNR > 1' *.mobtyper > mob_suite_res_aggregate.tsv
        """
}

process mob_suite_summary {
    tag "Summarizing MOB-Suite results"
    label "process_low"
    publishDir "$params.outdir"+"/annotations/summary", mode: "copy"

    input:
        path(mob_suite_res)
        file(samples)
    output:
        file("mob_suite_summary.tsv")
    shell:
        """
        cat ${samples} | cut -f1 -d',' > samples.list
        mob_suite_transpose.R ${mob_suite_res} samples.list mob_suite_summary.tsv
        """
}