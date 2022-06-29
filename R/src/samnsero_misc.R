# the following functions perform
# miscellaneous actions during report
# generation
check_annot_dups <- function() {
	if (exists("annot_types")) {
		dups <- annot_types %>% 
			group_by(element) %>% 
			tally() %>% 
			filter(n > 1) %>% 
			pull(element)
		
		if (length(dups) > 0) {
			message("Duplicated annotation identifier detected..")
			message("The following hits are found in multiple databases: ", str_c(dups, ", "))
			quit(status = 1)
		}	
	}
}