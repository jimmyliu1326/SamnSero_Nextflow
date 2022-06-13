# the following functions read in
# result files in SamnSero pipeline
# and perform light data cleaning
library(dplyr)
library(purrr)
library(stringr)
library(tidyr)
library(tibble)
library(data.table)
library(magrittr)

# load sistr res
load_sistr <- function(path) {
	# read data
	df <- fread(path, sep = ",", header = T)
	# clean df
	df <- df %>% 
		#rename("id" = "genome") %>% 
		select(id, serovar, serovar_antigen,
					 serovar_cgmlst, serogroup, qc_status, 
					 qc_messages)
	# return
	return(df)
}

# load checkm
load_checkm <- function(path) {
	# read file
	df <- fread(path)
	# clean df
	df <- df %>% 
		#rename("id" = `Bin Id`) %>% 
		select(id, everything())
	# return
	return(df)
}

# load quast
load_quast <- function(path) {
	# read file
	df <- fread(path)
	# return
	return(df)
}

# load abricate summary
load_abricate_summary <- function(path) {
	# read file
	df <- fread(path)
	# return
	return(df)
}

load_kreport <- function(path) {
	# parse sample id
	sample <- gsub(".kraken.report", "", basename(path))
	# read file
	df <- fread(path) %>% 
		mutate("id" = as.character(sample))
	# rename first 6 cols
	colnames(df)[1:6] <- c("percent", "count", "count_direct", "level", "taxid", "name")
	# return
	return(df)
}

# load abricate res
load_abricate_res <- function(path) {
	# read file
	df <- fread(path)
	# return
	return(df)
}

# load mob suite res
load_mob_suite_res <- function(path) {
	# read file
	df <- fread(path) %>% 
		# remove the ids after :
		mutate(id = str_replace(id, ":.*", ""))
	# return
	return(df)
}

# load rgi res
load_rgi <- function(path) {
	# read file
	# read file
	df <- fread(path, sep = "\t") %>% 
		# clean contig name
		# remove ids after _
		mutate(Contig = str_replace(Contig,"_.*",""),
					 Best_Hit_ARO = map_chr(Best_Hit_ARO, function(x) {
					 	string <- unlist(str_split(x, " "))
					 	n <- length(string)
					 	if (n >= 3) {
					 		# if string contains 'conferring resistance to..' remove, otherwise only remove species
					 		if (any(str_detect(string, "conferring"))) {
					 			clean_string <- str_replace_all(paste(string[3:length(string)], collapse = " "), " with", "")
					 			clean_string <- paste0(str_replace_all(clean_string, "conferring resistance to |conferring ", "("), ")", collapse = "")
					 			clean_string <- str_replace_all(clean_string, "multidrug antibiotic resistance", "MDR")
					 			return(clean_string)
					 		} else {
					 			clean_string <- paste(string[3:length(string)], collapse = " ")
					 			return(clean_string)
					 		}
					 	} else {
					 		return(x)
					 	}
					 }))
	# return
	return(df)
}
