select_filter <- function(id, label, shared_data, group, choices = NULL,
													width = "100%", class = "filter-input") {
	values <- shared_data$data()[[group]]
	keys <- shared_data$key()
	if (is.list(values)) {
		# Multiple values per row
		flat_keys <- unlist(mapply(rep, keys, sapply(values, length)))
		keys_by_value <- split(flat_keys, unlist(values), drop = TRUE)
		choices <- if (is.null(choices)) sort(unique(unlist(values))) else choices
	} else {
		# Single value per row
		keys_by_value <- split(seq_along(keys), values, drop = TRUE)
		choices <- if (is.null(choices)) sort(unique(values)) else choices
	}
	
	script <- sprintf("
    window['__ct__%s'] = (function() {
      const handle = new window.crosstalk.FilterHandle('%s')
      const keys = %s
      return {
        filter: function(value) {
          if (!value) {
            handle.clear()
          } else {
            handle.set(keys[value])
          }
        }
      }
    })()
  ", id, shared_data$groupName(), toJSON(keys_by_value))
	
	div(
		class = class,
		tags$label(`for` = id, label),
		tags$select(
			id = id,
			onchange = sprintf("window['__ct__%s'].filter(this.value)", id),
			style = sprintf("width: %s", validateCssUnit(width)),
			tags$option(value = "", "All"),
			lapply(choices, function(value) tags$option(value = value, value))
		),
		tags$script(HTML(script))
	)
}

# Custom Crosstalk search filter. This is a free-form text field that does
# case-insensitive text searching on a single column.
search_filter <- function(id, label, shared_data, group, width = "100%", class = "filter-input") {
	values <- as.list(shared_data$data()[[group]])
	values_by_key <- setNames(values, shared_data$key())
	
	script <- sprintf("
    window['__ct__%s'] = (function() {
      const handle = new window.crosstalk.FilterHandle('%s')
      const valuesByKey = %s
      return {
        filter: function(value) {
          if (!value) {
            handle.clear()
          } else {
            // Escape special characters in the search value for regex matching
            value = value.replace(/[.*+?^${}()|[\\]\\\\]/g, '\\\\$&')
            const regex = new RegExp(value, 'i')
            const filtered = Object.keys(valuesByKey).filter(function(key) {
              const value = valuesByKey[key]
              if (Array.isArray(value)) {
                for (let i = 0; i < value.length; i++) {
                  if (regex.test(value[i])) {
                    return true
                  }
                }
              } else {
                return regex.test(value)
              }
            })
            handle.set(filtered)
          }
        }
      }
    })()
  ", id, shared_data$groupName(), toJSON(values_by_key))
	
	div(
		class = class,
		tags$label(`for` = id, label),
		tags$input(
			id = id,
			type = "search",
			oninput = sprintf("window['__ct__%s'].filter(this.value)", id),
			style = sprintf("width: %s", validateCssUnit(width))
		),
		tags$script(HTML(script))
	)
}

rt_select_filter <- function(values, group, id, shared_data,
													width = "100%", class = "filter-input") {
	values <- shared_data$data()[[group]]
	choices <- unique(values)
	keys <- shared_data$key()
	if (is.list(values)) {
		# Multiple values per row
		flat_keys <- unlist(mapply(rep, keys, sapply(values, length)))
		keys_by_value <- split(flat_keys, unlist(values), drop = TRUE)
		choices <- if (is.null(choices)) sort(unique(unlist(values))) else choices
	} else {
		# Single value per row
		keys_by_value <- split(seq_along(keys), values, drop = TRUE)
		choices <- if (is.null(choices)) sort(unique(values)) else choices
	}
	
	script <- sprintf("
    window['__ct__%s'] = (function() {
      const handle = new window.crosstalk.FilterHandle('%s')
      const keys = %s
      return {
        filter: function(value) {
          if (!value) {
            handle.clear()
          } else {
            handle.set(keys[value])
          }
        }
      }
    })()
  ", id, shared_data$groupName(), toJSON(keys_by_value))
	
	div(
		class = class,
		tags$label(`for` = id),
		tags$select(
			id = id,
			onchange = sprintf("window['__ct__%s'].filter(this.value)", id),
			style = sprintf("width: %s", validateCssUnit(width)),
			tags$option(value = "", "All"),
			lapply(choices, function(value) tags$option(value = value, value))
		),
		tags$script(HTML(script))
	)
}

# Custom Crosstalk range filter. This is a simple range input that only filters
# minimum values of a column.
range_filter <- function(id, label, shared_data, group, min = NULL, max = NULL,
												 step = NULL, suffix = "", width = "100%", class = "filter-input") {
	values <- shared_data$data()[[group]]
	values_by_key <- setNames(as.list(values), shared_data$key())
	
	script <- sprintf("
    window['__ct__%s'] = (function() {
      const handle = new window.crosstalk.FilterHandle('%s')
      const valuesByKey = %s
      return {
        filter: function(value) {
          const filtered = Object.keys(valuesByKey).filter(function(key) {
            return valuesByKey[key] >= value
          })
          handle.set(filtered)
        }
      }
    })()
  ", id, shared_data$groupName(), toJSON(values_by_key))
	
	min <- if (!is.null(min)) min else min(values)
	max <- if (!is.null(max)) max else max(values)
	value <- min
	
	oninput <- paste(
		sprintf("document.getElementById('%s__value').textContent = this.value + '%s';", id, suffix),
		sprintf("window['__ct__%s'].filter(this.value)", id)
	)
	
	div(
		class = class,
		tags$label(`for` = id, label),
		div(
			tags$input(
				id = id,
				type = "range",
				min = min,
				max = max,
				step = step,
				value = value,
				oninput = oninput,
				onchange = oninput, # For IE11 support
				style = sprintf("width: %s", validateCssUnit(width))
			)
		),
		span(id = paste0(id, "__value"), paste0(value, suffix)),
		tags$script(HTML(script))
	)
}

reactable_select <- function(values, name, tableId) {
	tags$select(
		# Set to undefined to clear the filter
		onchange = sprintf(
			"Reactable.setFilter('%s', '%s', event.target.value || undefined)",
			tableId, name),
		# "All" has an empty value to clear the filter, and is the default option
		tags$option(value = "", "All"),
		lapply(unique(values), tags$option),
		"aria-label" = sprintf("Filter %s", name),
		style = "width: 100%; height: 28px;"
	)
}

reactable_crosstalk_select <- function(values, name,
																			 id, shared_data,
																			 class = "filter-input") {
	values <- shared_data$data()[[name]]
	choices <- unique(values)
	keys <- shared_data$key()
	if (is.list(values)) {
		# Multiple values per row
		flat_keys <- unlist(mapply(rep, keys, sapply(values, length)))
		keys_by_value <- split(flat_keys, unlist(values), drop = TRUE)
		choices <- if (is.null(choices)) sort(unique(unlist(values))) else choices
	} else {
		# Single value per row
		keys_by_value <- split(seq_along(keys), values, drop = TRUE)
		choices <- if (is.null(choices)) sort(unique(values)) else choices
	}
	
	script <- sprintf("
    window['__ct__%s'] = (function() {
      const handle = new window.crosstalk.FilterHandle('%s')
      const keys = %s
      return {
        filter: function(value) {
          if (!value) {
            handle.clear()
          } else {
            handle.set(keys[value])
          }
        }
      }
    })()
  ", id, shared_data$groupName(), toJSON(keys_by_value))
	div(
	class = class,
	tags$label(`for` = id),
	tags$select(
		onchange = sprintf("window['__ct__%s'].filter(this.value)", id),
		# Set to undefined to clear the filter
		# "All" has an empty value to clear the filter, and is the default option
		tags$option(value = "", "All"),
		lapply(unique(values), tags$option),
		#"aria-label" = sprintf("Filter %s", name),
		style = "width: 100%; height: 28px;"
	),
		tags$script(HTML(script))
	)
}

muiDependency <- function() {
	list(
		# Material UI requires React
		reactR::html_dependency_react(),
		htmlDependency(
			name = "mui",
			version = "5.6.3",
			src = c(href = "https://unpkg.com/@mui/material@5.6.3/umd/"),
			script = "material-ui.production.min.js"
		)
	)
}

# Render a bar chart in the background of the cell
bar_style <- function(width = 1, fill = "#e6e6e6", height = "75%", align = c("left", "right"), color = NULL) {
	align <- match.arg(align)
	if (align == "left") {
		position <- paste0(width * 100, "%")
		image <- sprintf("linear-gradient(90deg, %1$s %2$s, transparent %2$s)", fill, position)
	} else {
		position <- paste0(100 - width * 100, "%")
		image <- sprintf("linear-gradient(90deg, transparent %1$s, %2$s %1$s)", position, fill)
	}
	list(
		backgroundImage = image,
		backgroundSize = paste("100%", height),
		backgroundRepeat = "no-repeat",
		backgroundPosition = "center",
		color = color
	)
}

# Creates a data list column filter for a table with the given ID
dataListFilter <- function(tableId, style = "width: 100%; height: 28px;") {
	function(values, name) {
		dataListId <- sprintf("%s-%s-list", tableId, name)
		tagList(
			tags$input(
				type = "text",
				list = dataListId,
				oninput = sprintf("Reactable.setFilter('%s', '%s', event.target.value || undefined)", tableId, name),
				"aria-label" = sprintf("Filter %s", name),
				style = style
			),
			tags$datalist(
				id = dataListId,
				lapply(unique(values), function(value) tags$option(value = value))
			)
		)
	}
}