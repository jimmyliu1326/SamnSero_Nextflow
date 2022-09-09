process fastp {
    tag "Fastp QC on ${sample_id}"
    label "process_low"

    input: 
        tuple val(sample_id), path(reads)
        val(opts)
    output: 
        tuple val(sample_id), path("*.fastp.fastq.gz")
    shell:
        """
        prefix=\$(echo ${reads[0]} | sed 's/_R[1-2].fastq.*//g' | sed 's/_[1-2].fastq.*//g')
        fastp --in1 ${reads[0]} --in2 ${reads[1]} --out1 \${prefix}_1.fastp.fastq.gz --out2 \${prefix}_2.fastp.fastq.gz --thread ${task.cpus} ${opts}
        """
}