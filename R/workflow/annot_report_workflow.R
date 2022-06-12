# workflow
source(file.path(src_dir, "modules/annot/load_data.R"))
source(file.path(src_dir,"modules/annot/clean_data.R"))
source(file.path(src_dir,"modules/annot/prepare_summary.R"))
source(file.path(src_dir,"src/samnsero_misc.R"))
check_annot_dups()
source(file.path(src_dir,"modules/annot/crosstalk.R"))
source(file.path(src_dir,"modules/annot/create_reactbl.R"))
