process vamb_concatenate {
    tag "Concatenating all assemblies"
    label "process_low"

    input:
        path(assembly)
    output:
        path("*.fasta.gz")
    shell:
        """
        concatenate.py --keepnames combined.fasta.gz *.fasta
        """
}