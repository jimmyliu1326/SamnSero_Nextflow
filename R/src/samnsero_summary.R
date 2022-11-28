annot_sum2mat <- function(df, var_only=F) {
	
		var_df <- df %>%  
			reduce(left_join, by = "id") %>% 
			column_to_rownames("id") %>% 
			t() %>%
			as.data.frame() %>% 
			rownames_to_column("id") %>% 
			mutate_at(vars(2:ncol(.)), ~ifelse(. == ".", 0, 1)) %>% 
			rowwise() %>% 
			mutate(var = var(c_across(2:ncol(.))))
			
	if (var_only == T) {
		
		var_df %>% 
			filter(var != 0) %>% 
			select(-var) %>% 
			filter(!(id %in% c("GENE", "NUM_FOUND"))) %>% 
			#mutate_at(vars(2:ncol(.)), ~ifelse(. == 0, "A", "P")) %>% 
			column_to_rownames("id")	
		
	} else {
		
		var_df %>% 
			select(-var) %>% 
			filter(!(id %in% c("GENE", "NUM_FOUND"))) %>% 
			#mutate_at(vars(2:ncol(.)), ~ifelse(. == 0, "A", "P")) %>% 
			column_to_rownames("id")	
		
	}
}

amr_class_sum <- function(df) {
	df %>%  
		# select(id, name, `Drug Class`, `snps`, start, end, strand) %>% 
		# distinct() %>% 
		group_by(id, name) %>% 
		group_split() %>% 
		map(., function(x) {
			# split drug class into vector
			class <- unlist(str_split(x$`Drug Class`, "; "))
			# return
			data.frame(id = x$id[1],
								 name = x$name[1],
								 "Drug Class" = class)
		}) %>% 
		bind_rows() %>% 
		rename("Drug Class" = "Drug.Class") %>% 
		group_by(id, `Drug Class`) %>% 
		tally() %>%
		mutate(id = factor(id, levels = samples)) %>% 
		pivot_wider(names_from = "id",
								values_from = "n",
								values_fill = 0,
								names_expand = T) %>% 
		column_to_rownames("Drug Class")
}

getSummaryType <- function(df, type_id) {
	df %>% 
		rownames_to_column("id") %>% 
		filter(id %in% (annot_types %>% 
											filter(type == type_id) %>% 
											pull(element))) %>% 
		column_to_rownames("id")
}

combine_sistr_qc <- function(quast_res, checkm_res, sistr_res) {
	quast_res %>%
		select(id, "# contigs", "Total length", "# N's per 100 kbp", "N50", "Avg. coverage depth") %>%
		left_join(checkm_res %>% 
								select(id, Completeness, Contamination, `Strain heterogeneity`), by = "id") %>%
		left_join(sistr_res %>%
								select(id, serogroup, serovar, qc_status, qc_messages),
							by = "id"
		) %>%
		select(id, serogroup, serovar, qc_status,
					 qc_messages, "Total length",
					 Completeness, Contamination, 
					 "Strain heterogeneity", everything()) %>%
		# clean columns
		mutate(`Total length` = `Total length`/1000000,
					 N50 = N50/1000000,
					 serovar = if_else(str_detect(serovar, "\\|"), "Unresolved", serovar)) %>% 
		select(-qc_messages, everything())
}

kreport_sum <- function(df) {
	df %>% 
		group_by(id) %>% 
		group_split() %>% 
		map_dfr(function(x) {
			# get id
			id <- x$id[1]
			#print(id)
			# calc unclassified reads
			unclassified <- x %>% 
				filter(level == "U") %>% 
				pull(percent)
			
			# calc classified reads
			classified <- 100-unclassified
			
			# calc total number of reads
			total_count <- x %>% 
				filter(taxid %in% c(0, 1)) %>% 
				pull(count) %>% 
				sum()
			# calc bacterial reads
			bacteria <- x %>% filter(name == "Bacteria") %>% pull(percent)
			if (length(bacteria) == 0) bacteria <- 0
			# calc viral reads
			virus <- x %>% filter(name == "Viruses") %>% pull(percent)
			if (length(virus) == 0) virus <- 0
			# calc eukaryotic reads
			eukaryota <- x %>% filter(name == "Eukaryota") %>% pull(percent)
			if (length(eukaryota) == 0) eukaryota <- 0
			# calc archaeal reads
			archaea <- x %>% filter(name == "Archaea") %>% pull(percent)
			if (length(archaea) == 0) archaea <- 0
			# calc synthetic reads
			artificial <- x %>% filter(name == "artificial sequences") %>% pull(percent)
			if (length(artificial) == 0) artificial <- 0
			
			data.frame(id = id,
								 total = total_count,
								 classified = classified,
								 unclassified = unclassified,
								 bacteria = bacteria,
								 virus = virus,
								 eukaryota = eukaryota,
								 archaea = archaea,
								 artificial = artificial
			)
		})
}

kreport_class_sum <- function(df) {
	# create classification results table by domain
	kreport_class_res <- df %>% 
		# change domain level of 'artificial sequences' from '-' to 'D'
		mutate(level = case_when(name == "artificial sequences" ~ "D",
														 T ~ level),
					 name = str_replace_all(name, "artificial sequences", "Artificial sequences")) %>% 
		filter(level %in% c("D","S"))
	
	tax_levels <- kreport_class_res$level
	# split the species into domain groups (D)
	tax_groups <- cut(seq_along(tax_levels), which(c(tax_levels,"D") == "D"), labels = F, right=F)
	tax_groups_idx <- split(seq_along(tax_levels), tax_groups)
	# get the domain of each species group
	domain_group <- unlist(map(tax_groups_idx, ~return(rep(kreport_class_res$name[.[1]], length(.)))))
	# add domain group to class results table
	kreport_class_res %>% 
		mutate(domain = domain_group) %>% 
		pivot_wider(id_cols = c("level", "taxid", "name", "domain"),
								names_from = "id", values_from= "percent") %>% 
		filter(level != "D") %>% 
		select(-level) %>% 
		select(name, taxid, domain, everything()) %>% 
		mutate_at(vars(4:ncol(.)), ~if_else(is.na(.), 0, .))
}
