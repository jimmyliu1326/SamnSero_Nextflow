if (exists("amr_res_clean")) amr_data <- SharedData$new(unique(amr_res_clean[,c("id", "contig", "idx", "combined_class")]),
													 key = ~idx)
if (exists("vf_res_clean")) vf_data <- SharedData$new(unique(vf_res_clean[,c("id", "contig", "idx")]), 
													group = amr_data$groupName(), 
													key = ~idx)
if (exists("plasmid_res_clean")) plasmid_data <- SharedData$new(plasmid_res_clean, 
															 group = amr_data$groupName(),
															 key = ~idx)