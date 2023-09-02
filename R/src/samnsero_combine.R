#!/usr/bin/env Rscript

# load pkgs
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(tidyr))
suppressPackageStartupMessages(library(purrr))
suppressPackageStartupMessages(library(stringr))
suppressPackageStartupMessages(library(data.table))

# parse args
args <- commandArgs(trailingOnly = T)

# parse file extensions
file_ext <- str_split(args, "\\.") %>% 
	map_chr(~return(.[[length(.)]]))

# get delimiter based on file ext
delim <- if_else(file_ext == "tsv", "\t", ",")

# join all files by column modified id
combined_res <- map2(rev(args), rev(delim), ~fread(.x, header = T, sep = .y)) %>% 
	reduce(left_join, by = "id")

# remove xtra columns
xtra_cols <- c("fasta_filepath")

combined_res <- combined_res %>% 
	select(-xtra_cols) %>% # remove xtra cols
	select(id, serovar, qc_status, qc_messages, everything())

# metagenomic binning check
binning <- any(str_detect(combined_res$id, "_BIN_"))

# return
if (binning) {
	combined_res <- combined_res %>% separate(id, into = c("id", "bin"), sep = "_BIN_")
}

# write out
fwrite(combined_res, row.names = F, sep = ",")