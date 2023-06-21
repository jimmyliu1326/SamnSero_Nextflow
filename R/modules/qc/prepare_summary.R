source(file.path(src_dir, "src/samnsero_summary.R"))
combined_res <- combine_sistr_qc(quast_res, checkm_res, sistr_res_clean)
kreport_summary <- kreport_sum(kreport_res) %>% 
	left_join(target_res) %>% 
	mutate(target_count = target_count / 10^3,
				 target_bases = target_bases / 10^6) %>% 
	select(id, total, classified, unclassified, target_count, target_bases, everything())
kreport_class_res <- kreport_class_sum(kreport_res)
sistr_cols <- c("serogroup", "serovar", "serovar_antigen", "serovar_cgmlst", "qc_status", "qc_messages")
sistr_df <- combined_res %>% select(id, all_of(sistr_cols))
stats_df <- combined_res %>% select(-sistr_cols)