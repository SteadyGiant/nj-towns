#!/usr/bin/env Rscript
cat('\014')


READ_URL = 'https://www.njfamily.com/new-jerseys-best-towns-for-families-the-list-2019/'


library(dplyr)
library(readr)
library(rvest)


best_towns = READ_URL %>%
  xml2::read_html() %>%
  rvest::html_nodes(css = '#post-27575 > div > div > div.entry-content > table') %>%
  rvest::html_table() %>%
  bind_rows() %>%
  # First row is actually var names.
  `names<-`(slice(., 1)) %>%
  slice(-1) %>%
  rename(`Best Towns Rank` = `Town\nRank`) %>%
  mutate(County = gsub(' County', '', County),
         Town = gsub(' Borough$| Twp\\.$', '', Town),
         `Best Towns Rank` = as.numeric(`Best Towns Rank`))

dive_dens =
  read_csv('./data/output/NJ_20132017_diversity_density.csv') %>%
  mutate(join_town = gsub(' borough$| city$| township$| town$| village$', '',
                          Municipality))

data_join = best_towns %>%
  left_join(dive_dens,
            by = c('Town' = 'join_town',
                   'County')) %>%
  select(-c(`Total Population`, Municipality))

data_join %>%
  arrange(`Best Towns Rank`) %>%
  slice(1:20) %>%
  pull(`Diversity Index`)
