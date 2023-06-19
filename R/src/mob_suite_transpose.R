#!/usr/bin/env Rscript

# parse args
default_args <- commandArgs(trailingOnly = F)
src_dir <- dirname(gsub("--file=", "",default_args[grep("--file", default_args)]))

args <- commandArgs(trailingOnly = T)
input_path <- args[1]
samples_path <- args[2]
output_path <- args[3]

# load pkgs
source(file.path(src_dir, "samnsero_load.R"))

# set wd
#setwd(work_dir)

# load data
samples <- readLines(samples_path)
input <- load_mob_suite_res(input_path)

# create summary table
summary <- function(df) {
	df %>% 
		select(id, "primary_cluster_id") %>% 
		group_by(id) %>% 
		group_split() %>% 
		map(function(x) {
			# get id
			id <- x$id[1]
			types <- unique(unlist(str_split(paste(x$`primary_cluster_id`,sep = ","), ",")))
			# return
			data.frame(id = id,
								 plasmids = types,
								 value = "1" # place holder for presence
			)
		}) %>%
		bind_rows() %>% 
		#mutate(id = factor(id, levels = samples)) %>% 
		pivot_wider(names_from = id,
								values_from = value,
								values_fill = ".",
								names_expand = T) %>%
		# transpose df
		pivot_longer(cols = 2:ncol(.),
								 names_to = "id",
								 values_to = "value") %>% 
		pivot_wider(names_from = plasmids,
								values_from = value)
		
}

# write out
write.table(summary(input), file = output_path, sep = "\t", quote = F, row.names = F)