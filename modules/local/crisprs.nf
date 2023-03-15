// CRISPR prediction tools
process tnblast {
    tag "In-silico CRISPR PCR for ${sample_id}"
    label "process_low"
    publishDir "$params.outdir"+"/annotations/crisprs/fasta/", mode: "copy"

    input:
        tuple val(sample_id), path(assembly), path(primers)
    output:
        tuple val(sample_id), file("CRISPR_{1,2}/${sample_id}.CRISPR_{1,2}.fa"), emit: crispr_1, optional: true
    shell:
        """
        tntblast \
            -i ${primers} \
            -o ${sample_id}.tnblast \
            -d ${assembly} \
            -e 40 \
            -m 1 \
            -a F \
            -S T \
            --best-match \
            -l 4000 \
            -n T

        if test -f ${sample_id}.tnblast.CRISPR_1; then 
            mkdir CRISPR_1
            mv ${sample_id}.tnblast.CRISPR_1 CRISPR_1/${sample_id}.CRISPR_1.fa
            sed -i 's/>/>${sample_id}-/g' CRISPR_1/${sample_id}.CRISPR_1.fa
        fi

        if test -f ${sample_id}.tnblast.CRISPR_2; then 
            mkdir CRISPR_2
            mv ${sample_id}.tnblast.CRISPR_2 CRISPR_2/${sample_id}.CRISPR_2.fa
            sed -i 's/>/>${sample_id}-/g' CRISPR_2/${sample_id}.CRISPR_2.fa
        fi
        
        """
}

process cctyper {
    tag "CRISPR ${crispr_id} typing for ${sample_id}"
    label "process_low"
    publishDir "$params.outdir"+"/annotations/crisprs/gff/crispr_${crispr_id}/", mode: "copy", pattern: "*.gff"

    input:
        tuple val(sample_id), path(crispr_fa), val(crispr_id)
    output:
        tuple val(sample_id), file("${sample_id}.crispr_${crispr_id}.tsv"), val(crispr_id), emit: typing_res, optional: true
        tuple val(sample_id), file("${sample_id}.crispr_${crispr_id}.gff"), val(crispr_id), emit: gff, optional: true
    shell:
        """
        cctyper \
            -t ${task.cpus} \
            --no_plot \
            --repeat_id 50 \
            --spacer_id 40 \
            ${crispr_fa} \
            cctyper_res/ \


        if test -f cctyper_res/crisprs_all.tab; then
            mv cctyper_res/crisprs_all.tab ${sample_id}.crispr_${crispr_id}.tsv
            sed -i "1i\\##gff-version 3\" cctyper_res/crisprs.gff
            mv cctyper_res/crisprs.gff ${sample_id}.crispr_${crispr_id}.gff
        fi
        """
}

process aggregate_cctyper {
    tag "Aggregating CCTyper results"
    label "process_low"
    publishDir "$params.outdir"+"/annotations/crisprs/typing_res/", mode: "copy"

    input:
        tuple val(crispr_id), path(cctyper_res)
    output:
        file("CRISPR_${crispr_id}_res_aggregate.tsv")
    shell:
        """
        awk 'NR == 1 || FNR > 1' * > CRISPR_${crispr_id}_res_aggregate.tsv
        """
}