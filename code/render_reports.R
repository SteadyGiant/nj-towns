#!/usr/bin/env Rscript
cat('\014')

library(rmarkdown)

rmarkdown::render(input = './README.Rmd',
                  output_format = 'github_document',
                  output_file = 'README.md',
                  output_dir = './')

rmarkdown::render(input = './code/Markdown/Methodology.Rmd',
                  output_format = 'github_document',
                  output_file   = 'Methodology.md',
                  output_dir    = './reports/')

rmarkdown::render(input = './code/Markdown/racial-diversity-nj.Rmd',
                  output_format = 'html_document',
                  output_file   = 'racial-diversity-nj.html',
                  output_dir    = './reports/')
