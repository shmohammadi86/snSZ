# Helper functions shared by the snSZ notebooks.
#
# Sourced by every notebook through its setup chunk, after config/paths.R.
# Functions cover four tasks:
#   1. Storing and loading results (datasets, tables, figures).
#   2. Sample quality control (outlier samples by excitatory-neuron fraction).
#   3. Individual-level transcriptional deviation (TD) scores.
#   4. Annotation of ACTIONet archetypes and transcription factor enrichment.
#
# Synapse access is optional: functions that can fetch from Synapse do so only
# when the synapser package is installed and the user is logged in.

# Synapse locations used during the study (controlled access; see docs/data.md).
synapse.project.id <- "syn22755334"
synapse.results.folder <- "syn25910026"

# ---------------------------------------------------------------------------
# 1. Storing and loading results
# ---------------------------------------------------------------------------

#' Save an R object as an RDS dataset
#'
#' @param obj Object to save.
#' @param name File name without extension; the file is `<name>.rds`.
#' @param description Unused; kept for compatibility with earlier calls.
#' @param dataset.path Output directory. Defaults to `dataset.path` from
#'   config/paths.R when that variable exists, otherwise `results/datasets`.
#' @return The written file path, invisibly.
storeDataset <- function(obj, name, description = NULL,
                         dataset.path = get0("dataset.path", ifnotfound = "results/datasets")) {
  dir.create(dataset.path, recursive = TRUE, showWarnings = FALSE)
  file_path <- file.path(dataset.path, paste0(name, ".rds"))
  readr::write_rds(obj, file = file_path)
  invisible(file_path)
}

#' Save one or more data frames as sheets of an Excel workbook
#'
#' @param DFs Named list of data frames; each becomes one sheet. Unnamed lists
#'   get sheets `Table1`, `Table2`, and so on.
#' @param name File name without extension; the file is `<name>.xlsx`.
#' @param description Unused; kept for compatibility with earlier calls.
#' @param tables.path Output directory.
#' @return The written file path, invisibly.
storeTable <- function(DFs, name, description = NULL,
                       tables.path = get0("tables.path", ifnotfound = "results/tables")) {
  if (is.null(names(DFs))) {
    names(DFs) <- paste0("Table", seq_along(DFs))
  }
  dir.create(tables.path, recursive = TRUE, showWarnings = FALSE)
  wb <- openxlsx::createWorkbook()
  for (n in names(DFs)) {
    openxlsx::addWorksheet(wb = wb, sheetName = n)
    openxlsx::writeData(wb, sheet = n, DFs[[n]])
  }
  file_path <- file.path(tables.path, paste0(name, ".xlsx"))
  openxlsx::saveWorkbook(wb, file_path, overwrite = TRUE)
  invisible(file_path)
}

#' Save a plot as PNG (300 dpi) or PDF
#'
#' @param gg A ggplot, grob, ComplexHeatmap object, or anything that prints
#'   to a graphics device.
#' @param name File name without extension.
#' @param extension Either `"png"` or `"pdf"`.
#' @param description Unused; kept for compatibility with earlier calls.
#' @param width,height Size in inches.
#' @param figures.path Output directory.
#' @return The written file path, invisibly.
storeFigure <- function(gg, name, extension, description = NULL, width = 10, height = 8,
                        figures.path = get0("figures.path", ifnotfound = "results/figures")) {
  extension <- match.arg(extension, c("png", "pdf"))
  dir.create(figures.path, recursive = TRUE, showWarnings = FALSE)
  file_path <- file.path(figures.path, paste0(name, ".", extension))
  if (extension == "png") {
    png(file_path, width = width, height = height, units = "in", res = 300)
  } else {
    pdf(file_path, width = width, height = height)
  }
  print(gg)
  dev.off()
  invisible(file_path)
}

#' Load an RDS dataset written by `storeDataset()`
#'
#' @param name File name without extension.
#' @param dataset.path Directory holding `<name>.rds`.
#' @return The stored object.
loadDataset <- function(name, dataset.path = get0("dataset.path", ifnotfound = "results/datasets")) {
  file_path <- file.path(dataset.path, paste0(name, ".rds"))
  if (!file.exists(file_path)) {
    stop(sprintf("Dataset not found: %s (set the paths in config/paths.R)", file_path))
  }
  readr::read_rds(file_path)
}

#' Load an input file, fetching it from Synapse when it is missing locally
#'
#' Reads `<name>.<extension>` from `input.path`. When the file is absent and the
#' synapser package is available, the file is downloaded from the study's
#' Synapse input folder first (requires a prior `synapser::synLogin()`).
#'
#' @param name File name without extension.
#' @param extension One of `csv`, `tsv`, `tab`, `txt`, `rds`, `RDS`.
#' @param input.path Local input directory.
#' @return A tibble for delimited files, or the stored object for RDS files.
loadInputDataset <- function(name, extension, input.path = get0("input.path", ifnotfound = "input")) {
  file_name <- paste(name, extension, sep = ".")
  file_path <- file.path(input.path, file_name)
  if (!file.exists(file_path)) {
    if (!requireNamespace("synapser", quietly = TRUE)) {
      stop(sprintf("Input not found: %s, and synapser is not installed", file_path))
    }
    input.folder <- synapser::synStore(synapser::Folder(name = "input", parentId = synapse.project.id))
    syn.files <- synapser::synGetChildren(input.folder$properties$id)$asList()
    hit <- Filter(function(f) f$name == file_name, syn.files)
    if (length(hit) == 0) {
      stop(sprintf("Did not find %s on Synapse", file_name))
    }
    synapser::synGet(hit[[1]]$id, downloadLocation = input.path)
  }
  if (extension == "csv") {
    readr::read_csv(file_path, col_types = readr::cols())
  } else if (extension %in% c("tsv", "tab", "txt")) {
    readr::read_tsv(file_path, col_types = readr::cols())
  } else if (extension %in% c("rds", "RDS")) {
    readr::read_rds(file_path)
  } else {
    stop(sprintf("Unsupported extension: %s", extension))
  }
}

# ---------------------------------------------------------------------------
# 2. Sample quality control
# ---------------------------------------------------------------------------

#' Identify outlier samples by their excitatory-neuron fraction
#'
#' Computes, for each individual, the percentage of nuclei assigned to
#' excitatory neuron types (labels starting with `Ex`, excluding `Ex-NRGN`) and
#' flags individuals outside `[min.perc, max.perc]`. This is the rule used in
#' the study to remove five outlier samples.
#'
#' @param metadata Cell-level metadata with columns `Celltype` (factor) and `ID`
#'   (individual), for example `ACTIONet_summary$metadata`.
#' @param min.perc,max.perc Accepted range of the excitatory-neuron percentage.
#' @return Character vector of flagged individual IDs.
identify_outlier_samples <- function(metadata, min.perc = 10, max.perc = 80) {
  ncells <- table(metadata$Celltype, metadata$ID)
  freq <- 100 * sweep(ncells, 2, colSums(ncells), "/")
  ex.rows <- grepl("^Ex", rownames(freq)) & !grepl("^Ex-NRGN", rownames(freq))
  ex.perc <- colSums(freq[ex.rows, , drop = FALSE])
  names(ex.perc)[ex.perc < min.perc | ex.perc > max.perc]
}

# ---------------------------------------------------------------------------
# 3. Transcriptional deviation scores
# ---------------------------------------------------------------------------

#' Transcriptional deviation (TD) scores per individual and cell type
#'
#' For each cell type, correlates every individual's pseudobulk profile with
#' the cell type's DE statistic vector, using a partial Pearson correlation that
#' controls for the mean expression across individuals. Averaging TD scores
#' over neuronal cell types gives the transcriptional pathology score (TPS).
#'
#' @param DE.stats Gene by cell-type matrix of DE statistics (for example
#'   limma t-statistics); column names must match assay names of `pb.sce`.
#' @param pb.sce Pseudobulk SingleCellExperiment with one assay per cell type
#'   and one column per individual.
#' @return Individual by cell-type matrix of TD scores (NA set to 0).
TD.scores <- function(DE.stats, pb.sce) {
  common.genes <- intersect(rownames(DE.stats), rownames(pb.sce))
  X.DE <- DE.stats[common.genes, , drop = FALSE]
  scores <- sapply(seq_len(ncol(X.DE)), function(i) {
    x <- X.DE[, i]
    Y <- SummarizedExperiment::assays(pb.sce)[[colnames(X.DE)[[i]]]][common.genes, ]
    z <- Matrix::rowMeans(Y)
    apply(Y, 2, function(y) {
      suppressWarnings(ppcor::pcor.test(x, y, z, method = "pearson")$estimate)
    })
  })
  colnames(scores) <- colnames(X.DE)
  rownames(scores) <- colnames(pb.sce)
  scores[is.na(scores)] <- 0
  scores
}

# ---------------------------------------------------------------------------
# 4. Archetype annotation and transcription factor enrichment
# ---------------------------------------------------------------------------

#' Annotate ACTIONet archetypes (cell states) with discrete labels
#'
#' Scores each archetype for each label by comparing the archetype footprint of
#' cells carrying the label with all other cells, then assigns each archetype
#' its best-scoring label.
#'
#' @param ace ACTIONetExperiment, or a cell by archetype matrix.
#' @param labels Cell labels (vector, or name of a column of `colData(ace)`).
#' @param archetype.slot Name of the archetype footprint in `colMaps(ace)`.
#' @param algorithm `"ttest"` (Welch t-statistic) or `"wilcox"` (AUC minus 0.5,
#'   with -log10 P values in `logPvals`).
#' @return List with `Label` (best label per archetype), `Confidence` (best
#'   score), `Enrichment` (archetype by label scores) and, for `"wilcox"`,
#'   `logPvals`.
annotate.archetypes.using.labels <- function(ace, labels, archetype.slot = "H_unified", algorithm = "ttest") {
  Labels <- ACTIONet:::.preprocess_annotation_labels(labels, ace)
  if (is.matrix(ace) | ACTIONetExperiment:::is.sparseMatrix(ace)) {
    profile <- as.matrix(ace)
  } else {
    profile <- Matrix::t(ACTIONetExperiment::colMaps(ace)[[archetype.slot]])
  }
  Annot <- names(Labels)[match(sort(unique(Labels)), Labels)]
  if (algorithm == "wilcox") {
    wilcox.out <- presto::wilcoxauc(profile, Annot[Labels])
    Enrichment <- do.call(cbind, split(wilcox.out$auc - 0.5, wilcox.out$group))
    logPvals <- -log10(do.call(cbind, split(wilcox.out$pval, wilcox.out$group)))
  } else {
    Enrichment <- sapply(Annot, function(label) {
      mask <- names(Labels) == label
      N.class <- sum(mask)
      N.null <- sum(!mask)
      if ((N.class < 3) | (N.null < 3)) {
        return(rep(0, nrow(profile)))
      }
      class.profile <- profile[, mask]
      null.profile <- profile[, !mask]
      delta.mean <- Matrix::rowMeans(class.profile) - Matrix::rowMeans(null.profile)
      delta.mean / sqrt(apply(class.profile, 1, var) / N.class + apply(null.profile, 1, var) / N.null)
    })
  }
  Enrichment[is.na(Enrichment)] <- 0
  archetypeLabels <- Annot[apply(Enrichment, 1, which.max)]
  rownames(Enrichment) <- paste("A", seq_len(nrow(Enrichment)), "-", archetypeLabels, sep = "")
  out <- list(Label = archetypeLabels, Confidence = apply(Enrichment, 1, max), Enrichment = Enrichment)
  if (algorithm == "wilcox") {
    out$logPvals <- logPvals
  }
  out
}

#' Query the ChEA3 transcription factor enrichment service
#'
#' @param genes Character vector of gene symbols.
#' @param url ChEA3 enrichment endpoint.
#' @return List of data frames, one per ChEA3 library, as returned by the API.
queryChEA3 <- function(genes, url = "https://maayanlab.cloud/chea3/api/enrich/") {
  payload <- list(query_name = "snSZ", gene_set = genes)
  response <- httr::POST(url = url, body = payload, encode = "json")
  jsonlite::fromJSON(httr::content(response, "text"))
}
