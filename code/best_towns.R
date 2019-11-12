#!/usr/bin/env Rscript

library(dplyr)
library(readr)
library(rvest)

options(scipen = 999)


##%######################################################%##
#                                                          #
####                      Extract                       ####
#                                                          #
##%######################################################%##

URL = 'https://www.njfamily.com/new-jerseys-best-towns-for-families-the-list-2019/'

data_raw = URL %>%
  read_html() %>%
  html_nodes(css = '#post-27575 > div > div > div.entry-content > table') %>%
  html_table() %>%
  bind_rows()

best_towns = data_raw %>%
  # first row is actually var names
  `names<-`(slice(., 1)) %>%
  slice(-1) %>%
  rename(`Best Towns Rank` = `Town Rank`) %>%
  mutate(County = gsub(' County', '', County),
         `Best Towns Rank` = as.numeric(`Best Towns Rank`))

race_diver = read_csv('./data/output/diversity_race.csv')

econ_diver =
  read_csv('./data/output/diversity_econ.csv') %>%
  select(GEOID, econ_diversity:more_econ_diverse_than_state)

mhi =
  read_csv('./data/output/mhi.csv') %>%
  select(GEOID, mhi)

dens =
  read_csv('./data/output/density.csv') %>%
  select(GEOID, density, density_rank)


##%######################################################%##
#                                                          #
####                     Transform                      ####
#                                                          #
##%######################################################%##

### "Best" towns

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
      # there are two Fairfield townships, but in diff counties
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
      Town == 'Boonton' & `Total Population` == '4,350' ~ 'Boonton township',
      Town == 'Bordentown' & `Total Population` == '12,202' ~ 'Bordentown township',
      Town == 'Burlington' & `Total Population` == '22,824' ~ 'Burlington township',
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
  bind_rows(best_towns_dupes) %>%
  arrange(`Best Towns Rank`)

rm(best_towns, best_towns_dupes)


### Racial diversity

race_diver_clean = race_diver %>%
  mutate(
    join_town = gsub(' city$| town$| village$| Village township$| borough$',
                     '',
                     municipality),
    twp_identifier = paste(join_town, county, sep = ' ')
  ) %>%
  mutate(
    join_town = if_else(!twp_identifier %in% best_townships$identifier,
                        gsub(' township$', '', join_town,
                             ignore.case = TRUE),
                        join_town) %>%
      gsub('Ventnor City', 'Ventnor', .) %>%
      gsub('Margate City', 'Margate', .) %>%
      gsub('Peapack and Gladstone', 'Peapack-Gladstone', .) %>%
      gsub('Egg Harbor City', 'Egg Harbor', .)
  ) %>%
  filter(
    !(municipality == 'Shrewsbury township'
      & population == 1117)
    &
      !(municipality == 'Pemberton borough'
        & population == 1439)
  ) %>%
  select(-twp_identifier) %>%
  select(GEOID, join_town, county, population:pct_hispanic)

rm(best_townships)


### Join data

data_join = best_towns_clean %>%
  left_join(race_diver_clean,
            by = c('join_town',
                   'County' = 'county')) %>%
  left_join(econ_diver, by = 'GEOID') %>%
  left_join(mhi, by = 'GEOID') %>%
  left_join(dens, by = 'GEOID') %>%
  select(-join_town) %>%
  select(GEOID, everything()) %>%
  rename(`Population (ACS, 2012-17)` = population)


##%######################################################%##
#                                                          #
####                      Validate                      ####
#                                                          #
##%######################################################%##

# No dupes from join. Good. That sucked.
sum(duplicated(data_join$`Best Towns Rank`))
# [1] 0


##%######################################################%##
#                                                          #
####                        Load                        ####
#                                                          #
##%######################################################%##

write_csv(data_join, path = './data/output/best_towns.csv')

# save a copy of the raw HTML table
saveRDS(data_raw, file = './data/archive/njfamily.com_SLASH_new-jerseys-best-towns-for-families-the-list-2019')
