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

# ?toupper
simpleCap =
  Vectorize({
    function(x) {
      s <- strsplit(x, " ")[[1]]
      paste(toupper(substring(s, 1, 1)), substring(s, 2),
            sep = "", collapse = " ")
    }
  })


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
         `Best Towns Rank` = as.numeric(`Best Towns Rank`))

best_towns_dupes = best_towns %>%
  mutate(join_town_tmp = gsub(' Twp\\.| Borough$| Township$', '', Town)) %>%
  filter(join_town_tmp %in% join_town_tmp[duplicated(join_town_tmp)]) %>%
  arrange(join_town_tmp) %>%
  mutate(
    join_town = case_when(
      Town == 'Berlin' & `Total Population` == '5,580' ~ 'Berlin township',
      Town == 'Chester Twp.' ~ 'Chester township',
      Town == 'Clinton Twp.' ~ 'Clinton township',
      Town == 'Egg Harbor' & `Total Population` == '43,296' ~
        'Egg Harbor township',
      # There are two Fairfield townships, but in diff counties.
      Town == 'Fairfield' ~ 'Fairfield township',
      Town == 'Franklin Twp.' ~ 'Franklin township',
      Town == 'Hamilton Twp.' ~ 'Hamilton township',
      Town == 'Hopewell Twp.' ~ 'Hopewell township',
      Town == 'Lawrence Twp.' ~ 'Lawrence township',
      Town == 'Lebanon' & `Total Population` == '6,101' ~ 'Lebanon township',
      Town == 'Monroe Twp.' ~ 'Monroe township',
      Town == 'Ocean Twp.' ~ 'Ocean township',
      Town == 'Rockaway' & `Total Population` == '25,494' ~ 'Rockaway township',
      Town == 'Springfield Twp.' ~ 'Springfield township',
      Town == 'Washington Twp.' & County == 'Warren' ~ 'Washington township',
      Town == 'Washington Twp.' & County != 'Warren' ~ 'Washington',
      Town == 'Chatham Twp.' ~ 'Chatham township',
      Town == 'Freehold Township' ~ 'Freehold township',
      Town == 'Mendham Twp.' ~ 'Mendham township',
      Town == 'Raritan Twp.' ~ 'Raritan township',
      Town %in% c('Union Twp.', 'Union Township') ~ 'Union township',
      TRUE ~ join_town_tmp
    )
  ) %>%
  select(-join_town_tmp)

best_townships = best_towns_dupes %>%
  filter(grepl('township', join_town)) %>%
  mutate(identifier = paste(join_town, County, sep = ' '))

best_towns_clean = best_towns %>%
  filter(!Town %in% best_towns_dupes$Town) %>%
  mutate(join_town = gsub(' town$| Twp\\.$| Borough$', '', Town)) %>%
  bind_rows(best_towns_dupes)

dive_dens =
  read_csv(paste0(DATA_READ_DIR,
                  'NJ_1000up_diversity_density_unformat.csv')) %>%
  mutate(
    join_town = gsub(' city$| town$| village$| Village township$| borough$',
                     '',
                     Municipality),
    twp_identifier = paste(join_town, County, sep = ' ')) %>%
  mutate(
    join_town = if_else(!twp_identifier %in% best_townships$identifier,
                        gsub(' township$', '', join_town,
                             ignore.case = TRUE),
                        join_town) %>%
      gsub('Ventnor City', 'Ventnor', .) %>%
      gsub('Margate City', 'Margate', .) %>%
      gsub('Peapack and Gladstone', 'Peapack-Gladstone', .) %>%
      gsub('Egg Harbor City', 'Egg Harbor', .)
  )


############
### Join ###
############

data_join = best_towns_clean %>%
  left_join(dive_dens,
            by = c('join_town',
                   'County')) %>%
  select(-c(`Total Population`, Municipality, join_town))


##############
### Expore ###
##############

mean(data_join$`Diversity Index`)
# [1] 0.3151452
mean(data_join$`Diversity Index`[data_join$`Best Towns Rank` <= 20])
# [1] 0.2721031
mean(data_join$`Diversity Index`[data_join$`Best Towns Rank` <= 10])
# [1] 0.3118671

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
