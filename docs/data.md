# Data

No data is stored in this repository. Source data and processed datasets are available through the PsychENCODE Knowledge Portal (https://psychencode.org), Synapse accession `syn25922167` (https://doi.org/10.7303/syn25922167); individual-level data are controlled access. During the study the analysis workspace was held in Synapse (project `syn22755334`); `loadInputDataset()` in `R/functions.R` can fetch input files from it for users with access.

## Directory layout

`config/paths.R` reads these environment variables; defaults sit under `<repo>/submission/`.

| Variable | Default | Holds |
|---|---|---|
| `SNSZ_ROOT` | `submission` | Root of the workspace |
| `SNSZ_DATASETS` | `<root>/datasets` | Intermediate R objects (`.rds`) passed between notebooks |
| `SNSZ_TABLES` | `<root>/tables` | Excel and TSV tables; RDS copies in `tables/rds/` |
| `SNSZ_FIGURES` | `<root>/figures` | PNG and PDF figures |
| `SNSZ_INPUT` | `<root>/input` | External inputs: marker sets, gene sets, GWAS loci, bulk expression, qPCR values |

## Datasets passed between notebooks

| Dataset | Written by | Read by |
|---|---|---|
| `combinedCells_ACTIONet` | Upstream preprocessing (not in this repository) | 1, 2, 7 |
| `ACTIONet_summary` | 1 | 2, 3, 4, 5, 6 |
| `pseudobulk_mean_logcounts`, `pseudobulk_mean_logcounts_filtered` | 2 | 3, 4, 5, 6 |
| `Cohort_specific_DE_results_final`, `DE_genes_pseudobulk_final`, `meta_analysis_results_final` | 3 | 4, 5, 6, 7 |
| `celltype_gene_specificity` | Upstream (ACTIONet) | 1, 4, 5, 6, 7 |
| `TF_modules`, `WGCNA_consensusTOM`, `ChEA_DE_TF_enrichment_min50genes_final` | 5 | 5 |
| `celltype_stats` (tables/rds) | 7 | 1 to 6 |
