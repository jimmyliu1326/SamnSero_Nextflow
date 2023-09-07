# clean data
source(file.path(src_dir, "src/samnsero_clean.R"))
# mask unresolved serotypes
sistr_res_clean <- sistr_clean(sistr_res)
