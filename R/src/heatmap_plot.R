# load pkgs
library(ComplexHeatmap)
library(RColorBrewer)
library(circlize)

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
			row_split = annotation_rows,
			row_title = NULL,
			# add block annotations for rows
			left_annotation = rowAnnotation(
				"foo" = anno_block(
					gp = gpar(fill = 2:4),
					labels = annot_name,
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

