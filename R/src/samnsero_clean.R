# the following functions perform
# data wranling to prepare data frames
# for plotting and visualizations

vf_clean <- function(df) {
	df <- df %>% 
		select(1:6,10,11,13,14) %>% 
		rename("contig" = SEQUENCE,
					 "coverage" = "%COVERAGE",
					 "identity" = "%IDENTITY"
		) %>% 
		mutate(PRODUCT = str_replace_all(PRODUCT, " \\[.*", ""),
					 PRODUCT = str_replace_all(PRODUCT, ".*\\) ", "")) %>% 
		select(1, 6, 8, 7, 2, 9, 10, 3:5) %>% 
		mutate(idx = paste(id, contig, sep = "-"))
	colnames(df) <- tolower(colnames(df))
	# return
	df
}

sistr_clean <- function(df) {
	df %>% 
		mutate(serovar = if_else(str_detect(serovar, "\\|"), "Unresolved", serovar),
					 serovar_antigen = if_else(str_detect(serovar_antigen, "\\|"), "Unresolved", serovar_antigen),
					 serovar_cgmlst = if_else(str_detect(serovar_cgmlst, "\\|"), "Unresolved", serovar_cgmlst))
}

rgi_clean <- function(df) {
	df %>% 
		select(c(2:5, 9:11, 13,15:17,21,26)) %>% 
		rename("name" = "Best_Hit_ARO",
					 "end" = "Stop",
					 "identity" = "Best_Identities",
					 "coverage" = "Percentage Length of Reference Sequence",
					 "strand" = "Orientation",
					 "snps" = "SNPs_in_Best_Hit_ARO",
					 "contig" = "Contig",
					 "start" = "Start") %>% 
		select("id", "ARO", "name", "Drug Class", "identity", "coverage", 
					 "contig", "Resistance Mechanism", "AMR Gene Family", "snps",
					 "start", "end", "strand"
		) %>% 
		mutate(coverage = if_else(coverage < 0, coverage*-1, coverage),
					 coverage = if_else(coverage > 100, 100, coverage),
					 "Drug Class" = str_replace_all(`Drug Class`, " antibiotic", "")) %>% 
		mutate(idx = paste(id, contig, sep = "-")) %>% 
		group_by(idx) %>% 
		mutate(combined_class = paste(`Drug Class`, collapse = "; "),
					 combined_class = map_chr(combined_class, function(x) {
					 	# split into a vector of class
					 	class <- unlist(str_split(x, "; "))
					 	# count
					 	count <- as.data.frame(table(class))
					 	colnames(count) <- c("val", "freq")
					 	# return string
					 	count %>%
					 		mutate(str = paste0(val, " (", freq, ")")) %>%
					 		pull(str) %>%
					 		paste(collapse = "; ")
					 	
					 })) %>%
		ungroup()
}

plasmid_clean <- function(df) {
	df %>% 
		select(1,3,4,18,14, 27, 6,8, 10, 12, 21,23,25,26) %>% 
		rename("rep_type" = "rep_type(s)",
					 "relaxase_type" = "relaxase_type(s)",
					 "orit_type" = "orit_type(s)",
					 "predicted_host" = "predicted_host_range_overall_name",
					 "observed_host" = "observed_host_range_ncbi_name",
					 "reported_host" = "reported_host_range_lit_name",
					 "pmid" = "associated_pmid(s)") %>% 
		mutate_at(vars(6:12), ~str_replace_all(.,",", ", ")) %>% 
		mutate(idx = paste(id, contig, sep = "-"))
}