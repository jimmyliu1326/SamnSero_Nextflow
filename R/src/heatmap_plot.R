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
			col = structure(c("#DE2D26", "gray"), names = c("P", "A")),
			border = T,
			border_gp = gpar(col = "white", lwd = 2),
			rect_gp = gpar(col = "white"),
			row_names_gp = gpar(fontsize = 10),
			column_names_gp = gpar(fontsize = 10),
			height = unit(4, "mm")*nrow(.),
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
					"Serovar" = structure(c(brewer.pal(8, "Dark2"), brewer.pal(8, "Accent"))[1:length(unique(annotation_cols$serovar))],
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
	draw(p, heatmap_legend_side = "top", annotation_legend_side = "left")
}

plot_type <- function(df, sistr_df) {
	annotation_cols <- sistr_df %>% 
		select(id, serovar) %>% 
		column_to_rownames("id")
	
	p <- df %>% 
		as.matrix() %>% 
		Heatmap(
			# split rows by gene feature type
			row_title = NULL,
			clustering_distance_rows = dist_str,
			clustering_distance_columns = dist_str,
			col = structure(c("#DE2D26", "gray"), names = c("P", "A")),
			border = T,
			border_gp = gpar(col = "white", lwd = 2),
			rect_gp = gpar(col = "white"),
			row_names_gp = gpar(fontsize = 10),
			column_names_gp = gpar(fontsize = 10),
			height = unit(5, "mm")*nrow(.),
			width = unit(6, "mm")*ncol(.),
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
					"Serovar" = structure(c(brewer.pal(8, "Dark2"), brewer.pal(8, "Accent"))[1:length(unique(annotation_cols$serovar))],
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
	draw(p, heatmap_legend_side = "top",annotation_legend_side = "left")
}

plot_class <- function(df, sistr_df) {
	annotation_cols <- sistr_df %>% 
		select(id, serovar) %>% 
		column_to_rownames("id")
	max_val <- df %>% as.matrix() %>% as.numeric() %>% max(na.rm =T)
	min_val <- df %>% as.matrix() %>% as.numeric() %>% min(na.rm =T)
	p <- df %>% 
		as.matrix() %>% 
		Heatmap(
			col = colorRamp2(seq(min_val, max_val, length = 10), 
											 rev(colorRampPalette(c(brewer.pal(n=11,"RdYlBu")[c(2:4,8:10)]))(10))),
			row_title = NULL,
			border = T,
			border_gp = gpar(col = "white", lwd = 2),
			rect_gp = gpar(col = "white"),
			row_names_gp = gpar(fontsize = 10),
			column_names_gp = gpar(fontsize = 10),
			height = unit(6, "mm")*nrow(.),
			width = unit(6, "mm")*ncol(.),
			na_col = "#878787",
			#show_column_names = T
			heatmap_legend_param = list(
				title = "Feature Count",
				legend_direction = "horizontal",
				legend_width = unit(5, "cm"),
				#labels = c("low", "medium", "high")#,
				at =seq(1,max_val, length = 4)
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
					"Serovar" = structure(c(brewer.pal(8, "Dark2"), brewer.pal(8, "Accent"))[1:length(unique(annotation_cols$serovar))],
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
	draw(p, heatmap_legend_side = "top", annotation_legend_side = "left")
}

