process fastqc {
    tag "FastQC on ${sample_id}"
    label "process_low"

    input: 
        tuple val(sample_id), path(reads)
    output: 
        path("*.zip")
    shell:
        """
        fastqc -o . -t ${task.cpus} *.fastq*
        """
}

process multiqc {
    tag "Aggregating FastQC reports with MultiQC"
    label "process_low"
    publishDir "$params.outdir"+"/reports/", mode: "copy"

    input: 
        path(fastqc)
    output: 
        path("multiqc.html")
    shell:
        """
        multiqc -n multiqc.html .
        """
}