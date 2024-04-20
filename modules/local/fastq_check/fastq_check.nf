process fastq_check {
    tag "Checking FASTQ for ${sample_id}"
    label "process_low"
    errorStrategy 'ignore'
    cache false

    input:
        tuple val(sample_id), path(reads)
    output:
        tuple val(sample_id), path('*.fastq.gz')
    script:
        def ext = reads.getExtension()
        def cat_cmd = ext == 'gz' ? 'zcat' : 'cat'
        def out_prefix = reads.getSimpleName()
        def out_fastq = ext == 'gz' ? reads.getSimpleName() + '.copy.fastq.gz' : reads.getSimpleName() + '.copy.fastq'
        """
        # create local copy of current data
        cp ${reads} ${out_fastq}
        # verify integrity
        ${cat_cmd} ${out_fastq} > /dev/null
        # count lines
        n=\$(${cat_cmd} ${out_fastq} | wc -l)
        fastq_n=\$(( \$n / 4 ))
        # exit if less than 4 lines i.e. 0 reads
        if test \$fastq_n -lt 0; then echo 'Insufficient number of reads detected'; exit 1; fi 
        # expand fastq count and subset fastq
        n=\$(( \$fastq_n * 4 ))
        ${cat_cmd} ${out_fastq} | sed -n "1,\${n}p" | gzip > ${out_prefix}.fastq.gz.tmp
        mv ${out_prefix}.fastq.gz.tmp ${out_prefix}.fastq.gz
        # verify file integrity
        ${cat_cmd} ${out_prefix}.fastq.gz | \
            awk 'NR%4==2 || NR%4==0' | \
            paste - - | \
            awk '{if(length(\$1) != length(\$2)) {print "Read " NR/4 " has different number of bases and quality scores"; exit 1}}' \
            > /dev/null
        """
}