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
incdist_cosub = get_acs(table = 'S1901',
                        geography = 'county subdivision',
                        state = 'NJ',
                        year = 2017,
                        survey = 'acs5',
                        summary_var = 'S1901_C01_001',
                        cache_table = TRUE)

# get the same for the entire state
# https://factfinder.census.gov/bkmk/table/1.0/en/ACS/17_5YR/S1901/0100000US|0400000US34
incdist_state = get_acs(table = 'S1901',
                        geography = 'state',
                        state = 'NJ',
                        year = 2017,
                        survey = 'acs5',
                        summary_var = 'S1901_C01_001',
                        cache_table = TRUE)

race_diver_uni =
  read_csv('data/output/NJ_diversity_race.csv') %>%
  select(GEOID)

mhi_cosub =
  read_csv(here::here('data/output/NJ_mhi.csv')) %>%
  mutate(GEOID = as.character(GEOID))


##%######################################################%##
#                                                          #
####                      Universe                      ####
#                                                          #
##%######################################################%##

incdist_cosub_uni = incdist_cosub %>%
  rename(num_hh = summary_est) %>%
  # Keep only bracket %s. That's rows 1-11.
  group_by(GEOID) %>%
  # for each town, rows 2-11 are vars for HHs
  slice(2:11) %>%
  ungroup() %>%
  # only incorporated towns
  filter(!grepl('County subdivisions not defined', NAME))

# calc median num HHs
MED_HH = median(incdist_cosub_uni$num_hh)

incdist_cosub_uni %<>%
  # Keep towns w/ pop >= 1k.
  # Use racial diversity dataset, since it's already filtered.
  filter(GEOID %in% race_diver_uni$GEOID)


##%######################################################%##
#                                                          #
####                     Transform                      ####
#                                                          #
##%######################################################%##

incdist_cosub_clean = incdist_cosub_uni %>%
  mutate(pct = estimate / 100,
         NAME = gsub(', New Jersey$', '', NAME)) %>%
  separate(col = NAME,
           into = c('municipality', 'county'),
           sep = ', ') %>%
  mutate(county = gsub(' County$', '', county))

# calculate statewide econ diversity
STATE_ECON_DIVERSITY = incdist_state %>%
  slice(2:11) %>%
  mutate(pct = estimate / 100) %>%
  summarize(econ_diversity = 1 - sum(pct^2)) %>%
  pull(econ_diversity)

# calculate economic diversity index for each town, & other stuff
incdist_cosub_agg = incdist_cosub_clean %>%
  group_by(GEOID, municipality, county, num_hh) %>%
  summarize(econ_diversity = 1 - sum(pct^2)) %>%
  ungroup() %>%
  mutate(econ_diversity_rank = min_rank(desc(econ_diversity)),
         state_econ_diversity = STATE_ECON_DIVERSITY,
         more_econ_diverse_than_state = if_else(
           econ_diversity > state_econ_diversity, 1, 0
         )) %>%
  arrange(econ_diversity_rank)

data_join = incdist_cosub_agg %>%
  left_join(
    select(mhi_cosub,
           GEOID, mhi),
    by = 'GEOID'
  )


##%######################################################%##
#                                                          #
####                      Validate                      ####
#                                                          #
##%######################################################%##

sum(duplicated(data_join$GEOID))
# [1] 0

# compare results to
# https://www.nj.com/data/2019/04/nj-towns-are-increasingly-becoming-rich-or-poor-is-the-middle-class-disappearing.html

MED_HH
# [1] 2979

STATE_ECON_DIVERSITY
# [1] 0.883128
MED_ECON_DIVERSITY = median(incdist_cosub_agg$econ_diversity)
# [1] 0.864891
sum(data_join$more_econ_diverse_than_state)
# [1] 20

summary(data_join)


##%######################################################%##
#                                                          #
####                        Load                        ####
#                                                          #
##%######################################################%##

write_csv(incdist_cosub_agg,
          here::here('data/output/NJ_diversity_econ.csv'))
