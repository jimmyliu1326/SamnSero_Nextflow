source(file.path(src_dir, "src/samnsero_load.R"))
checkm_res <- load_checkm(checkm_path)
quast_res <- load_quast(quast_path)
sistr_res <- load_sistr(sistr_path)
kreport_res <- map_dfr(list.files(kreport_path),
											 ~load_kreport(file.path(kreport_path, .)))