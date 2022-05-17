// genetic risk factor prediction
process mob_suite {
    tag "Plasmid prediction for ${assembly.simpleName}"
    label "process_low"

    input:
        tuple val(sample_id), path(assembly)
    output:
        file("${assembly.simpleName}.mobtyper")
    shell:
        """
        mob_recon --infile ${assembly} --outdir .
        mv mobtype_results.txt ${assembly.simpleName}.mobtyper
        """
}

process aggregate_mob_suite {
    tag "Aggregating MOB-Suite results"
    label "process_low"
    publishDir "$params.outdir"+"/annotations", mode: copy

    input:
        path(mob_suite_res)
    output:
        file("mob_suite_res_aggregate.tsv")
    shell:
        """
        awk 'NR == 1 || FNR > 1' * > mob_suite_res_aggregate.tsv
        sed -i 's/^sample_id/id/g' mob_suite_res_aggregate.tsv
        """
}