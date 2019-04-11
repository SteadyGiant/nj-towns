#!/usr/bin/env Rscript
cat('\014')


##############
### Params ###
##############

READ_URL       = 'https://www.njfamily.com/new-jerseys-best-towns-for-families-the-list-2019/'
DATA_READ_DIR  = './data/output/'
DATA_WRITE_DIR = './data/output/'


#############
### Setup ###
#############

library(dplyr)
library(readr)
library(rvest)


##############
### Import ###
##############

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
         join_town = gsub(' Borough$| Twp\\.$| Township$| town$', '', Town),
         `Best Towns Rank` = as.numeric(`Best Towns Rank`))

dive_dens =
  read_csv(paste0(DATA_READ_DIR,
                  'NJ_20132017_diversity_density_unformatted.csv')) %>%
  mutate(join_town = gsub(' borough$| city$| township$| town$| village$| Village township$', '',
                          Municipality),
         join_town = gsub('Ventnor City', 'Ventnor', join_town),
         join_town = gsub('Margate City', 'Margate', join_town),
         join_town = gsub('Peapack and Gladstone', 'Peapack-Gladstone',
                          join_town))


############
### Join ###
############

data_join = best_towns %>%
  left_join(dive_dens,
            by = c('join_town',
                   'County')) %>%
  select(-c(`Total Population`, Municipality, join_town))


##############
### Expore ###
##############

mean(data_join$`Diversity Index`)
# [1] 0.3118595
mean(data_join$`Diversity Index`[data_join$`Best Towns Rank` < 20])
# [1] 0.2522159
mean(data_join$`Diversity Index`[data_join$`Best Towns Rank` < 10])
# [1] 0.2855

data_join %>%
  pull(`Diversity Index`) %>%
  density(bw = 0.05) %>%
  plot()

abline(v = mean(data_join$`Diversity Index`), col = 'blue')
abline(v = mean(data_join$`Diversity Index`[data_join$`Best Towns Rank` < 20]),
       col = 'red')


##############
### Export ###
##############

write_csv(x = data_join,
          path = './data/output/NJ_best_towns_diversity_density.csv')
