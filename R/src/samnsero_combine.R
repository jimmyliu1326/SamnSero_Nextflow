# load pkgs
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(purrr))
suppressPackageStartupMessages(library(stringr))
suppressPackageStartupMessages(library(data.table))

# parse args
args <- commandArgs(trailingOnly = T)
work_dir <- args[1]
files <- args[2:length(args)]

# change work dir
setwd(work_dir)

# join all files by column modified id
# IDs in quast results have _ instead of -
combined_res <- map(rev(files), function(x) {
	fread(x, header = T) %>% 
		mutate(mod_id = str_replace_all(id, "-", "_"))
	}) %>% 
	reduce(left_join, by = "mod_id")

# remove xtra columns
id_cols <- c(colnames(combined_res)[which(str_detect(colnames(combined_res), "id."))], "mod_id")
xtra_cols <- c("fasta_filepath")

combined_res <- combined_res %>% 
	select(-id_cols, -xtra_cols) %>%
	select(id, serovar, qc_status, qc_messages, everything())

# write out
fwrite(combined_res, row.names = F, sep = ",")