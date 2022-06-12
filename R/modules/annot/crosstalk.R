amr_data <- SharedData$new(unique(amr_res_clean[,c("id", "contig", "idx", "combined_class")]),
													 key = ~idx)
vf_data <- SharedData$new(unique(vf_res_clean[,c("id", "contig", "idx")]), 
													group = amr_data$groupName(), 
													key = ~idx)
plasmid_data <- SharedData$new(plasmid_res_clean, 
															 group = amr_data$groupName(),
															 key = ~idx)