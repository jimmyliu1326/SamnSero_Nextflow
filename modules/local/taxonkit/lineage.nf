process taxonkit_rank2name {
    tag "Get target taxon name given target rank"
    label "process_low"

    input: 
        val(taxid)
        val(rank)
    output: stdout
    script:
        """
        IFS=';'        
        rank=( \$(taxonkit lineage -j ${task.cpus} <(echo ${taxid}) -R | cut -f3) )
        lineage=( \$(taxonkit lineage -j ${task.cpus} <(echo ${taxid}) -R | cut -f2) )
        idx=\$(printf '%s\\n' "\${rank[@]}" | grep -n ${rank} | sed 's/:${rank}\$//g')
        echo \${lineage[\$(( \$idx - 1 ))]} | tr -d '\\n'
        """
}