#!/usr/bin/env Rscript

library(here)
library(rmarkdown)

render(input = here::here('README.Rmd'),
       output_format = 'github_document',
       output_file = here::here('README.md'))

render(input = here::here('code/markdown/methodology.Rmd'),
       output_format = 'github_document',
       output_file = here::here('reports/methodology.md'))
