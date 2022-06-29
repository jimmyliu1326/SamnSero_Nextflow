# clean data
source(file.path(src_dir, "src/samnsero_clean.R"))
# mask unresolved serotypes
if (exists("sistr_res")) sistr_res_clean <- sistr_clean(sistr_res)
# VF
if (exists("vf_res")) vf_res_clean <- vf_clean(vf_res)
# AMR
if (exists("amr_res")) amr_res_clean <- rgi_clean(amr_res)
# plasmid
if (exists("plasmid_res")) plasmid_res_clean <- plasmid_clean(plasmid_res)