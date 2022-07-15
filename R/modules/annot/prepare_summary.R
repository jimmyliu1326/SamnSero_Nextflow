source(file.path(src_dir, "src/samnsero_summary.R"))
if (exists("amr_res_clean")) amr_drug_summary <- amr_class_sum(amr_res_clean)
if (!is_empty(annot_summary)) {
	# create presence/absence matrix of each annotation type
	tidy_res <- annot_sum2mat(annot_summary, var_only = F)
	plasmid_summary <- getSummaryType(tidy_res, "Plasmid")
	amr_summary <- getSummaryType(tidy_res, "AMR")
	vf_summary <- getSummaryType(tidy_res, "Virulence Factor")
	# create presence/absence matrix of each annotation type (variable elements only)
	tidy_res_var <- annot_sum2mat(annot_summary, var_only = T)
	plasmid_summary_var <- getSummaryType(tidy_res_var, "Plasmid")
	amr_summary_var <- getSummaryType(tidy_res_var, "AMR")
	vf_summary_var <- getSummaryType(tidy_res_var, "Virulence Factor")
	
}

