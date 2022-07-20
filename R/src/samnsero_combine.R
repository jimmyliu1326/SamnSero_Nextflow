#!/usr/bin/env Rscript

# load pkgs
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(purrr))
suppressPackageStartupMessages(library(stringr))
suppressPackageStartupMessages(library(data.table))

# parse args
args <- commandArgs(trailingOnly = T)

# join all files by column modified id
# IDs in quast results have _ instead of -
combined_res <- map(rev(args), ~fread(., header = T)) %>% 
	reduce(left_join, by = "id")

# remove xtra columns
xtra_cols <- c("fasta_filepath")

combined_res <- combined_res %>% 
	select(-id_cols, -xtra_cols) %>%
	select(id, serovar, qc_status, qc_messages, everything())

# write out
fwrite(combined_res, row.names = F, sep = ",")