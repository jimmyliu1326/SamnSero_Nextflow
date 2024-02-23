# load helper funcs
source(file.path(src_dir, "src/samnsero_summary.R"))

# combine serotyping and assembly stat results
combined_res <- combine_sistr_qc(quast_res, checkm_res, sistr_res_clean)

# taxonomic summary
kreport_summary <- kreport_sum(kreport_res) %>% 
	left_join(target_res) %>% 
	# convert to K for reads and M for bases
	mutate(target_count = target_count / 10^3, 
				 total = total / 10^3,
				 target_bases = target_bases / 10^6,
				 total_bases = total_bases / 10^6) %>% 
	select(-total_count) %>% # remove total_count column from target_res, as it is already provided by kreport_summary
	select(id, total, total_bases, classified, unclassified, target_count, target_bases, everything())

kreport_class_res <- kreport_class_sum(kreport_res)

# process timepoint data
if ( rt ) { 
	# convert timepoint data from ms to minutes
	tp_data <- kreport_summary %>% 
		left_join(combined_res, by = "id") %>% 
		tp_process()
	# filter df
	combined_res %<>% tp_filter()
	kreport_summary %<>% tp_filter()
}

# create labels column
combined_res %<>% mutate(labels = id)

# create reactable dfs
sistr_cols <- c("serogroup", "serovar", "serovar_antigen", "serovar_cgmlst", "qc_status", "qc_messages")
sistr_df <- combined_res %>% select(id, all_of(sistr_cols))
stats_df <- combined_res %>% select(-sistr_cols)

# metagenomic binning check
binning <- any(str_detect(sistr_res$id, "_BIN_"))

# process bins
if (binning) {
	sistr_df %<>% separate(id, into = c("id", "bin"), sep = "_BIN_")
	stats_df %<>% separate(id, into = c("id", "bin"), sep = "_BIN_")
	combined_res %<>% separate(id, into = c("id", "bin"), sep = "_BIN_") %>% mutate(labels = paste0(id, " (", bin, ")"))
}



