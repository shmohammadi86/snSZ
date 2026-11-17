# Data and output locations for the snSZ notebooks.
#
# Every notebook sources this file. Set the environment variables below (for
# example in ~/.Renviron) instead of editing paths inside the notebooks.
#
#   SNSZ_ROOT      Root of the analysis workspace (default: "submission").
#   SNSZ_DATASETS  Intermediate R objects (RDS); default <root>/datasets.
#   SNSZ_FIGURES   Figure output; default <root>/figures.
#   SNSZ_TABLES    Table output; default <root>/tables (RDS copies in tables/rds).
#   SNSZ_INPUT     External inputs (marker sets, GWAS loci, bulk data); default <root>/input.
#
# Relative defaults resolve from the repository root via here::here().

snsz_root <- Sys.getenv("SNSZ_ROOT", here::here("submission"))
dataset.path <- Sys.getenv("SNSZ_DATASETS", file.path(snsz_root, "datasets"))
figures.path <- Sys.getenv("SNSZ_FIGURES", file.path(snsz_root, "figures"))
tables.path <- Sys.getenv("SNSZ_TABLES", file.path(snsz_root, "tables"))
input.path <- Sys.getenv("SNSZ_INPUT", file.path(snsz_root, "input"))
