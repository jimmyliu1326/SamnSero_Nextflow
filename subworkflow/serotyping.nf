// import modules
include { sistr; aggregate_sistr; aggregate_sistr_watch } from '../modules/local/sistr.nf'

workflow SEROTYPING {
    take: assembly
    main:
        if ( params.watchdir ) {

            sistr_res = sistr(assembly).map { it[1] }
            aggregate_sistr_watch.scan(sistr_res)
                | set { aggregate_res }

        } else {

            sistr(assembly)
                | map { it[1] }
                | collect
                | aggregate_sistr
                | set { aggregate_res }

        }
        
    emit:
        aggregate_res
}