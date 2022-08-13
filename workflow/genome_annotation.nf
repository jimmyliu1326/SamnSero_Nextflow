// import modules
include { abricate; abricate_summary; abricate_custom; makeblastdb } from '../modules/local/abricate.nf'
include { annot_report } from '../modules/local/report.nf'
include { mob_suite; aggregate_mob_suite; mob_suite_summary; mob_suite_merge } from '../modules/local/mob-suite.nf'
include { rgi; aggregate_rgi; rgi_summary } from '../modules/local/rgi.nf'
include { cctyper; tnblast; aggregate_cctyper } from '../modules/local/crisprs.nf'
include { mafft } from '../modules/local/msa.nf'

workflow ANNOT {
    take: assembly
    main:
        // run abricate for VF prediction
        db = ['vfdb']

        assembly
            | combine(db)
            | abricate
            | groupTuple
            | abricate_summary

        abricate_combined_flat = abricate_summary.out.summary
            | collect
            | concat(abricate_summary.out.aggregate_res.collect())

        // if ( params.custom_db ) {
        //     custom_db_l = channel.fromPath(params.custom_db, checkIfExists: true).splitCsv(header: false)
        //     makeblastdb(custom_db_l)
        //     db = makeblastdb.out
        //     abricate_custom(assembly.combine(db)) 
        //     abricate_summary(abricate_custom.out.concat(abricate.out).groupTuple())
        // } else {
        //     abricate_summary(abricate.out.groupTuple())
        // }

        // get samples.list for annot results transposition
        samples = channel
            .fromPath(params.input, checkIfExists: true)
        
        // run mob-suite for plasmid prediction
        assembly
            | mob_suite
            | mob_suite_merge
            | map { it[1] }
            | collect
            | aggregate_mob_suite

        mob_suite_summary(aggregate_mob_suite.out, samples)
        
        mob_suite_summary.out.concat(aggregate_mob_suite.out)
            | set { mob_suite_combined_flat }
        
        // aggregate and summarize mob suite results if the result array is not empty
        

        // run rgi for AMR prediction
        assembly
            | rgi
            | map { it[1] }
            | collect
            | aggregate_rgi

        rgi_summary(aggregate_rgi.out, samples)

        rgi_summary.out
            | concat(aggregate_rgi.out)
            | set { rgi_combined_flat }

        // run tnblast to identify crispr loci
        primers = channel
            .fromPath("${projectDir}/data/crispr_primers/crispr_primers.txt")

        assembly
            | combine(primers)
            | tnblast
        
        // transpose tnblast output to return one tuple per crispr locus
        tnblast.out
            | transpose
            | map { id, path -> 
                locus_id = path.toString().replaceAll(/.*CRISPR_|.fa/, "").toInteger()
                return tuple(id, path, locus_id)
                }
            | filter { it.size() > 0 } // only continue if at least 1 element emitted by channel
            | set { crisprs_ch }
            
        
        // annotate the crispr arrays if the tnblast results are not empty
            
        // crispr locus typing using cctyper
        cctyper(crisprs_ch)

        // combine cctyper res
        cctyper.out.typing_res
            | map { [ it[2], it[1] ]}
            | groupTuple(by: 0)
            | aggregate_cctyper

        
        // msa crispr locus sequences if analyzing more than 1 sample
        crisprs_ch
            | map { [ it[2], it[1] ]}
            | groupTuple(by: 0)
            | filter { it[1].size() > 2} // only continue if 2 or more elements per locus emitted by channel
            | mafft

    emit:
        rgi_combined_flat \
            | concat(abricate_combined_flat, mob_suite_combined_flat) \
            | collect
}