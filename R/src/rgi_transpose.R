# parse args
default_args <- commandArgs(trailingOnly = F)
src_dir <- dirname(gsub("--file=", "",default_args[grep("--file", default_args)]))
args <- commandArgs(trailingOnly = T)
input_path <- args[1]
samples_path <- args[2]
output_path <- args[3]

# load pkgs
source(file.path(src_dir, "samnsero_load.R"))

# load data
samples <- readLines(samples_path)
input <- load_rgi(input_path)

# create summary table
summary <- function(df) {
	df %>% 
		select(id, Best_Hit_ARO, Best_Identities) %>% 
		group_by(id, Best_Hit_ARO) %>% 
		arrange(desc(Best_Identities)) %>% 
		slice(1) %>% 
		ungroup() %>% 
		mutate(id = factor(id, levels = samples),
					 Best_Identities = as.character(Best_Identities)) %>% 
		pivot_wider(names_from = "id",
								values_from = "Best_Identities",
								values_fill = ".",
								names_expand = T) %>%
		# transpose df
		pivot_longer(cols = 2:ncol(.),
								 names_to = "id",
								 values_to = "value") %>%
		pivot_wider(names_from = "Best_Hit_ARO",
								values_from = "value")
}

# write out
write.table(summary(input), file = output_path, sep = "\t", quote = F, row.names = F)

