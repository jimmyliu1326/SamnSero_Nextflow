# load pkgs
library(dplyr)
library(purrr)
library(stringr)
library(tidyr)
library(tibble)
library(data.table)

# load sistr res
load_sistr <- function(path) {
	# read data
	df <- fread(path, sep = ",", header = T)
	# clean df
	df <- df %>% 
		#rename("id" = "genome") %>% 
		select(id, serovar, serovar_antigen,
					 serovar_cgmlst, serogroup, qc_status, 
					 qc_messages) %>% 
		rename(serogroup_predicted = serogroup)
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
	# clean df
	df <- df %>% 
		rename("id" = "#FILE") %>% 
		mutate("id" = str_replace(id, ".tab", ""))
	# return
	return(df)
}