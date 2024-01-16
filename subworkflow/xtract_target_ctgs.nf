// import modules
include { MMSEQS2_EASY_TAXONOMY } from '../modules/local/mmseqs2/easy-taxonomy.nf'
include { taxonkit_rank2name } from '../modules/local/taxonkit/lineage.nf'
include { seqkit_grep } from '../modules/local/seqkit/grep.nf'
include { rename_CTG } from '../modules/local/rename_CTG/rename_CTG.nf'
include { rename_FASTA } from '../modules/local/rename_FASTA/rename_FASTA.nf'
include { vamb_taxometer } from '../modules/local/vamb/vamb_taxometer.nf'
include { vamb_concatenate } from '../modules/local/vamb/concatenate.nf'
include { minimap2_map_ont_asm } from '../modules/local/minimap2/map-ont.nf'
include { samtools_view } from '../modules/local/samtools/view.nf'

workflow XTRACT_TARGET_CTGS {
    take: 
        assembly
        reads
        taxid
    main:
        // get the taxon name given taxid (e.g. 28901) and target rank (e.g. genus)
        taxonkit_rank2name(taxid, params.lca_rank)
        // ctgs taxonomic classification 
        MMSEQS2_EASY_TAXONOMY(assembly, params.mmseqs_db)
        // refine mmseqs2 classification by vamb
        // align reads to concatenated metagenome assemblies
        // reads 
        //     | join(assembly)
        //     | minimap2_map_ont_asm
        //     | samtools_view 
        //     | set { ch_bam }
        
        // assembly
        //     | join(ch_bam)
        //     | join(MMSEQS2_EASY_TAXONOMY.out) 
        //     | set { ch_taxometer }
        // run taxometer
        // vamb_taxometer(ch_taxometer)
        // keep ctgs assigned to target taxid (e.g. 28901) at target rank (e.g. genus)
        target_ctgs = seqkit_grep(assembly, MMSEQS2_EASY_TAXONOMY.out, taxonkit_rank2name.out)        
    emit:
        target_ctgs
}