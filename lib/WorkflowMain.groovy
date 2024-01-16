//
// This file holds several functions specific to the main.nf workflow in the jimmyliu1326/SamnSero_Nextflow pipeline
//

class WorkflowMain {

    //
    // Citation string for pipeline
    //
    public static String citation(workflow) {
        return "If you use ${workflow.manifest.name} for your analysis please cite:\n\n" +
            // TODO nf-core: Add Zenodo DOI for pipeline after first release
            //"* The pipeline\n" +
            //"  https://doi.org/10.5281/zenodo.XXXXXXX\n\n" +
            "* The nf-core framework\n" +
            "  https://doi.org/10.1038/s41587-020-0439-x\n\n" +
            "* Software dependencies\n" +
            "  https://github.com/${workflow.manifest.name}/blob/master/CITATIONS.md"
    }

    //
    // Print help to screen if required
    //
    public static String help(workflow, params, log) {
        def command = "nextflow run jimmyliu1326/SamnSero_Nextflow -r [version] --input samplesheet.csv"
        def help_string = ''
        help_string += NfcoreTemplate.logo(workflow, params.monochrome_logs)
        help_string += NfcoreSchema.paramsHelp(workflow, params, command)
        help_string += '\n' + citation(workflow) + '\n'
        help_string += NfcoreTemplate.dashedLine(params.monochrome_logs)
        return help_string
    }

    //
    // Print parameter summary log to screen
    //
    public static String paramsSummaryLog(workflow, params, log) {
        def summary_log = ''
        summary_log += NfcoreTemplate.logo(workflow, params.monochrome_logs)
        summary_log += NfcoreSchema.paramsSummaryLog(workflow, params)
        summary_log += '\n' + citation(workflow) + '\n'
        summary_log += NfcoreTemplate.dashedLine(params.monochrome_logs)
        return summary_log
    }

    //
    // Validate parameters and print summary to screen
    //
    public static void initialise(workflow, params, log, schema_filename='nextflow_schema.json') {
        // Print help to screen if required
        if (params.help) {
            log.info help(workflow, params, log)
            System.exit(0)
        }

        // Print pipeline version if --version is invoked
        if (params.version) {
            log.info "${workflow.manifest.name} ${workflow.manifest.version}"
            System.exit(0)
        }

        // Validate workflow parameters via the JSON schema
        NfcoreSchema.validateParameters(workflow, params, log)

        // Print parameter summary log to screen
        log.info paramsSummaryLog(workflow, params, log)

        // check if input sample sheet exists
        if ( params.input ) {
            if ( !Utils.fileExists(params.input) ) {
                log.error "Please provide a valid path to the input sample sheet"
            System.exit(1)
            }
        }

        // check if taxon name contains non-empty values
        // when --qc is invoked
        if ( params.qc & params.taxon_name == true ) {
            log.error "Parameter taxon_name is empty"
            System.exit(1)
        }

        // check if centrifuge database exists
        // when --qc is invoked
        if (params.qc) {
            if (!Utils.fileExists(params.centrifuge)) {
                log.error "Please provide a valid path to the Centrifuge database"
                System.exit(1)
            }
        }
    }
}
