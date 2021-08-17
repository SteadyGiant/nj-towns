#!/usr/bin/env Rscript

library(here)
library(rmarkdown)

render(input = './code/markdown/methodology.Rmd',
       output_format = 'github_document',
       output_file = here::here('./reports/methodology.md'))
