source(file.path(src_dir, "src/samnsero_load.R"))

# read sistr results
sistr_res <- load_sistr(sistr_path)

# load annotation results - one row per feature
if (file.exists(plasmid_res_path)) plasmid_res <- load_mob_suite_res(plasmid_res_path)
if (file.exists(amr_res_path)) amr_res <- load_rgi(amr_res_path)
if (file.exists(vf_res_path)) vf_res <- fread(vf_res_path)

# CARD ontology ID mapping
aro_path <- file.path(src_dir, "data/aro/aro.tsv")
aro <- fread(aro_path, sep = "\t", header = T)

# read annotation summary
annot_summary <- map(annot_summary_files, function(x) {
	file_path <- file.path(annot_dir, "summary", x)
	if (file.exists(file_path)) {
		fread(file.path(annot_dir, "summary", x)) %>%
			mutate_at(vars(2:ncol(.)), ~as.character(.))
	}
})

# analyze annot_summary if not empty
if (is_empty(annot_summary) == F) {
	# get sample list from summary data
	samples <- annot_summary[[1]]$id
	
	# combine a list of summary df to a single combined summary with all annotations
	aggregate_summary <- map(annot_summary, ~pivot_longer(., cols = 2:ncol(.),
																												names_to = "element",
																												values_to = "identity"))
	
	# get annotation type of each element
	annot_types <- map2_dfr(annot_name, aggregate_summary, function(x, y) {
		y %>% 
			mutate(type = x) %>% 
			select(element, type) %>% 
			distinct()
	}) %>%
		mutate(type = factor(type,
												 levels = annot_name))	
}
