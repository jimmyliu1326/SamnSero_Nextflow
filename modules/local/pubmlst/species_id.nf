process pubmlst_species_id {
    tag "Predicting species ID by rMLST for ${sample_id}"
    label "process_low"
    maxForks 10

    input:
        tuple val(sample_id), path(assembly)
        val(target_taxon)
    output:
        tuple val(sample_id), path("*.species_id"), emit: results
        tuple val(sample_id), env(target), emit: target
    shell:
        """
        pubmlst_species_id.py --file ${assembly} > ${sample_id}.species_id
        
        if grep -q "${target_taxon}" *.species_id; then
            target='true'
        else
            target='false'
        fi

        """
}