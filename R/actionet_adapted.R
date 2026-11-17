# Archetype annotation adapted from ACTIONet.
#
# Source: ACTIONet (https://github.com/shmohammadi86/ACTIONet), function
# annotate.archetypes.using.labels(), modified for the snSZ analysis.
# Copyright (C) Shahin Mohammadi and the ACTIONet authors.
#
# This file is licensed under the GNU General Public License, version 2 or (at
# your option) any later version, the license of ACTIONet. It is NOT covered by
# the MIT license of the rest of this repository. See NOTICE and
# https://www.gnu.org/licenses/old-licenses/gpl-2.0.html.
#
# SPDX-License-Identifier: GPL-2.0-or-later

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
