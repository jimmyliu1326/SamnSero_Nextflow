process MMSEQS2_EASY_TAXONOMY {
    tag "Assigning taxonomic classification at contig level for ${sample_id}"
    label "process_medium"

    input:
        tuple val(sample_id), path(genome)
        path(database)
    output:
        tuple val(sample_id), path("*_lca.tsv")
    script:
        def chunk_memory = task.memory.toGiga()
        """
        DB_PATH=\$(find -L ${database} -maxdepth 1 -name '*.dbtype' | sed -e 'N;s/^\\(.*\\).*\\n\\1.*\$/\\1/')
        mmseqs easy-taxonomy \
            ${genome} \
            \$DB_PATH \
            ./${sample_id} \
            tmp \
            --threads ${task.cpus} \
            --split-memory-limit ${chunk_memory}G \
            --orf-filter 1 \
            -s 1 \
            --lca-ranks superkingdom,phylum,class,order,family,genus,species
        """
}