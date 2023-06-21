process taxonkit_name2taxid {
    tag "Converting taxon name to NCBI taxon ID"
    label "process_low"

    input: val(taxon_name)
    output: stdout
    shell:
        """
        echo $taxon_name | taxonkit name2taxid -j ${task.cpus} | cut -f2 | tr -d '\n'
        """
}