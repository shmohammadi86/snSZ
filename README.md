# snSZ

Analysis code for the multi-cohort single-nucleus atlas of schizophrenia in the human prefrontal cortex:

> Ruzicka WB\*, Mohammadi S\*, Fullard JF\*, Davila-Velderrain J\*, et al. Single-cell multi-cohort dissection of the schizophrenia transcriptome. *Science* 384, eadg5136 (2024). https://doi.org/10.1126/science.adg5136 (\* equal contribution)

If you use this code, please cite the paper (see `CITATION.cff`).

## Key findings

From the published paper:

- Single-nucleus RNA-seq of prefrontal cortex from **140 individuals in two independent cohorts**: McLean (24 schizophrenia, 24 controls) and Mount Sinai (41 schizophrenia, 51 controls), **468,727 nuclei**.
- **27 cell types and subpopulations**; the meta-analysis of the 25 captured in both cohorts found **6,634 differential expression events in 2,455 unique genes** (FDR < 0.05, |log2FC| > 0.1).
- **Excitatory neurons were the most affected cell group**, with transcriptional changes converging on neurodevelopment and synapse-related pathways.
- Cell-type changes include **known genetic risk factors**, linking rare and common variants to neuronal population-specific alterations.
- The magnitude of schizophrenia-associated change separates **two populations of individuals with schizophrenia**, marked by specific excitatory and inhibitory neuronal cell states.

## Start here

| If you want to | Open |
|---|---|
| See the analysis in order | [`docs/notebooks.md`](docs/notebooks.md) |
| Reproduce the differential expression and meta-analysis | [`notebooks/02_differential_expression/02_cohort_de_and_meta_analysis.Rmd`](notebooks/02_differential_expression/02_cohort_de_and_meta_analysis.Rmd) |
| Understand the individual-level heterogeneity (TPS) | [`notebooks/04_heterogeneity/01_transcriptional_pathology_score.Rmd`](notebooks/04_heterogeneity/01_transcriptional_pathology_score.Rmd) |
| Reuse the helper functions | [`R/functions.R`](R/functions.R) |
| Get the data | [`docs/data.md`](docs/data.md) |

## Layout

| Path | Contents |
|---|---|
| `notebooks/01_atlas/` | Cell-type annotation, sample QC, composition, marker-based annotation |
| `notebooks/02_differential_expression/` | Pseudobulk profiles, per-cohort limma-trend DE, fixed-effect meta-analysis, DE assessment and enrichment |
| `notebooks/03_regulation/` | Transcription factor co-expression modules, ChEA3 enrichment, CUT&Tag support |
| `notebooks/04_heterogeneity/` | Transcriptional deviation scores, transcriptional pathology score (TPS), associated cell states |
| `notebooks/05_tables/` | Per-cell-type summary table |
| `R/functions.R` | Shared helpers (storage, sample QC, TD scores, archetype annotation, ChEA3), documented with roxygen comments |
| `config/paths.R` | Data and output locations, set through environment variables |
| `scripts/check_repo.R` | Static checks run by `make check` |
| `docs/` | Notebook map, data access, documentation index |

## Reproducing the analysis

1. Obtain the data (controlled access; see [`docs/data.md`](docs/data.md)). No data is stored in this repository.
2. Point `config/paths.R` at your copy by setting `SNSZ_ROOT` (or the individual `SNSZ_*` variables).
3. Install R 4.x with ACTIONet, muscat, limma, metafor, WGCNA, ComplexHeatmap, ggpubr, EnhancedVolcano, gprofiler2, rrvgo, ppcor, openxlsx, readr and here. Each notebook lists its packages in its setup chunk.
4. Run the notebooks in folder order. Chunks are not evaluated by default (`eval = FALSE`), so `make render` produces readable HTML without the data; set `eval = TRUE` in a notebook's setup chunk to run it.

`make check` verifies notebook headers, parses all R code, and scans for absolute paths.

## License

Code is released under the MIT License and documentation under CC BY 4.0 (see `LICENSE`).

## Contact

Shahin Mohammadi, mohammadi@cytognosis.org. Questions about the study and data: see the corresponding authors of the paper.
