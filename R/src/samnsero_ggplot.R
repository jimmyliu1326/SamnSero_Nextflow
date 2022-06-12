# checkm_plot <- function(df) {
# 	p <- df %>% 
# 		ggplot(aes(x = Completeness, y = Contamination, 
# 							 label = id, group = serovar
# 							 #fill = `Strain heterogeneity`
# 		)) +
# 		geom_point() +
# 		theme_minimal() +
# 		geom_hline(yintercept = 5, linetype="longdash") +
# 		geom_vline(xintercept = 95, linetype="longdash") +
# 		scale_y_continuous(limits = c(0, 100)) +
# 		scale_x_continuous(limits = c(0,100)) +
# 		labs(x = "Completeness (%)",
# 				 y = "Contamination (%)")
# 	
# 	ggplotly(p)
# 	
# }
# 
# quast_plot <- function(df) {
# 	p <- df %>% 
# 		ggplot(aes(x = N50, y = `Total length`,
# 							 label = id, group = serovar
# 		)) +
# 		geom_point() +
# 		theme_minimal() +
# 		scale_y_continuous(labels = scales::comma,
# 											 limits = c(0, NA)) +
# 		scale_x_continuous(labels = scales::comma,
# 											 limits = c(0, NA)) +
# 		geom_abline(intercept=0, slope=1, color="red",linetype="longdash") +
# 		labs(x = "N50 (Mbps)",
# 				 y = "Total length (Mbps)")
# 	
# 	ggplotly(p)
# 	
# }

hline <- function(y = 0, color = "black") {
	list(
		type = "line",
		opacity = 0.5,
		x0 = 0,
		x1 = 1,
		xref = "paper",
		y0 = y,
		y1 = y,
		line = list(color = color, dash="dash")
	)
}

vline <- function(x = 0, color = "black") {
	list(
		type = "line",
		opacity = 0.5,
		y0 = 0,
		y1 = 1,
		yref = "paper",
		x0 = x,
		x1 = x,
		line = list(color = color, dash="dash")
	)
}

abline <- function(xmax=1, color = "black") {
	val <- xmax+xmax*0.1
	list(
		type = "line",
		opacity = 0.5,
		y0 = 0,
		y1 = val,
		xref = "x",
		yref = "y",
		x0 = 0,
		x1 = val,
		line = list(color = color, dash="dash")
	)
}

checkm_plot <- function(df) {
	df %>% 
		plot_ly(x = ~Completeness, y = ~Contamination, name = ~serovar, text = ~I(id),
						hovertemplate = paste('%{text}<br><br>',
																	'Completeness: %{x}<br>',
																	'Contamination: %{y}'),
						type = 'scatter',
						mode = 'markers') %>% 
		layout(xaxis = list(title = 'Completeness (%)',
												range = list(0, 100),
												zeroline = F),
					 yaxis = list(title = "Contamination (%)",
					 						 range = list(0, 100),
					 						 zeroline = F),
					 showlegend = F,
					 shapes = list(vline(95),
					 							 hline(5)))
}

quast_plot <- function(df) {
	df %>% 
		plot_ly(x = ~N50, y = ~`Total length`, name = ~serovar, text = ~I(id),
						hovertemplate = paste('%{text}<br><br>',
																	'N50: %{x}<br>',
																	'Total length: %{y}'),
						type = 'scatter',
						mode = 'markers') %>% 
		layout(xaxis = list(title = 'N50 (Mbps)',
												rangemode="tozero",
												zeroline = F),
					 yaxis = list(title = "Total length (Mbps)",
					 						 rangemode="tozero",
					 						 zeroline = F),
					 showlegend = F,
					 shapes = list(abline(xmax = max(df$origData()$N50), "red")))
}