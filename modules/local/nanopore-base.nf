// basic processes for Nanopore workflows
process combine {
    tag "Combining FASTQ files for ${sample_id}"
    label "process_low"

    input:
        tuple val(sample_id), path(reads)
    output:
        tuple val(sample_id), file("${sample_id}.{fastq,fastq.gz}")
    shell:
        """
        sample=\$(ls ${reads} | head -n 1)
        if [[ \${sample##*.} == "gz" ]]; then
            ext="fastq.gz"
            cat_cmd="zcat"
        else
            ext="fastq"
            cat_cmd="cat"
        fi
        cat ${reads}/*.\$ext > ${sample_id}.\$ext
        # verify file integrity
        \$cat_cmd ${sample_id}.\$ext | \
            awk 'NR%4==2 || NR%4==0' | \
            paste - - | \
            awk '{if(length($1) != length($2)) {print "Read " NR/4 " has different number of bases and quality scores"; exit 1}}' \
            > /dev/null
        """
}

process combine_watch {
    tag "Combining FASTQ files"
    label "process_low"
    maxForks 1

    input:
        path(reads)
    output:
        path("*.{fastq,fastq.gz}")
    script:
        def file = reads[0]
        def ext = file.getExtension()
        // def inputs =  reads.join(', ')
        def new_fastq = reads.first()
        def cumulative_fastq = task.index != 1 ? reads.last() : ''
        def date = new Date()
        def id = new_fastq.getSimpleName()
        // def timestamp = date.format("dd_MM_yyyy_HH_mm_ss")
        def timestamp = date.getTime()
        def out_fastq = ext == 'gz' ? "${timestamp}_TIME_${id}.fastq.gz" : "${timestamp}_TIME_${id}.fastq"
        println "Task ${task.index}: Combining "+ new_fastq + ", " + cumulative_fastq
        """
        cat ${new_fastq} ${cumulative_fastq} > ${out_fastq}
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
    // publishDir "$params.out_dir"+"/reads/", mode: "copy"

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
    publishDir "$params.out_dir"+"/reports/", mode: "copy", pattern: "*.html", saveAs: { "NanoComp_report.html" }
    publishDir "$params.out_dir"+"/qc/nanocomp/", mode: "copy", pattern: "*.{txt,gz}", saveAs: { 
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
        NanoComp -t ${task.cpus} --tsv_stats --raw --fastq *.fastq* --names \$(ls | sed 's/.fastq*//g') -o .
        """
}