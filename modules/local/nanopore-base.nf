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
            awk '{if(length(\$1) != length(\$2)) {print "Read " NR/4 " has different number of bases and quality scores"; exit 1}}' \
            > /dev/null
        """
}

process fastq_watch {
    tag "Collecting FASTQ files"
    label "process_low"
    maxForks 1

    input:
        path(reads)
    output:
        path("latest_${task.index}/")
    script:
        def file = reads[0]
        def ext = file.getExtension()
        def new_fastq = reads.first()
        def id = new_fastq.getSimpleName()
        def barcode = id.replaceAll('.*_TIME_', '')
        def timestamp = id.replaceAll('_TIME_.*', '')
        def dir = 'latest_' + task.index
        def out_fastq = ext == 'gz' ? "${timestamp}_TIME_${barcode}.fastq.gz" : "${timestamp}_TIME_${barcode}.fastq"
        // println "Task ${task.index}: Combining "+ new_fastq + ", " + cumulative_fastq
        println "Task ${task.index}: Adding " + new_fastq + " to " + dir
        """
        # create output dir
        mkdir ${dir}
        # copy symlink for new_fastq
        cp -P ${new_fastq} ${dir}/${out_fastq}
        # create symlinks from previous i-1 iteration
        if test ${task.index} -gt 1; then
        find -L \$PWD/latest_\$(( ${task.index} - 1)) -type f -name '*.fastq*' | \
        parallel -j 8 'f={}; cp -a \$f ${dir}/\$(basename \$f)' \\;
        fi
        """
}

process combine_watch {
    tag "Combining FASTQ files"
    label "process_low"

    input:
        path(dir)
    output:
        path("*.{fastq,fastq.gz}")
    script:
        """
        # find the latest barcode
        latest=\$(find -L ${dir} -maxdepth 1 -type f -name '*.fastq*' -exec sh -c 'echo \$(basename {})' \\; | sort -r | head -n1 | sed 's/.fastq.*//g')
        barcode=\$(echo \${latest} | sed 's/.*_TIME_//g')
        timestamp=\$(echo \${latest} | sed 's/_TIME_.*//g')
        sample_id=\$(echo \${timestamp}_TIME_\${barcode})
        # search for all fastq associated with latest barcode
        fastq=\$(find -L \$PWD/${dir} -maxdepth 1 -type f -name "*\${barcode}.fastq*")
        # concatenate and deduplicate
        cat \${fastq} | seqkit rmdup -n -o \${sample_id}.fastq.gz
        """
}

process porechop {
    tag "Adaptor trimming on ${sample_id}"
    label "process_medium"

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
        nanoq -i ${reads} -l ${params.min_rl} -q ${params.min_rq} -O g > ${sample_id}.filt.fastq.gz
        """
}

process nanocomp {
    tag "Generating raw read QC with NanoPlot"
    label "process_low"

    input:
        path(reads)
    output:
        path("NanoComp-report.html"), emit: report_html
        path("NanoStats.txt"), emit: stats_tsv
        path("NanoComp-data.tsv.gz"), emit: data
    shell:
        """
        NanoComp -t ${task.cpus} --tsv_stats --raw --fastq *.fastq* --names \$(ls | sed 's/.fastq.*//g') -o .
        """
}

process nanocomp_dir {
    tag "Generating raw read QC with NanoPlot"
    label "process_low"
    maxForks 1

    input:
        tuple path(dir), path(work)
    output:
        path("NanoComp-report.html"), emit: report_html
        path("NanoStats.txt"), emit: stats_tsv
        path("NanoComp-data.tsv.gz"), emit: data
    shell:
        """
        id=\$(find -L ${dir} -type f -name '*.fastq.gz' | sed 's/.*_TIME_//g' | sed 's/.filt.fastq.gz//g' | sort -u)
        fastq=""
        for i in \$id; do fastq+=\$(find -L ${dir} -type f | grep \$i.filt.fastq.gz | sort -r | head -n1); fastq+=" "; done
        NanoComp -t ${task.cpus} --tsv_stats --raw --fastq \$fastq --names \$(echo \$fastq | sed 's/ /\\n/g' | sed 's/.*_//g' | sed 's/.filt.fastq.gz//g' | tr '\\n' ' ') -o .
        """
}