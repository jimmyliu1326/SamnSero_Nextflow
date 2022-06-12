amr_reactable <- function(amr_ct) {
	amr_ct %>% 
		reactable(
			defaultColDef = colDef(
				filterMethod = JS("function(rows, columnId, filterValue) {
			        const pattern = new RegExp(filterValue, 'i')
			
			        return rows.filter(function(row) {
			          return pattern.test(row.values[columnId])
			        })
			      }")
			),
			columns = list(
				.selection = colDef( # makes selection box sticky
					style = list(position = "sticky", left = 0, background = "#fff", zIndex = 1),
					headerStyle = list(position = "sticky", left = 0, background = "#fff", zIndex = 1),
					width = 45
				),
				idx = colDef(name = "",
										 width = 0,
										 cell = function(value) {
										 	return("")
										 }),
				id = colDef(name = "Sample",
										width = 175,
										style = list(position = "sticky",
																 left = 45,
																 background = "#fff",
																 zIndex = 1,
																 borderRight = "1px solid #eee"),
										headerStyle = list(position = "sticky",
																			 left = 45,
																			 background = "#fff", 
																			 zIndex = 1,
																			 borderRight = "1px solid #eee")),
				contig = colDef(name = "Contig",
												width = 100),
				combined_class = colDef(name = "Drug Class Summary",
																filterable = T,
																width = 1200
				)
			), # end of list
			details = function(index) {
				data <- select(amr_res_clean[amr_res_clean$idx == unique(amr_res_clean[,"idx"])$idx[index],], -c("idx","combined_class"))
				htmltools::div(style = "padding: 8px",
											 reactable(
											 	data,
											 	defaultColDef = colDef(
											 		minWidth = 100,
											 		resizable = T,
											 		filterable = T,
											 		filterMethod = JS("function(rows, columnId, filterValue) {
			        const pattern = new RegExp(filterValue, 'i')
			
			        return rows.filter(function(row) {
			          return pattern.test(row.values[columnId])
			        })
			      }")
											 	),
											 	columns = list(
											 		id = colDef(name = "",
											 								filterable = F,
											 								width = 0,
											 								cell = function(value) {
											 									return("")
											 								}),
											 		contig = colDef(name = "",
											 										filterable = F,
											 										width = 0,
											 										cell = function(value) {
											 											return("")
											 										}),
											 		name = colDef(name = "Feature",
											 									#width = 100,
											 									resizable = F),
											 		ARO = colDef(name = "OntologyID",
											 								 resizable = F,
											 								 html = TRUE, 
											 								 cell = function(value, index) {
											 								 	id <- aro$ID[which(aro$Accession == value)][1]
											 								 	url <- paste0("https://card.mcmaster.ca/ontology/", id)
											 								 	sprintf('<a href="%s" target="_blank">%s</a>', url, value)
											 								 }),
											 		`Drug Class` = colDef(width = 200,
											 													resizable = F),
											 		identity = colDef(name = "Identity",
											 											format = colFormat(
											 												suffix = "%",
											 												digits = 2
											 											),
											 											filterMethod = JS("filterRange"),
											 											filterInput = JS("muiRangeFilter")
											 		),
											 		coverage = colDef(name = "Coverage",
											 											format = colFormat(
											 												suffix = "%",
											 												digits = 2
											 											),
											 											filterMethod = JS("filterRange"),
											 											filterInput = JS("muiRangeFilter")
											 		),
											 		contig = colDef(name = "Contig",
											 										width = 150),
											 		`Resistance Mechanism` = colDef(width = 200,
											 																		resizable = F),
											 		`AMR Gene Family` = colDef(width = 200,
											 															 resizable = F),
											 		snps = colDef(name = "SNP(s)"),
											 		start = colDef(name = "Start",
											 									 format = colFormat(separators = TRUE),
											 									 filterMethod = JS("filterRange"),
											 									 filterInput = JS("muiRangeFilter"),
											 									 width = 150),
											 		end = colDef(name = "End",
											 								 format = colFormat(separators = TRUE),
											 								 filterMethod = JS("filterRange"),
											 								 filterInput = JS("muiRangeFilter"),
											 								 width = 150),
											 		strand = colDef(name = "Strand",
											 										filterInput = function(values, name) reactable_select(values, name, tableId = "amr-table"))
											 	), # end of list
											 	wrap = T,
											 	searchable = T,
											 	searchMethod = JS("function(rows, columnIds, filterValue) {
			        const pattern = new RegExp(filterValue, 'i')
			        return rows.filter(function(row) {
			      		return columnIds.some(function(columnId) {
					        return pattern.test(row.values[columnId])
					      })
					    })		
			      }"),
											 	highlight = T,
											 	showPageInfo = FALSE, 
											 	showPageSizeOptions = TRUE,
											 	height = 500,
											 	bordered = T,
											 	#defaultPageSize = 5,
											 	elementId = "amr-table"
											 )
				)
			},
			selection = "multiple",
			highlight = T,
			onClick = "select",
			showPageInfo = FALSE, 
			showPageSizeOptions = TRUE,
			searchable = T,
			#defaultPageSize = 5,
			searchMethod = JS("function(rows, columnIds, filterValue) {
			        const pattern = new RegExp(filterValue, 'i')
			        return rows.filter(function(row) {
			      		return columnIds.some(function(columnId) {
					        return pattern.test(row.values[columnId])
					      })
					    })		
			      }"),
			elementId = "amr-front"
		)
}





vf_reactable <- function(vf_ct) {
	vf_ct %>% 
		reactable(
			columns = list(
				idx = colDef(name = "",
										 width = 0,
										 cell = function(value) {
										 	return("")
										 }),
				id = colDef(name = "Sample",
										width = 175),
				contig = colDef(name = "Contig")
			), # end of list
			details = function(index) {
				data <- vf_res_clean[vf_res_clean$idx == unique(vf_res_clean[,"idx"])$idx[index], -c("idx")]
				htmltools::div(style = "padding: 8px",
											 reactable(
											 	data,
											 	defaultColDef = colDef(
											 		minWidth = 100,
											 		resizable = T,
											 		filterable = T,
											 		filterMethod = JS("function(rows, columnId, filterValue) {
        const pattern = new RegExp(filterValue, 'i')

        return rows.filter(function(row) {
          return pattern.test(row.values[columnId])
        })
      }")
											 	),
											 	columns = list(
											 		.selection = colDef( # makes selection box sticky
											 			style = list(position = "sticky", left = 0, background = "#fff", zIndex = 1),
											 			headerStyle = list(position = "sticky", left = 0, background = "#fff", zIndex = 1),
											 			width = 45
											 		),
											 		id = colDef(name = "",
											 								filterable = F,
											 								width = 0,
											 								cell = function(value) {
											 									return("")
											 								}),
											 		contig = colDef(name = "",
											 										filterable = F,
											 										width = 0,
											 										cell = function(value) {
											 											return("")
											 										}),
											 		identity = colDef(name = "Identity",
											 											format = colFormat(
											 												suffix = "%",
											 												digits = 2
											 											),
											 											filterMethod = JS("filterRange"),
											 											filterInput = JS("muiRangeFilter")),
											 		coverage = colDef(name = "Coverage",
											 											format = colFormat(
											 												suffix = "%",
											 												digits = 2
											 											),
											 											filterMethod = JS("filterRange"),
											 											filterInput = JS("muiRangeFilter")),
											 		contig = colDef(name = "Contig"),
											 		product = colDef(name = "Gene Product",
											 										 width = 300,
											 										 resizable = T),
											 		gene = colDef(name = "Gene",
											 									width = 75,
											 									align = 'center'),
											 		accession = colDef(name = "NCBI Asm",
											 											 cell = function(value, index) {
											 											 	url <- paste0("https://www.ncbi.nlm.nih.gov/gene/?term=", value)
											 											 	sprintf('<a href="%s" target="_blank">%s</a>', url, value)
											 											 },
											 											 html = T),
											 		start = colDef(name = "Start",
											 									 format = colFormat(separators = TRUE),
											 									 filterMethod = JS("filterRange"),
											 									 filterInput = JS("muiRangeFilter"),
											 									 width = 150),
											 		end = colDef(name = "End",
											 								 cell = function(value) {
											 								 	div(scales::comma(value))
											 								 },
											 								 filterMethod = JS("filterRange"),
											 								 filterInput = JS("muiRangeFilter"),
											 								 width = 150),
											 		strand = colDef(name = "Strand",
											 										filterInput = function(values, name) reactable_select(values, name, tableId = "vf-table"))
											 	), # end of list
											 	wrap = T,
											 	searchable = T,
											 	searchMethod = JS("function(rows, columnIds, filterValue) {
        const pattern = new RegExp(filterValue, 'i')
        return rows.filter(function(row) {
      		return columnIds.some(function(columnId) {
		        return pattern.test(row.values[columnId])
		      })
		    })		
      }"),
											 	highlight = T,
											 	showPageInfo = FALSE, 
											 	showPageSizeOptions = TRUE,
											 	height = 500,
											 	bordered = T,
											 	#defaultPageSize = 5,
											 	elementId = "vf-table"
											 )
				)
			},
			selection = "multiple",
			onClick = "select",
			highlight = T,
			showPageInfo = FALSE, 
			showPageSizeOptions = TRUE,
			#defaultPageSize = 5,
			searchable = T,
			searchMethod = JS("function(rows, columnIds, filterValue) {
			        const pattern = new RegExp(filterValue, 'i')
			        return rows.filter(function(row) {
			      		return columnIds.some(function(columnId) {
					        return pattern.test(row.values[columnId])
					      })
					    })		
			      }"),
			elementId = "vf-front"
		)
}





plasmid_reactable <- function(plasmid_ct) {
	plasmid_ct %>% 
		reactable(
			defaultColDef = colDef(
				minWidth = 200,
				resizable = T,
				filterable = T,
				filterMethod = JS("function(rows, columnId, filterValue) {
			        const pattern = new RegExp(filterValue, 'i')
			
			        return rows.filter(function(row) {
			          return pattern.test(row.values[columnId])
			        })
			      }")
			),
			columns = list(
				idx = colDef(name = "",
										 width = 0,
										 filterable = F,
										 cell = function(value) {
										 	return("")
										 }),
				.selection = colDef( # makes selection box sticky
					style = list(position = "sticky", left = 0, background = "#fff", zIndex = 1),
					headerStyle = list(position = "sticky", left = 0, background = "#fff", zIndex = 1),
					width = 45
				),
				id = colDef(width = 175,
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
				contig = colDef(name = "Contig"),
				size = colDef(name = "Length",
											width = 150,
											format = colFormat(separators = TRUE),
											header = function(value) {
												units <- div(style = "color: #999", "bps")
												div(title = value, value, units)
											},
											filterMethod = JS("filterRange"),
											filterInput = JS("muiRangeFilter")),
				gc = colDef(name = "GC Content",
										width = 125,
										format = colFormat(
											suffix = "%",
											digits = 2
										),
										filterMethod = JS("filterRange"),
										filterInput = JS("muiRangeFilter")),
				predicted_mobility = colDef(name = "Mobility",
																		width = 100,
																		filterInput = function(values, name) reactable_select(values, name, tableId = "plasmid-table")),
				rep_type = colDef(name = "Replicon Type(s)"),
				relaxase_type = colDef(name = "Relaxase Type(s)"),
				mpf_type = colDef(name = "MPF Type",
													width = 125),
				orit_type = colDef(name = "OriT Type(s)"),
				contig = colDef(name = "Contig",
												width = 100),
				primary_cluster_id = colDef(name = "Primary<br>Cluster ID",
																		html = T,
																		width = 100),
				predicted_host = colDef(html = T,
																name = "Predicted<br>Host Range"),
				observed_host = colDef(html = T,
															 name = "Observed<br>Host Range"),
				reported_host = colDef(html = T,
															 name = "Reported<br>Host Range"),
				pmid = colDef(name = "PMID(s)",
											html = T,
											cell = function(value, index) {
												if ( value != "-" ) {
													pmid <- unlist(str_split(value, "; "))
													url <- paste0("https://pubmed.ncbi.nlm.nih.gov/", pmid)
													url <- paste0('<a href="',url, '" target="_blank">', pmid, '</a>')
													url <- paste0(url, collapse = ", ")
													sprintf(url)	
												} else {
													return(value)
												}
											})
			), # end of list
			wrap = T,
			searchable = T,
			searchMethod = JS("function(rows, columnIds, filterValue) {
			        const pattern = new RegExp(filterValue, 'i')
			        return rows.filter(function(row) {
			      		return columnIds.some(function(columnId) {
					        return pattern.test(row.values[columnId])
					      })
					    })		
			      }"),
			selection = "multiple",
			onClick = "select",
			highlight = T,
			showPageInfo = FALSE, 
			showPageSizeOptions = TRUE,
			height = 500,
			bordered = T,
			#defaultPageSize = 5,
			elementId = "plasmid-table"
		)
}