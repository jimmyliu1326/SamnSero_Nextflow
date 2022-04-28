// import modules
include { abricate; abricate_summary; abricate_custom; makeblastdb } from '../modules/local/abricate.nf'

workflow ANNOT {
    take: assembly
    main:
        if ( !params.custom_db ) {
            db = ["card", "vfdb", 'plasmidfinder']
            abricate(assembly.combine(db))
            abricate_summary(abricate.out.groupTuple())
        } else {
            custom_db_l = channel.fromPath(params.custom_db, checkIfExists: true).splitCsv(header: false)
            makeblastdb(custom_db_l)
            db = makeblastdb.out
            abricate_custom(assembly.combine(db)) 
            abricate_summary(abricate_custom.out.groupTuple())
        }
}