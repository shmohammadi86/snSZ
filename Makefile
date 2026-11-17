.PHONY: check render help

help:  ## List targets
	@grep -E '^[a-z]+:.*##' Makefile | sed 's/:.*##/:/'

check:  ## Static checks: notebook headers, R parsing, no absolute home paths
	Rscript scripts/check_repo.R

render:  ## Render all notebooks to HTML (chunks are not evaluated by default)
	for nb in $$(find notebooks -name '*.Rmd' | sort); do Rscript -e "rmarkdown::render('$$nb', output_dir = 'docs/rendered', quiet = TRUE)"; done
