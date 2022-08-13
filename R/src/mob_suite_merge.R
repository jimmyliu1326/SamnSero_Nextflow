#!/usr/bin/env Rscript

# load pkgs
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(purrr))
suppressPackageStartupMessages(library(stringr))
suppressPackageStartupMessages(library(data.table))

# parse args
args <- commandArgs(trailingOnly = T)
contig_report_path <- args[1]
mobtyper_res_path <- args[2]

# load data
contig_report <- fread(contig_report_path, header = T,  colClasses = c(id = "character"))
mobtyper_res <- fread(mobtyper_res_path, header = T, colClasses = c(id = "character"))

# join the two tables
out <- mobtyper_res %>% 
	left_join(contig_report %>% 
							rename(contig = contig_id) %>%
							select(contig, primary_cluster_id, secondary_cluster_id))

# write out
fwrite(out, row.names = F, sep = "\t", quote = F)