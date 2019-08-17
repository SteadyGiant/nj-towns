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
  filter(
    # only incorporated towns
    !grepl('County subdivisions not defined', NAME)
    # drop num HHs
    & variable != 'S1901_C01_001'
  )

# calc median num HHs
MED_HH = median(incdist_cosub_uni$num_hh)

incdist_cosub_uni %<>%
  # keep towns w/ num HHs at or above median
  filter(num_hh >= MED_HH)


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
  mutate(county = gsub(' County$', '', county)) %>%
  # this isn't that serious
  select(-c(moe, summary_moe))

# calculate statewide econ diversity
STATE_ECON_DIVERSITY = incdist_state %>%
  slice(2:11) %>%
  mutate(pct = estimate / 100) %>%
  summarize(econ_diversity = 1 - sum(pct^2)) %>%
  pull(econ_diversity)

# calculate economic diversity index for each town, & other stuff
incdist_cosub_agg = incdist_cosub_clean %>%
  group_by(GEOID, municipality, county) %>%
  summarize(econ_diversity = 1 - sum(pct^2)) %>%
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

# compare results to
# https://www.nj.com/data/2019/04/nj-towns-are-increasingly-becoming-rich-or-poor-is-the-middle-class-disappearing.html

MED_HH
# [1] 2979

STATE_ECON_DIVERSITY
# [1] 0.883128
MED_ECON_DIVERSITY = median(incdist_cosub_agg$econ_diversity)
# [1] 0.864891
sum(incdist_cosub_agg$more_econ_diverse_than_state)
# [1] 15


##%######################################################%##
#                                                          #
####                        Load                        ####
#                                                          #
##%######################################################%##

write.csv(x = incdist_cosub_agg,
          file = here::here('data/output/NJ_diversity_econ.csv'),
          row.names = FALSE)
