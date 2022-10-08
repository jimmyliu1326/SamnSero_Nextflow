# load pkgs
library(ComplexHeatmap)
library(RColorBrewer)
library(circlize)
library(iheatmapr)

# calculate distance for string matrix
dist_str <- function(x, y) {
	x = strtoi(charToRaw(paste(x, collapse = "")), base = 16)
	y = strtoi(charToRaw(paste(y, collapse = "")), base = 16)
	sqrt(sum((x -y)^2))
}

# calculate heatmap dims
calc_ht_size = function(ht, unit = "inch") {
	pdf(NULL)
	ht = draw(ht)
	w = ComplexHeatmap:::width(ht)
	w = convertX(w, unit, valueOnly = TRUE)
	h = ComplexHeatmap:::height(ht)
	h = convertY(h, unit, valueOnly = TRUE)
	dev.off()
	
	c(w, h)
}

# plotting function
plot_full <- function(df, sistr_df) {
	annotation_cols <- sistr_df %>% 
		select(id, serovar) %>% 
		column_to_rownames("id")
	annotation_rows <- data.frame(
		"element" = rownames(df)) %>% 
		left_join(annot_types,
							by = "element") %>% 
		pull(type) %>% 
		factor(levels = annot_name)
	# get total sample count
	n <- nrow(sistr_df)
	# calculate cell dimensions based on n
	# cell_h <- case_when(n <= 30 ~ 4,
	# 										between(n, 31, 60) ~ 3,
	# 										between(n, 61, 90) ~ 2,
	# 										n >= 90 ~ 1) + 1
	#cell_w <- cell_h
	# calulate axis label font size
	# axis_fontsize <- case_when(n <= 30 ~ 10,
	# 													 between(n, 31, 60) ~ 8,
	# 													 between(n, 61, 90) ~ 6,
	# 													 n >= 90 ~ 4)
	
	
	p <- df %>% 
		rownames_to_column("element") %>% 
		mutate_at(vars(2:ncol(.)), ~ifelse(. == 0, "A", "P")) %>% 
		column_to_rownames("element") %>% 
		as.matrix() %>% 
		Heatmap(
			# split rows by gene feature type
			row_split = annotation_rows,
			row_title = NULL,
			# add block annotations for rows
			left_annotation = rowAnnotation(
				"foo" = anno_block(
					gp = gpar(fill = 2:4),
					labels = unique(annotation_rows),
					labels_gp = gpar(col = "white", fontsize = 10)
				)),
			clustering_distance_rows = dist_str,
			clustering_distance_columns = dist_str,
			# cluster_rows = F,
			# cluster_columns = F,
			col = structure(c("#DE2D26", "gray"), names = c("P", "A")),
			border = T,
			border_gp = gpar(col = "white", lwd = 2),
			rect_gp = gpar(col = "white"),
			row_names_gp = gpar(fontsize = 10),
			column_names_gp = gpar(fontsize = 10),
			height = unit(5, "mm")*nrow(.),
			width = unit(5, "mm")*ncol(.),
			#show_column_names = T
			heatmap_legend_param = list(
				title = "",
				labels = c("Present", "Absent"),
				at = c("P", "A"),
				nrow = 1
			),
			top_annotation = HeatmapAnnotation(
				gp = gpar(col = "gray"),
				#height = unit(5, "mm"),
				annotation_height = unit(c(10,3,3), "mm"),
				#simple_anno_size_adjust = T,
				annotation_label = "Serovar",
				annotation_name_gp = gpar(fontsize = 10),
				# objects
				"Serovar" = annotation_cols$serovar,
				col = list(
					"Serovar" = structure(c(brewer.pal(8, "Dark2"),
																	brewer.pal(8, "Accent"),
																	brewer.pal(8, "Set1"),
																	brewer.pal(8, "Set2"),
																	brewer.pal(8, "Set3"))[1:length(unique(annotation_cols$serovar))],
													 names = unique(annotation_cols$serovar))
				),
				annotation_legend_param = list(
					"Serovar" = list(
						title = "Serovar"
					)
				)
			)
		)
	# draw
	p
}

plot_type <- function(df, sistr_df) {
	annotation_cols <- sistr_df %>% 
		select(id, serovar) %>% 
		column_to_rownames("id")
	n <- nrow(sistr_df)
	# calculate cell dimensions based on n
	cell_h <- case_when(n <= 30 ~ 4,
											between(n, 31, 60) ~ 3,
											between(n, 61, 90) ~ 2,
											n >= 90 ~ 1) + 1
	cell_w <- cell_h
	# calulate axis label font size
	axis_fontsize <- case_when(n <= 30 ~ 10,
														 between(n, 31, 60) ~ 8,
														 between(n, 61, 90) ~ 6,
														 n >= 90 ~ 4)
	
	p <- df %>% 
		as.matrix() %>% 
		Heatmap(
			# split rows by gene feature type
			row_title = NULL,
			clustering_distance_rows = dist_str,
			clustering_distance_columns = dist_str,
			# cluster_rows = F,
			# cluster_columns = F,
			col = structure(c("#DE2D26", "gray"), names = c("P", "A")),
			border = T,
			border_gp = gpar(col = "white", lwd = 2),
			rect_gp = gpar(col = "white"),
			row_names_gp = gpar(fontsize = axis_fontsize),
			column_names_gp = gpar(fontsize = axis_fontsize),
			height = unit(cell_h, "mm")*nrow(.),
			width = unit(cell_w, "mm")*ncol(.),
			#show_column_names = T
			heatmap_legend_param = list(
				title = "",
				labels = c("Present", "Absent"),
				at = c("P", "A"),
				nrow = 1
			),
			top_annotation = HeatmapAnnotation(
				gp = gpar(col = "gray"),
				#height = unit(5, "mm"),
				annotation_height = unit(c(10,3,3), "mm"),
				#simple_anno_size_adjust = T,
				annotation_label = "Serovar",
				annotation_name_gp = gpar(fontsize = 10),
				# objects
				"Serovar" = annotation_cols$serovar,
				col = list(
					"Serovar" = structure(c(brewer.pal(8, "Dark2"), 
																	brewer.pal(8, "Accent"),
																	brewer.pal(8, "Set1"),
																	brewer.pal(8, "Set2"),
																	brewer.pal(8, "Set3"))[1:length(unique(annotation_cols$serovar))],
																names = unique(annotation_cols$serovar))
				),
				annotation_legend_param = list(
					"Serovar" = list(
						title = "Serovar"
					)
				)
			)
		)
	# draw
	p
}

plot_class <- function(df, sistr_df) {
	annotation_cols <- sistr_df %>% 
		select(id, serovar) %>% 
		column_to_rownames("id")
	max_val <- df %>% as.matrix() %>% as.numeric() %>% max(na.rm =T)
	min_val <- df %>% as.matrix() %>% as.numeric() %>% min(na.rm =T)
	n <- nrow(sistr_df)
	# calculate cell dimensions based on n
	cell_h <- case_when(n <= 30 ~ 4,
											between(n, 31, 60) ~ 3,
											between(n, 61, 90) ~ 2,
											n >= 90 ~ 1) + 1
	cell_w <- cell_h
	# calulate axis label font size
	axis_fontsize <- case_when(n <= 30 ~ 10,
														 between(n, 31, 60) ~ 8,
														 between(n, 61, 90) ~ 6,
														 n >= 90 ~ 4)
	
	p <- df %>% 
		as.matrix() %>% 
		Heatmap(
			col = colorRamp2(round(c(0, seq(1, max_val, length = 10))), 
											 rev(c(colorRampPalette(c(brewer.pal(n=11,"RdYlBu")[c(2:4,8:10)]))(10), "gray50"))),
			row_title = NULL,
			border = T,
			border_gp = gpar(col = "white", lwd = 2),
			rect_gp = gpar(col = "white"),
			row_names_gp = gpar(fontsize = axis_fontsize),
			column_names_gp = gpar(fontsize = axis_fontsize),
			height = unit(cell_h, "mm")*nrow(.),
			width = unit(cell_w, "mm")*ncol(.),
			# cluster_rows = F,
			# cluster_columns = F,
			na_col = "#878787",
			#show_column_names = T
			heatmap_legend_param = list(
				title = "Feature Count",
				legend_direction = "horizontal",
				legend_width = unit(5, "cm"),
				#labels = c("low", "medium", "high")#,
				at =round(seq(0, max_val, length = 4))
			),
			top_annotation = HeatmapAnnotation(
				gp = gpar(col = "gray"),
				#height = unit(5, "mm"),
				annotation_height = unit(c(10,3,3), "mm"),
				#simple_anno_size_adjust = T,
				annotation_label = "Serovar",
				annotation_name_gp = gpar(fontsize = 10),
				# objects
				"Serovar" = annotation_cols$serovar,
				col = list(
					"Serovar" = structure(c(brewer.pal(8, "Dark2"), 
																	brewer.pal(8, "Accent"),
																	brewer.pal(8, "Set1"),
																	brewer.pal(8, "Set2"),
																	brewer.pal(8, "Set3"))[1:length(unique(annotation_cols$serovar))],
																names = unique(annotation_cols$serovar))
				),
				annotation_legend_param = list(
					"Serovar" = list(
						title = "Serovar"
					)
				)
			)
		)
	# draw
	p
}

plotly_type <- function(df, sistr_df) {
	
	# get matrix dimensions
	row_n <- nrow(df)
	col_n <- ncol(df)
	
	if (row_n <= 15) { 
		col_annot_size = 1/row_n*0.4
		col_sum_size = 1/row_n*1.1
		y_len = 1/row_n*0.25*length(unique(sistr_df$serovar))
		label_buffer = 1/row_n*0.1
	} else { 
		col_annot_size = (1/row_n+0.0095)*0.85
		col_sum_size = (1/row_n+0.0075)*3
		y_len = (1/row_n+0.04)*0.5*length(unique(sistr_df$serovar))
		label_buffer = (1/row_n+0.0075)*0.5
	}
	
	# draw plotly heatmap
	p <- df %>% 
		as.matrix() %>% 
		iheatmap(colors = c("gray", "red"),
						 show_colorbar = F,
						 layout = list(margin = list(l = 400)),
						 colorbar_grid = setup_colorbar_grid(y_length = y_len),
						 text = df %>% 
						 	rownames_to_column("element") %>% 
						 	pivot_longer(cols = 2:ncol(.),
						 							 names_to = "id",
						 							 values_to = "value") %>% 
						 	left_join(sistr_df %>% select(id, serovar)) %>% 
						 	mutate(value = if_else(value == 1, "Present", "Absent"),
						 				 value = paste0(value, " (", serovar, ")")) %>% 
						 	select(-serovar) %>% 
						 	pivot_wider(names_from = "id",
						 							values_from = "value") %>% 
						 	column_to_rownames("element") %>% 
						 	as.matrix()) %>% 
		add_col_groups(sistr_df$serovar[match(colnames(df), sistr_df$id)],
									 title = "Serovar",
									 name = "Serovar",
									 size = col_annot_size,
									 buffer = label_buffer
									 ) %>%
		add_row_labels() %>% 
		add_col_summary(summary_function = "sum",
										size = col_sum_size,
										buffer = label_buffer) %>% 
		add_col_title("Number of unique features", side = "top")
	
	if (row_n != 1) { p <- p %>% add_row_clustering(side = "right") }
	
	
	p <- p %>% 
		add_col_clustering(side = "bottom") %>% 
		add_col_labels(side = "bottom",
									 buffer = label_buffer) 
	
	# return
	p
}

plotly_class <- function(df, sistr_df) {
	
	# get matrix dimensions
	row_n <- nrow(df)
	col_n <- ncol(df)
	
	# if (row_n <= 3) { 
	# 	col_annot_size = 0.7
	# 	col_sum_size = 0.8
	# } else { 
	# 	col_annot_size = 0.035
	# 	col_sum_size = 0.075
	# }
	
	if (row_n <= 15) { 
		col_annot_size = 1/row_n*0.5
		col_sum_size = 1/c(row_n)*1.1
		y_len = 1/c(row_n)*0.6
		label_buffer = 1/row_n*0.1
	} else { 
		col_annot_size = 1/row_n*1+0.0075
		col_sum_size = 1/c(row_n)*3.5
		y_len = 1/c(row_n)*1.75
		label_buffer = 1/row_n*0.5
	}
	
	# draw plotly heatmap
	p <- df %>% 
		as.matrix() %>% 
		iheatmap(colors = rev(c(brewer.pal(n=11,"RdYlBu")[c(2,6,10)])),
						 #show_colorbar = F,
						 name = "Feature count",
						 tooltip = setup_tooltip_options(prepend_value = "Feature count: "),
						 layout = list(margin = list(l = 400),
						 							size = 15),
						 colorbar_grid = setup_colorbar_grid(x_start = 1, y_start = 0.75),
						 text = df %>% 
						 	rownames_to_column("element") %>% 
						 	pivot_longer(cols = 2:ncol(.),
						 							 names_to = "id",
						 							 values_to = "value") %>% 
						 	left_join(sistr_df %>% select(id, serovar)) %>% 
						 	mutate(value = paste0(value, " (", serovar, ")")) %>% 
						 	select(-serovar) %>% 
						 	pivot_wider(names_from = "id",
						 							values_from = "value") %>% 
						 	column_to_rownames("element") %>% 
						 	as.matrix()) %>% 
		add_col_groups(sistr_df$serovar[match(colnames(df), sistr_df$id)],
									 title = "Serovar",
									 name = "Serovar",
									 size = col_annot_size,
									 buffer = label_buffer) %>% 
		add_row_labels() %>% 
		add_col_summary(summary_function = "sum",
										size = col_sum_size,
										buffer = label_buffer) %>% 
		add_col_title("Total features per sample", side = "top")
	
	if (row_n != 1) { p <- p %>% add_row_clustering(side = "right") }
	
	p <- p %>% 
		add_col_clustering(side = "bottom") %>% 
		add_col_labels(side = "bottom",
									 buffer = label_buffer) 
		
	
	# return
	p
}

plotly_full <- function(df, sistr_df) {
	
	annotation_rows <- data.frame(
		"element" = rownames(df)) %>% 
		left_join(annot_types,
							by = "element") %>% 
		pull(type) %>% 
		factor(levels = annot_name)
	
	# get matrix dimensions
	row_n <- nrow(df)
	col_n <- ncol(df)
	
	# create submatrix from combined matrix
	submat <- map(annot_name, function(x) {
		df %>% 
			rownames_to_column("element") %>% 
			filter(element %in% (annot_types %>% filter(type == x) %>% pull(element))) %>% 
			column_to_rownames("element")
	})
	
	# only keep non-empty sub matrices 
	submat <- submat[which(map_dbl(submat, ~return(nrow(.))) != 0)]
	
	# heatmap params
	if (nrow(df) < 10) { 
		col_annot_size = 1-0.15*nrow(df)
		col_sum_size = 0.8
		y_len = 0.65
	} else { 
		col_annot_size = 0.035
		col_sum_size = 0.075
		y_len = 0.04
	}
	
	if (nrow(submat[[1]]) < 10) { 
		h_size = 1-0.15*nrow(df)
	} else { 
		h_size = 0.5
	}
	
	# draw plotly heatmap
	p <- submat[[1]] %>% 
		as.matrix() %>% 
		iheatmap(colors = c("gray", "red"),
						 show_colorbar = F,
						 layout = list(margin = list(l = 400)),
						 colorbar_grid = setup_colorbar_grid(y_length = y_len),
						 text = submat[[1]] %>% 
						 	mutate_all(~if_else(. == 1, "Present", "Absent")) %>% 
						 	as.matrix(),
						 orientation = "vertical"
						 ) %>% 
		add_row_labels() %>% 
		add_row_title(title = annot_types %>% 
										filter(element == rownames(submat[[1]])[1]) %>% 
										mutate(type = as.character(type)) %>% 
										pull(type),
									buffer = 0.75)
	
	# add additional heatmaps
	if (length(submat) > 1) {
		
		# heatmap params
		if (nrow(submat[[2]]) < 10) { 
			h_size = 1-0.15*nrow(df)
		} else { 
			h_size = 0.5
		}
		
		p <- p %>%
			add_iheatmap(submat[[2]] %>% as.matrix(),
									 show_colorbar = F,
									 size = nrow(submat[[2]])/nrow(df)) %>% 
			add_row_labels() %>% 
			add_row_title(title = annot_types %>% 
											filter(element == rownames(submat[[2]])[1]) %>% 
											mutate(type = as.character(type)) %>% 
											pull(type),
										buffer = 0.75)
	}
	
	if (length(submat) > 2) {
		
		# heatmap params
		if (nrow(submat[[3]]) < 10) { 
			h_size = 1-0.15*nrow(df)
		} else { 
			h_size = 0.5
		}
		
		p <- p %>%
			add_iheatmap(submat[[3]] %>% as.matrix(),
									 show_colorbar = F,
									 size = nrow(submat[[2]])/nrow(df),
									 buffer = 0.01) %>% 
			add_row_labels() %>% 
			add_row_title(title = annot_types %>% 
											filter(element == rownames(submat[[3]])[1]) %>% 
											mutate(type = as.character(type)) %>% 
											pull(type),
										buffer = 0.75)
	}
	
	# return
	p %>% 
		add_col_groups(sistr_df$serovar[match(colnames(submat[[1]]), sistr_df$id)],
									 title = "Serovar",
									 name = "Serovar",
									 size = col_annot_size,
									 buffer = 0.01) %>% 
		add_col_labels() %>% 
		add_col_clustering(side = "bottom")
	
}

