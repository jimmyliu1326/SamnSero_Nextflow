# clean data
source(file.path(src_dir, "src/samnsero_clean.R"))
# mask unresolved serotypes
sistr_res_clean <- sistr_clean(sistr_res)
# VF
vf_res_clean <- vf_clean(vf_res)
# AMR
amr_res_clean <- rgi_clean(amr_res)
# plasmid
plasmid_res_clean <- plasmid_clean(plasmid_res)