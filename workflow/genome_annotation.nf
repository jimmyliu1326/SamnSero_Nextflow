// import modules
include { abricate; abricate_summary; abricate_custom; makeblastdb } from '../modules/local/abricate.nf'
include { annot_report } from '../modules/local/report.nf'

workflow ANNOT {
    take: assembly
    main:
        // run abricate for VF and custom marker prediction
        db = ['vfdb']
        abricate(assembly.combine(db))
            
        if ( params.custom_db ) {
            custom_db_l = channel.fromPath(params.custom_db, checkIfExists: true).splitCsv(header: false)
            makeblastdb(custom_db_l)
            db = makeblastdb.out
            abricate_custom(assembly.combine(db)) 
            abricate_summary(abricate_custom.out.concat(abricate.out).groupTuple())
        } else {
            abricate_summary(abricate.out.groupTuple())
        }

        // run mob-suite for plasmid prediction
        

        // run rgi for AMR prediction

    emit: abricate_summary.out 
}