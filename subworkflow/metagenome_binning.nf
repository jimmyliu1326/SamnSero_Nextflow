// import modules
include { rename_CTG } from '../modules/local/rename_CTG/rename_CTG.nf'
include { rename_FASTA } from '../modules/local/rename_FASTA/rename_FASTA.nf'
include { vamb } from '../modules/local/vamb/vamb.nf'
include { vamb_concatenate } from '../modules/local/vamb/concatenate.nf'
include { minimap2_map_ont } from '../modules/local/minimap2/map-ont.nf'
include { samtools_view } from '../modules/local/samtools/view.nf'
include { pubmlst_species_id } from '../modules/local/pubmlst/species_id.nf'
include { medaka; medaka_gpu } from '../modules/local/nanopore-polish.nf'

workflow MG_BIN {
    take: 
        assembly
        reads
    main:
        // rename metagenome assembly and 
        // concatenate assemblies into one file
        rename_CTG(assembly)
            | map { it[1] }
            | collect
            | vamb_concatenate

        // align sample reads to concatenated metagenome assemblies
        minimap2_map_ont(reads, vamb_concatenate.out)
            | samtools_view        

        // metagenomic binning
        vamb(samtools_view.out.map{ it[1] }.collect(), vamb_concatenate.out)
        
        vamb.out // a list of directory paths 
            | flatten 
            | map { dir ->
                dir_name = dir.getBaseName()
                bins = dir.listFiles().findAll { it.getExtension() == "fna" }
                tuple(dir_name, bins)
            }
            | transpose
            | map { id,path ->
                bin_id = path.getSimpleName()
                bin_sample_id = id+"_BIN_"+bin_id // concatenate Sample ID and Bin ID delimited by _BIN_
                tuple(id, bin_sample_id, path)
            }
            | set { bins } // tuple(Sample_ID, Sample_ID_BIN_BIN_ID, BIN FASTA Path)
        
        // polish bins
        if ( params.gpu ) {

            bins 
                | join(reads)
                | map { tuple(it[1], it[2], it[3])}
                | medaka_gpu
                | set { polished_bins } // tuple(Sample_ID_BIN_BIN_ID, BIN FASTA Path)

        } else {

            bins 
                | join(reads)
                | map { tuple(it[1], it[2], it[3])}
                | medaka
                | set { polished_bins } // tuple(Sample_ID_BIN_BIN_ID, BIN FASTA Path)

        }

        // identify target taxon bins
        if ( params.meta == "targeted" ) {

            // species identification using rMLST
            pubmlst_species_id(polished_bins, params.taxon_name)

            polished_bins 
                | join(pubmlst_species_id.out.target)
                | filter { it[2] == 'true' } // keep only target taxon bins
                | map { tuple(it[0], it[1]) } // return tuple(sample_id, genome_path)
                | set { target_bins }

        } else {

            target_bins = []

        }
        
        
        emit:
            bins = polished_bins
            target_bins = target_bins


}