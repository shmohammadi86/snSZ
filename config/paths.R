# Data and output locations for the snSZ notebooks.
#
# Every notebook sources this file with
#   source(here::here("config", "paths.R"))
# here::here() finds the repository root from wherever the notebook runs (it
# looks for the `.here` marker file, the .git folder or an .Rproj file), so no
# path in this repository is absolute or tied to one machine.
#
# Set these environment variables (for example in a user-level .Renviron file)
# instead of editing paths inside the notebooks:
#
#   SNSZ_DATA_DIR  Root of the analysis workspace (default: <repo>/data).
#                  SNSZ_ROOT is accepted as an older alias.
#   SNSZ_DATASETS  Intermediate R objects (RDS); default <root>/datasets.
#   SNSZ_FIGURES   Figure output; default <root>/figures.
#   SNSZ_TABLES    Table output; default <root>/tables (RDS copies in tables/rds).
#   SNSZ_INPUT     External inputs (marker sets, GWAS loci, bulk data); default <root>/input.
#
# Relative values of these variables are resolved against the repository root.

#' Build a path inside the repository, independent of the working directory
#'
#' @param ... Path components below the repository root.
#' @return Absolute path, resolved at run time by here::here().
repo_path <- function(...) here::here(...)

#' Resolve a location from an environment variable with a default
#'
#' @param var Environment variable name.
#' @param default Default path, used when the variable is unset or empty.
#' @return The path, made absolute against the repository root when relative.
resolve_dir <- function(var, default) {
  value <- Sys.getenv(var, unset = "")
  if (!nzchar(value)) value <- default
  if (!grepl("^(/|[A-Za-z]:[\\\\/])", value)) value <- repo_path(value)
  normalizePath(value, mustWork = FALSE)
}

snsz_root <- resolve_dir("SNSZ_DATA_DIR", Sys.getenv("SNSZ_ROOT", unset = "data"))
dataset.path <- resolve_dir("SNSZ_DATASETS", file.path(snsz_root, "datasets"))
figures.path <- resolve_dir("SNSZ_FIGURES", file.path(snsz_root, "figures"))
tables.path <- resolve_dir("SNSZ_TABLES", file.path(snsz_root, "tables"))
input.path <- resolve_dir("SNSZ_INPUT", file.path(snsz_root, "input"))
