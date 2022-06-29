source(file.path(src_dir, "src/samnsero_summary.R"))
if (exists("amr_res_clean")) amr_drug_summary <- amr_class_sum(amr_res_clean)
if (!is_empty(annot_summary)) {
	tidy_res <- annot_sum2mat(annot_summary)
	plasmid_summary <- getSummaryType("Plasmid")
	amr_summary <- getSummaryType("AMR")
	vf_summary <- getSummaryType("Virulence Factor")
}

