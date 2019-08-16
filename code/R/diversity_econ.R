#!/usr/bin/env Rscript

library(dplyr)
library(here)
library(magrittr)
library(tidycensus)
library(tidyr)

options(scipen = 999)

census_api_key(Sys.getenv('CENSUS_API_KEY'))


##%######################################################%##
#                                                          #
####                      Extract                       ####
#                                                          #
##%######################################################%##

# get % of households in each income bracket, for all county subdivisions in NJ
# https://factfinder.census.gov/bkmk/table/1.0/en/ACS/17_5YR/S1901/0100000US|0400000US34.06000
cosub_inc_brackets = get_acs(geography = 'county subdivision',
                             table = 'S1901',
                             year = 2017,
                             state = 'NJ',
                             survey = 'acs5')

# get the same for the entire state
# https://factfinder.census.gov/bkmk/table/1.0/en/ACS/17_5YR/S1901/0100000US|0400000US34
state_inc_brackets = get_acs(geography = 'state',
                             table = 'S1901',
                             year = 2017,
                             state = 'NJ',
                             survey = 'acs5')


##%######################################################%##
#                                                          #
####                      Universe                      ####
#                                                          #
##%######################################################%##

data_uni = cosub_inc_brackets %>%
  # Keep only num HHs & bracket % variables. That's rows 1-11.
  group_by(GEOID) %>%
  # for each town, rows 1-16 are vars for HHs
  slice(1:11) %>%
  ungroup() %>%
  # only want incorporated towns
  filter( !grepl('County subdivisions not defined', NAME) )

# calc median num HHs
MED_POP = median(data_uni$estimate[data_uni$variable == 'S1901_C01_001'])
# [1] 2979

data_uni %<>%
  # keep towns w/ num HHs at or above median
  group_by(GEOID) %>%
  filter(estimate[variable == 'S1901_C01_001'] >= MED_POP) %>%
  ungroup() %>%
  # drop num HHs
  filter(variable != 'S1901_C01_001')


##%######################################################%##
#                                                          #
####                     Transform                      ####
#                                                          #
##%######################################################%##

data_clean = data_uni %>%
  mutate(estimate = estimate / 100,
         NAME = gsub(', New Jersey$', '', NAME)) %>%
  separate(col = NAME,
           into = c('municipality', 'county'),
           sep = ', ') %>%
  mutate(county = gsub(' County$', '', county)) %>%
  # this isn't that serious
  select(-moe)

# calculate statewide econ diversity
STATE_ECON_DIVERSITY = state_inc_brackets %>%
  slice(2:11) %>%
  mutate(estimate = estimate / 100) %>%
  summarize(econ_diversity = 1 - sum(estimate^2)) %>%
  pull(econ_diversity)
# [1] 0.883128

# calculate economic diversity index for each town, & other stuff
data_agg = data_clean %>%
  group_by(GEOID, municipality, county) %>%
  summarize(econ_diversity = 1 - sum(estimate^2)) %>%
  ungroup() %>%
  mutate(econ_diversity_rank = min_rank(desc(econ_diversity)),
         state_econ_diversity = STATE_ECON_DIVERSITY,
         more_econ_diverse_than_state = if_else(
           econ_diversity > state_econ_diversity, 1, 0
         )) %>%
  arrange(econ_diversity_rank)


##%######################################################%##
#                                                          #
####                      Validate                      ####
#                                                          #
##%######################################################%##

MED_ECON_DIVERSITY = median(data_agg$econ_diversity)
# [1] 0.864891

sum(data_agg$more_econ_diverse_than_state)
# [1] 15

# compare results to
# https://www.nj.com/data/2019/04/nj-towns-are-increasingly-becoming-rich-or-poor-is-the-middle-class-disappearing.html


##%######################################################%##
#                                                          #
####                        Load                        ####
#                                                          #
##%######################################################%##

write.csv(x = data_agg,
          file = here::here('data/output/NJ_diversity_econ.csv'),
          row.names = FALSE)
