// taxonomic classifiers and viz tools for Nanopore workflows
process centrifuge {
    tag "Classifying reads for ${sample_id}"
    label "process_medium"

    input:
        tuple val(sample_id), path(reads)
        path(database_dir)
    output:
        tuple val(sample_id), path("*.report"), emit: report
        tuple val(sample_id), path("*.krona"), emit: krona
        tuple val(sample_id), path("*.kraken.report"), emit: kreport
    script:
        def watch = params.watchdir ?: ''
        def args = task.ext.args ?: ''
        """
        db_path=\$(find -L ${database_dir} -name "*.1.cf" -not -name "._*"  | sed 's/.1.cf//')
        
        if [[ ${params.seq_platform} == "illumina" ]]; then
            input="-1 ${reads[0]} -2 ${reads[1]}"
        else
            input="-U ${reads}"
        fi

        centrifuge \$input -S ${sample_id}.out --report ${sample_id}.report -x \$db_path -p ${task.cpus} --mm ${args}
        
        # insert sample ID if watchpath is invoked
        if test -z $watch; then
            
            cat ${sample_id}.out | cut -f1,3 > ${sample_id}.krona
            centrifuge-kreport -x \$db_path ${sample_id}.out > ${sample_id}.kraken.report
        
        else 

            cat ${sample_id}.out | cut -f1,3 | sed 's/\$/\t${sample_id}/' > ${sample_id}.krona
            centrifuge-kreport -x \$db_path ${sample_id}.out | sed 's/\$/\t${sample_id}/' > ${sample_id}.kraken.report

        fi
        """
}

process krona {
    tag "Generating Krona viz"
    label "process_low"
    publishDir "$params.out_dir"+"/reports/", mode: "copy"

    input:
        path(krona_input)
    output:
        file("taxonomy_classification.html")
    shell:
        """
        ktImportTaxonomy * -o taxonomy_classification.html
        """
}

process aggregate_kreport_watch {
    tag "Aggregating Centrifuge results"
    label "process_low"
    maxForks 1
    // publishDir "${params.out_dir}/timepoints/${res.first().getBaseName().replaceAll('_TIME_.*', '')}/qc/centrifuge", mode: 'copy', saveAs: { "kreport_res_aggregate.kraken.report" }

    input:
        path(res)
    output:
        file("centrifuge_res_aggregate_${res.first().getBaseName().replaceAll('_TIME_.*', '')}.kraken.report")
    script:
        def new_res = res.first()
        def timestamp = new_res.getBaseName().replaceAll('_TIME_.*', '')
        def cumulative_res = task.index != 1 ? res.last() : ''
        """
        awk 'NR == 1 || FNR > 1' ${new_res} ${cumulative_res} > centrifuge_res_aggregate_${timestamp}.kraken.report
        """
}

process aggregate_krona_watch {
    tag "Aggregating Centrifuge output for Krona"
    label "process_low"
    maxForks 1
    // publishDir "${params.out_dir}/timepoints/${res.first().getBaseName().replaceAll('_TIME_.*', '')}/qc/centrifuge", mode: 'copy', saveAs: { "centrifuge_res_aggregate.krona" }

    input:
        path(res)
    output:
        file("centrifuge_res_aggregate_${res.first().getBaseName().replaceAll('_TIME_.*', '')}.krona")
    script:
        def new_res = res.first()
        def timestamp = new_res.getBaseName().replaceAll('_TIME_.*', '')
        def cumulative_res = task.index != 1 ? res.last() : ''
        """
        awk 'NR == 1 || FNR > 1' ${new_res} ${cumulative_res} > centrifuge_res_aggregate_${timestamp}.krona
        """
}

process aggregate_krona_split {
    tag "Splitting Centrifuge output for Krona"
    label "process_low"
    maxForks 1
    //publishDir "${params.out_dir}/timepoints/${res.getSimpleName().replaceAll('centrifuge_res_aggregate_', '')}/qc/centrifuge", mode: 'copy', pattern: '*.krona'

    input:
        path(res)
    output:
        path('*.krona')
    script:
        def timestamp = res.getSimpleName().replaceAll('centrifuge_res_aggregate_', '')
        def id_col = 3
        """
        #!/usr/local/bin/Rscript
        # cat ${res} \
        #    | csvtk grep -H -t -T -f ${id_col} -r -p ${timestamp} \
        #    | csvtk mutate -t -T -H -f ${id_col} -R -p "_TIME_(\\S+)"  \
        #    | csvtk split -t -T -H -f ${id_col}
        
        #sed -i -r 's/(.*)\\s+[^\\s]+\$/\\1/' *.tsv
        #sed -i 's/"//g' *.tsv
        
        #find . -type f -name '*.tsv' -exec sh -c 'mv "\$1" "\$(echo "\$1" | sed s/stdin-// | sed s/tsv/krona/)"' _ {} \\;
        
        library(dplyr)
        library(stringr)
        library(tidyr)
        library(purrr)
        library(magrittr)
        library(tibble)
        library(data.table)
        
        df <- fread("${res}", header = F)
        current_id_tps <- df %>%
            separate(V3, into = c('timepoint', 'id'), sep = "_TIME_") %>%
            mutate(timepoint = as.numeric(timepoint)) %>%
            group_by(id) %>%
            arrange(desc(timepoint)) %>%
            slice(1) %>%
            mutate(id = paste(timepoint, id, sep = "_TIME_")) %>%
            pull(id)
        df_grp <- df %>%
            filter(V3 %in% current_id_tps) %>%
            mutate(V3 = str_replace_all(V3, ".*_TIME_", "")) %>%
            split(f = as.factor(.\$V3))
        
        walk2(names(df_grp), df_grp, function(x, y) {
            write.table(y, paste0(x, ".krona"), sep = "\t", quote = F, row.names = F, col.names = F)
        })

        """
}

process aggregate_kreport_split {
    tag "Splitting Centrifuge output"
    label "process_low"
    maxForks 1
    publishDir "${params.out_dir}/report_data/kreport", mode: 'copy', pattern: '*.kraken.report'
    //publishDir "${params.out_dir}/timepoints/${res.getSimpleName().replaceAll('centrifuge_res_aggregate_', '')}/qc/centrifuge", mode: 'copy', pattern: '*.tsv', saveAs: { file -> file.replaceAll('tsv', 'kraken.report') }
    input:
        path(res)
    output:
        path('*.tsv'), emit: tsv
        tuple val("${res.getSimpleName().replaceAll('centrifuge_res_aggregate_', '')}"), path('*_TIME_*.kraken.report'), emit: kreport
    script:
        def timestamp = res.getSimpleName().replaceAll('centrifuge_res_aggregate_', '')
        def id_col = 7
        """
        #!/usr/local/bin/Rscript
        # cat ${res} \
        #     | csvtk grep -H -t -T -f ${id_col} -r -p ${timestamp} \
        #     | csvtk mutate -t -T -H -f ${id_col} -R -p "_TIME_(\\S+)"  \
        #     | csvtk split -t -T -H -f ${id_col}
        
        # cat ${res} \
        #     | csvtk split -t -T -H -f ${id_col}
        
        # sed -i -r 's/(.*)\\s+[^\\s]+\$/\\1/' *.tsv
        # sed -i 's/"//g' *.tsv
        
        # find . -type f -name '*_TIME_*' -exec sh -c 'mv "\$1" "\$(echo "\$1" | sed s/stdin-// | sed s/tsv/kraken.report/)"' _ {} \\;

        library(dplyr)
        library(stringr)
        library(tidyr)
        library(purrr)
        library(magrittr)
        library(tibble)
        library(data.table)
        
        df <- fread("${res}", header = F)

        current_id_tps <- df %>%
            separate(V7, into = c('timepoint', 'id'), sep = "_TIME_") %>%
            mutate(timepoint = as.numeric(timepoint)) %>%
            group_by(id) %>%
            arrange(desc(timepoint)) %>%
            slice(1) %>%
            mutate(id = paste(timepoint, id, sep = "_TIME_")) %>%
            pull(id)

        current_df_grp <- df %>%
            filter(V7 %in% current_id_tps) %>%
            mutate(V7 = str_replace_all(V7, ".*_TIME_", "")) %>%
            split(f = as.factor(.\$V7))

        walk2(names(current_df_grp), current_df_grp, function(x, y) {
            write.table(y, paste0(x, ".tsv"), sep = "\t", quote = F, row.names = F, col.names = F)
        })

        all_df_grp <- df %>%
            split(f = as.factor(.\$V7))
        
        walk2(names(all_df_grp), all_df_grp, function(x, y) {
            write.table(y, paste0(x, ".kraken.report"), sep = "\t", quote = F, row.names = F, col.names = F)
        })
        """
}