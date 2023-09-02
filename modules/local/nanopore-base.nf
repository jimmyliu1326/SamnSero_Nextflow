// basic processes for Nanopore workflows
process combine {
    tag "Combining Fastq files for ${sample_id}"
    label "process_low"

    input:
        tuple val(sample_id), path(reads)
    output:
        tuple val(sample_id), file("${sample_id}.{fastq,fastq.gz}")
    shell:
        """
        sample=\$(ls ${reads} | head -n 1)
        if [[ \${sample##*.} == "gz" ]]; then
            cat ${reads}/*.fastq.gz > ${sample_id}.fastq.gz
        else
            cat ${reads}/*.fastq > ${sample_id}.fastq
        fi
        """
}

process porechop {
    tag "Adaptor trimming on ${sample_id}"
    label "process_high"

    input:
        tuple val(sample_id), path(reads)
    output:
        tuple val(sample_id), file("${sample_id}_trimmed.fastq")
    shell:
        """
        porechop -t ${task.cpus} -i ${reads} -o ${sample_id}_trimmed.fastq
        """
}

process nanoq {
    tag "Read filtering on ${sample_id}"
    label "process_low"
    cache true
    // publishDir "$params.outdir"+"/reads/", mode: "copy"

    input:
        tuple val(sample_id), path(reads)
    output:
        tuple val(sample_id), file("${sample_id}.filt.fastq.gz")
    shell:
        """
        nanoq -i ${reads} -l 1000 -q 10 -O g > ${sample_id}.filt.fastq.gz
        """
}

process nanocomp {
    tag "Generating raw read QC with NanoPlot"
    label "process_low"
    publishDir "$params.outdir"+"/reports/", mode: "copy", pattern: "*.html", saveAs: { "NanoComp_report.html" }
    publishDir "$params.outdir"+"/qc/nanocomp/", mode: "copy", pattern: "*.{txt,gz}", saveAs: { 
        fn ->
            if ( fn.endsWith("txt") ) { 
                "NanoComp_stats.tsv"
            } else { "NanoComp_data.tsv.gz" }
    }

    input:
        path(reads)
    output:
        path("NanoComp-report.html"), emit: report_html
        path("NanoStats.txt"), emit: stats_tsv
        path("NanoComp-data.tsv.gz"), emit: data
    shell:
        """
        NanoComp -t ${task.cpus} --tsv_stats --raw --fastq_rich *.fastq* --names \$(ls | sed 's/.fastq*//g') -o .
        """
}