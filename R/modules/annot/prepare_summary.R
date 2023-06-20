source(file.path(src_dir, "src/samnsero_summary.R"))
if (exists("amr_res_clean")) amr_drug_summary <- amr_class_sum(amr_res_clean)
if (!is_empty(annot_summary)) {
	# create presence/absence matrix of each annotation type
	tidy_res <- annot_sum2mat(annot_summary, var_only = F) %>% select(sistr_res_clean$id)
	plasmid_summary <- getSummaryType(tidy_res, "Plasmid") %>% select(sistr_res_clean$id)
	amr_summary <- getSummaryType(tidy_res, "AMR") %>% select(sistr_res_clean$id)
	vf_summary <- getSummaryType(tidy_res, "Virulence Factor") %>% select(sistr_res_clean$id)
	# create presence/absence matrix of each annotation type (variable elements only)
	tidy_res_var <- annot_sum2mat(annot_summary, var_only = T) %>% select(sistr_res_clean$id)
	plasmid_summary_var <- getSummaryType(tidy_res_var, "Plasmid") %>% select(sistr_res_clean$id)
	amr_summary_var <- getSummaryType(tidy_res_var, "AMR") %>% select(sistr_res_clean$id)
	vf_summary_var <- getSummaryType(tidy_res_var, "Virulence Factor") %>% select(sistr_res_clean$id)
}

