# parse the positional arguments from the args vector
work_dir <- args[1]
sistr_path <- args[2]
annot_dir <- args[3]

# define file paths for plasmid, amr, and vf annotation results
plasmid_res_path <- file.path(work_dir, annot_dir, "results", "mob_suite_res_aggregate.tsv")
amr_res_path <- file.path(work_dir, annot_dir, "results", "rgi_res_aggregate.tsv")
vf_res_path <-  file.path(work_dir, annot_dir, "results", "vfdb_res_aggregate.tsv")

# get file names for aggregated results and summary results
annot_res_files <- list.files(file.path(work_dir, annot_dir, "results"), pattern = "_aggregate")
annot_summary_files <- list.files(file.path(work_dir, annot_dir, "summary"))

# get annotation cateogy display name based on file names
annot_name <- map_chr(annot_summary_files, ~unlist(str_split(., "_summary"))[1])
annot_name <- case_when(annot_name == "rgi" ~ "AMR",
												annot_name == "vfdb" ~ "Virulence Factor",
												annot_name == "mob_suite" ~ "Plasmid",
												T ~ annot_name)