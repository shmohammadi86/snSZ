# Static repository checks for snSZ (run with `make check`).
#
# 1. Every notebook starts with front matter and the documentation header
#    (Purpose, Inputs, Outputs, Paper item, Run notes).
# 2. The R code of every notebook (extracted with knitr::purl) and every file
#    under R/, config/ and scripts/ parses.
# 3. No tracked file contains an absolute home path.
#
# Exits with status 1 on the first class of failure, after reporting all issues.

failures <- character()
fail <- function(msg) failures <<- c(failures, msg)

notebooks <- list.files("notebooks", pattern = "\\.Rmd$", recursive = TRUE, full.names = TRUE)
for (nb in notebooks) {
  txt <- readLines(nb, warn = FALSE)
  if (!identical(txt[1], "---")) fail(sprintf("%s: missing front matter", nb))
  for (key in c("**Purpose.**", "**Inputs.**", "**Outputs.**", "**Paper item.**", "**Run notes.**")) {
    if (!any(startsWith(txt, key))) fail(sprintf("%s: missing header field %s", nb, key))
  }
  tmp <- tempfile(fileext = ".R")
  invisible(knitr::purl(nb, output = tmp, quiet = TRUE, documentation = 0))
  res <- tryCatch(parse(tmp), error = function(e) e)
  if (inherits(res, "error")) fail(sprintf("%s: R code does not parse: %s", nb, conditionMessage(res)))
}

r_files <- list.files(c("R", "config", "scripts"), pattern = "\\.R$", recursive = TRUE, full.names = TRUE)
for (f in r_files) {
  res <- tryCatch(parse(f), error = function(e) e)
  if (inherits(res, "error")) fail(sprintf("%s: does not parse: %s", f, conditionMessage(res)))
}

tracked <- system2("git", c("ls-files"), stdout = TRUE)
for (f in setdiff(tracked[file.exists(tracked)], "scripts/check_repo.R")) {
  txt <- readLines(f, warn = FALSE)
  if (any(grepl("(~/|/home/|/Users/)", txt))) fail(sprintf("%s: contains an absolute home path", f))
}

if (length(failures)) {
  cat(paste0("FAIL ", failures, "\n"), sep = "")
  quit(status = 1)
}
cat(sprintf("OK: %d notebooks, %d R files, %d tracked files checked\n",
            length(notebooks), length(r_files), length(tracked)))
