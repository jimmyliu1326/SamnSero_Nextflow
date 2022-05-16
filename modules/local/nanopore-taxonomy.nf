// taxonomic classifiers for Nanopore workflows
process centrifuge {
    tag "Classifying reads for ${reads.baseName}"
    label "process_medium"
    //publishDir "$params.outdir"+"/taxon_class/", mode: "copy"

    input:
        path(reads)
        path(database)
    output:
        out=file("${reads.simpleName}/*.out")
        report=file("${reads.simpleName}/*.report")
        krona=file("${reads.simpleName}/*.krona")
    shell:
        """
        centrifuge -U ${reads} -S ${reads.simpleName}/centrifuge.out --report ${reads.simpleName}/centrifuge.report -k 1 -x ${database} -p ${task.cpus}
        cat centrifuge.out | cut -f1,3 > ${reads.simpleName}/${reads.simpleName}.krona
        """
}

process krona {
    tag "Generating Krona viz"
    label "process_medium"
    //publishDir "$params.outdir"+"/taxon_class/", mode: "copy"

    input:
        path(reads)
        path(database)
    output:
        out=file("${reads.simpleName}/*.out")
        report=file("${reads.simpleName}/*.report")
        krona=file("${reads.simpleName}/*.krona")
    shell:
        """
        centrifuge -U ${reads} -S ${reads.simpleName}/centrifuge.out --report ${reads.simpleName}/centrifuge.report -k 1 -x ${database} -p ${task.cpus}
        cat centrifuge.out | cut -f1,3 > ${reads.simpleName}/${reads.simpleName}.krona
        """
}