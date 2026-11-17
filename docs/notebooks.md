# Notebooks

Run in this order. Each notebook opens with a header giving its purpose, inputs, outputs, paper item and run notes.

| Order | Notebook | What it does | Paper item | Main outputs |
|---|---|---|---|---|
| 1 | `01_atlas/01_cell_annotation_and_qc.Rmd` | Atlas summary, outlier samples by excitatory-neuron fraction, composition, QC metrics, marker-based annotation | Cell-type atlas, QC and annotation figures | `ACTIONet_summary`; atlas and QC figures |
| 2 | `02_differential_expression/01_compute_pseudobulk.Rmd` | Mean log-count pseudobulk per cell type and individual; gene capture rates; outlier removal | DE inputs (Methods) | `pseudobulk_mean_logcounts[_filtered]` |
| 3 | `02_differential_expression/02_cohort_de_and_meta_analysis.Rmd` | limma-trend DE per cohort on batch-corrected pseudobulk; fixed-effect meta-analysis; DE calls; cohort agreement | DE results and tables | `DE_genes_pseudobulk_final` and DE tables |
| 4 | `02_differential_expression/03_de_assessment_and_enrichment.Rmd` | Overlap with PsychENCODE bulk DE, volcano plots, gProfiler enrichment, rrvgo themes | DE summary and enrichment figures and tables | gProfiler tables; DE figures |
| 5 | `03_regulation/01_tf_modules_and_chea.Rmd` | Consensus TF co-expression modules (WGCNA), ChEA3 enrichment, PGC3 loci, CUT&Tag-linked genes | TF module and ChEA figures and tables | `TF_modules`; ChEA tables |
| 6 | `04_heterogeneity/01_transcriptional_pathology_score.Rmd` | TD scores, TPS, individual classification, cell states A11 and A29, bulk and qPCR comparisons | Heterogeneity figures | TPS figures; `A11_vs_A29_gene_spec` |
| 7 | `05_tables/01_celltype_summary_table.Rmd` | Per-cell-type table: markers, composition, DE counts, H-MAGMA and SCHEMA enrichment, layers | Cell-type summary table | `celltype_stats` |

`celltype_stats` (notebook 7) supplies the cell-type colors used by notebooks 1 to 6; a copy from the study is needed before running them in order.

Figure and table numbers in the published paper should be confirmed against the paper and its supplement; the notebooks name their outputs by content.

## Earlier file names

| Earlier name | Current path |
|---|---|
| `CellAnnotation.Rmd` | `notebooks/01_atlas/01_cell_annotation_and_qc.Rmd` |
| `RunDE_computePB.Rmd` | `notebooks/02_differential_expression/01_compute_pseudobulk.Rmd` |
| `RunDE_performMetaAnalysis.Rmd` | `notebooks/02_differential_expression/02_cohort_de_and_meta_analysis.Rmd` |
| `RunDE_assessment.Rmd` | `notebooks/02_differential_expression/03_de_assessment_and_enrichment.Rmd` |
| `trans_factor_analysis.Rmd` | `notebooks/03_regulation/01_tf_modules_and_chea.Rmd` |
| `TPS_analysis.Rmd` | `notebooks/04_heterogeneity/01_transcriptional_pathology_score.Rmd` |
| `temp_analysis.Rmd` | `notebooks/05_tables/01_celltype_summary_table.Rmd` |
| `functions.R` | `R/functions.R` |
