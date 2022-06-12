gob <- c( "#F5736D", "#F6D57C", "#66C76B")

gob_pal <- function(x, y) {
	if (!is.na(x))
		rgb(colorRamp(gob, bias = y)(x), maxColorValue = 255)
	else
		NULL
}

gob_rev_pal <- function(x, y) {
	if (!is.na(x))
		rgb(colorRamp(rev(gob), bias = y)(x), maxColorValue = 255)
	else
		NULL
}

sistr_reactable <- function(sistr_ct) {
	# define default number of rows to be selected
	n_select <- nrow(sistr_data$origData())
	
	sistr_table <- sistr_data %>% 
		reactable(
			defaultColDef = colDef(
				filterable = T,
				filterInput = function(values, name) reactable_select(values, name, tableId = "sistr-table")
			),
			columns = list(
				.selection = colDef( # makes selection box sticky
					style = list(position = "sticky", left = 0, background = "#fff", zIndex = 1),
					headerStyle = list(position = "sticky", left = 0, background = "#fff", zIndex = 1),
					width = 45
				),
				id = colDef(width = 200,
										name = "Sample",
										# sticky = "left",
										style = list(position = "sticky",
																 left = 45,
																 background = "#fff",
																 zIndex = 1,
																 borderRight = "1px solid #eee"),
										headerStyle = list(position = "sticky",
																			 left = 45,
																			 background = "#fff", 
																			 zIndex = 1,
																			 borderRight = "1px solid #eee"),
										# Add a right border style to visually distinguish the sticky column
										# style = list(borderRight = "1px solid #eee"),
										# headerStyle = list(borderRight = "1px solid #eee"),
										filterable = F
				),
				qc_messages = colDef(minWidth = 2000,
														 name = "SISTR QC Message(s)",
														 filterable = F),
				qc_status = colDef(minWidth = 125,
													 html = T,
													 name = "SISTR<br>QC Status",
													 align = "center",
													 # 		 header = JS("
													 #       function(colInfo) {
													 #         return 'SISTR<br>QC Status'
													 #       }"),
													 cell = function(value) {
													 	class <- paste0("tag status-", value)
													 	div(class = class, value)
													 }),
				serovar = colDef(minWidth = 150,
												 name = "Serovar"
				),
				serogroup = colDef(minWidth = 110,
													 name = "Serogroup")
			), # end of list
			style = list(#fontFamily = "Arial",
				fontSize = 16),
			highlight = T,
			searchable = T,
			selection = "multiple",
			onClick = "select",
			defaultSelected = c(1:n_select),
			wrap = F, # if F, force long lines to be wrapped in a single line
			resizable = T,
			bordered = T,
			showPageInfo = FALSE, 
			showPageSizeOptions = TRUE, 
			defaultPageSize = 10,
			pagination = FALSE,
			height = 450,
			elementId = "sistr-table"
		)
}




stats_reactable <- function(stats_ct) {
	stats_ct %>% 
		reactable(
			defaultColDef = colDef(
				filterMethod = JS("filterRange"),
				filterInput = JS("muiRangeFilter"),
				filterable = T,
				resizable = F,
			),
			columns = list(
				.selection = colDef( # makes selection box sticky
					style = list(position = "sticky", left = 0, background = "#fff", zIndex = 1),
					headerStyle = list(position = "sticky", left = 0, background = "#fff", zIndex = 1),
					width = 45
				),
				id = colDef(width = 200,
										name = "Sample",
										style = list(position = "sticky",
																 left = 45,
																 background = "#fff",
																 zIndex = 1,
																 borderRight = "1px solid #eee"),
										headerStyle = list(position = "sticky",
																			 left = 45,
																			 background = "#fff", 
																			 zIndex = 1,
																			 borderRight = "1px solid #eee"),
										# Add a right border style to visually distinguish the sticky column
										#style = list(borderRight = "1px solid #eee"),
										#headerStyle = list(borderRight = "1px solid #eee"),
										filterable = F,
										resizable = T
				),
				Completeness = colDef(minWidth = 150,
															format = colFormat(
																suffix = "%",
																digits = 2
															),
															style = function(value) {
																if (value < 80) {
																	list(background = "#F5736D")	
																} else {
																	normalized <- (value-80) / 20
																	color <- gob_pal(normalized, 2)
																	list(background = color)
																}
															}),
				Contamination = colDef(minWidth = 150,
															 format = colFormat(
															 	suffix = "%",
															 	digits = 2
															 ),
															 style = function(value) {
															 	if (value > 10) {
															 		list(background = "#F5736D")	
															 	} else {
															 		normalized <- value / 10
															 		color <- gob_rev_pal(normalized, 1)
															 		list(background = color)
															 	}
															 }),
				`Strain heterogeneity` = colDef(minWidth = 150,
																				format = colFormat(
																					suffix = "%",
																					digits = 2
																				)),
				`Avg. coverage depth` = colDef(minWidth = 125,
																			 name = "Avg Coverage",
																			 format = colFormat(
																			 	suffix = "x"
																			 )),
				`Total length` = colDef(
					minWidth = 150,
					format = colFormat(
						digits = 2
					),
					header = function(value) {
						units <- div(style = "color: #999", "Mbps")
						div(title = value, value, units)
					},
					# cell = function(value) {
					# 	div(scales::comma(value))
					# },
					style = function(value) {
						if (value < 4 | value > 5.5) {
							list(background = "#F5736D")	
						} else if (value > 4.8) {
							normalized <- (value - 4.8) / (5.5 - 4.8)
							color <- gob_rev_pal(normalized, 0.75)
							list(background = color)
						} else {
							normalized <- (value - 4) / (4.8 - 4)
							color <- gob_pal(normalized, 1.5)
							list(background = color)
						}
					}),
				N50 = colDef(header = function(value) {
					units <- div(style = "color: #999", "Mbps")
					div(title = value, value, units)
				},
				# cell = function(value) {
				# 	div(scales::comma(value))
				# },
				minWidth = 125,
				format = colFormat(
					digits = 2
				))
			), # end of list
			style = list(#fontFamily = "Arial",
				fontSize = 16),
			highlight = T,
			searchable = T,
			selection = "multiple",
			onClick = "select",
			#defaultSelected = c(1:n_select),
			#wrap = F, # if F, force long lines to be wrapped in a single line
			bordered = T,
			showPageInfo = FALSE, 
			showPageSizeOptions = TRUE, 
			defaultPageSize = 10,
			pagination = FALSE,
			height = 450,
			elementId = "stats-table"
		)
}





kreport_class_reactable <- function(kreport_class_df) {
	kreport_class_df %>% 
		reactable(
			defaultColDef = colDef(
				minWidth = 125,
				resizable = T,
				format = colFormat(
					suffix = "%",
					digits = 2
				),
				filterInput = function(values, name) reactable_select(values, name, tableId = "kreport-class-table"),
				style = function(value) {
					if (is.numeric(value) & value <= 100) {
						bar_style(width = value / 100, 
											fill = "hsl(49, 41%, 65%)", # gold
											align = "right")	
					} else {
						return(NULL)
					}
				}
			),
			columns = list(
				name = colDef(name = "Species",
											minWidth = 200,
											sticky = "left",
											format = colFormat(
												suffix = "",
											)
				),
				taxid = colDef(name = "TaxID",
											 minWidth = 75,
											 format = colFormat(
											 	suffix = "",
											 )
				),
				domain = colDef(name = "Domain",
												minWidth = 100,
												format = colFormat(
													suffix = "",
												),
												filterable = T
				)
			), # end of list
			style = list(#fontFamily = "Arial",
				fontSize = 16),
			highlight = T,
			searchable = T,
			# selection = "multiple",
			# 			onClick = "select",
			wrap = F, # force long lines to be wrapped in a single line
			bordered = T,
			resizable = T,
			showPageInfo = FALSE, 
			showPageSizeOptions = TRUE, 
			defaultPageSize = 10,
			#pagination = FALSE,
			#height = 450,
			elementId = "kreport-class-table"
		)
}


kreport_summary_reactable <- function(kreport_summary_ct) {
	kreport_summary_ct %>% 
		reactable(
			defaultColDef = colDef(
				filterMethod = JS("filterRange"),
				filterInput = JS("muiRangeFilter"),
				filterable = T,
				resizable = F,
				minWidth = 150
			),
			columns = list(
				.selection = colDef( # makes selection box sticky
					style = list(position = "sticky", left = 0, background = "#fff", zIndex = 1),
					headerStyle = list(position = "sticky", left = 0, background = "#fff", zIndex = 1),
					width = 45
				),
				id = colDef(width = 200,
										name = "Sample",
										style = list(position = "sticky",
																 left = 45,
																 background = "#fff",
																 zIndex = 1,
																 borderRight = "1px solid #eee"),
										headerStyle = list(position = "sticky",
																			 left = 45,
																			 background = "#fff", 
																			 zIndex = 1,
																			 borderRight = "1px solid #eee"),
										# Add a right border style to visually distinguish the sticky column
										#style = list(borderRight = "1px solid #eee"),
										#headerStyle = list(borderRight = "1px solid #eee"),
										filterable = F,
										resizable = T
				),
				total = colDef(name = "Total Reads",
											 style = function(value) {
											 	bar_style(width = value / max(kreport_summary$total),
											 						fill = "hsl(31, 89%, 69%)", # orange
											 						align = "right")
											 },
											 cell = function(value) {
											 	div(scales::comma(value))
											 }
				),
				classified = colDef(name = "Classified",
														format = colFormat(
															suffix = "%",
															digits = 2
														),
														style = function(value) {
															bar_style(width = value / 100, 
																				fill = "hsl(209, 61%, 77%)", # blue
																				align = "right")
														}
				),
				unclassified = colDef(name = "Unclassified",
															format = colFormat(
																suffix = "%",
																digits = 2
															),
															style = function(value) {
																bar_style(width = value / 100, 
																					fill = "hsl(0, 66%, 76%)", # red
																					align = "right")
															}
				),
				bacteria = colDef(name = "Bacteria",
													format = colFormat(
														suffix = "%",
														digits = 2
													),
													style = function(value) {
														bar_style(width = value / 100, 
																			fill = "hsl(49, 41%, 65%)", # gold
																			align = "right")
													}
				),
				virus = colDef(name = "Virus",
											 format = colFormat(
											 	suffix = "%",
											 	digits = 2
											 )
				),
				eukaryota = colDef(name = "Eukaryota",
													 format = colFormat(
													 	suffix = "%",
													 	digits = 2
													 )
				),
				archaea = colDef(name = "Archaea",
												 format = colFormat(
												 	suffix = "%",
												 	digits = 2
												 )
				)
			), # end of list
			style = list(#fontFamily = "Arial",
				fontSize = 16),
			highlight = T,
			searchable = T,
			selection = "multiple",
			onClick = "select",
			#wrap = F, # if F, force long lines to be wrapped in a single line
			bordered = T,
			showPageInfo = FALSE, 
			showPageSizeOptions = TRUE, 
			defaultPageSize = 10,
			pagination = FALSE,
			height = 450,
			elementId = "kreport-summary-table"
		)
}