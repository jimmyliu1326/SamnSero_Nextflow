// plasmid prediction with mob-suite
process mob_suite {
    tag "Plasmid prediction for ${sample_id}"
    label "process_medium"

    input:
        tuple val(sample_id), path(assembly)
    output:
        tuple val(sample_id), file("mobtyper_results.txt"), file("contig_report.txt"), optional: true
    shell:
        """
        mob_recon --infile ${assembly} --outdir results --num_threads ${task.cpus}

        if test -f results/mobtyper_results.txt; then
            sed  's/^sample_id/id/g' results/mobtyper_results.txt > mobtyper_results.txt
            head -n1 results/contig_report.txt | sed  's/^sample_id/id/g' > contig_report.txt
            cat results/contig_report.txt | grep plasmid >> contig_report.txt
        fi
        """
}

process mob_suite_merge {
    tag "Merging MOB-Suite results for ${sample_id}"
    label "process_low"

    input:
        tuple val(sample_id), file(mobtyper_res), file(contig_report)
    output:
        tuple val(sample_id), file("${sample_id}.mobtyper")
    shell:
        """
        mob_suite_merge.R ${contig_report} ${mobtyper_res} > ${sample_id}.mobtyper
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