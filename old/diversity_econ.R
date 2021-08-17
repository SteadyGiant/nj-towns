#!/usr/bin/env Rscript

library(dplyr)
library(readr)
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
                        summary_var = 'S1901_C01_001')

# get the same for the entire state
# https://factfinder.census.gov/bkmk/table/1.0/en/ACS/17_5YR/S1901/0100000US|0400000US34
incdist_state = get_acs(table = 'S1901',
                        geography = 'state',
                        state = 'NJ',
                        year = 2017,
                        survey = 'acs5',
                        summary_var = 'S1901_C01_001')

# get racial diversity for county subdivisions
race_diver_uni =
  read_csv('./data/output/diversity_race.csv') %>%
  select(GEOID)

# get median household income for county subdivisions
mhi_cosub =
  read_csv('./data/output/mhi.csv') %>%
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
  filter(
    # only incorporated towns
    !grepl('County subdivisions not defined', NAME)
    # Keep towns w/ pop >= 1k.
    # Use racial diversity dataset, since it's already filtered.
    & GEOID %in% race_diver_uni$GEOID
  )


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
  summarize(pct_less10  = pct[variable == 'S1901_C01_002'],
            pct_10_14   = pct[variable == 'S1901_C01_003'],
            pct_15_24   = pct[variable == 'S1901_C01_004'],
            pct_25_34   = pct[variable == 'S1901_C01_005'],
            pct_35_49   = pct[variable == 'S1901_C01_006'],
            pct_50_74   = pct[variable == 'S1901_C01_007'],
            pct_75_99   = pct[variable == 'S1901_C01_008'],
            pct_100_149 = pct[variable == 'S1901_C01_009'],
            pct_150_199 = pct[variable == 'S1901_C01_010'],
            pct_200more = pct[variable == 'S1901_C01_011'],
            econ_diversity = 1 - sum(pct^2)) %>%
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

STATE_ECON_DIVERSITY
# [1] 0.883128
MED_ECON_DIVERSITY = median(incdist_cosub_agg$econ_diversity)
# [1] 0.864891
# [1] 0.861224
sum(data_join$more_econ_diverse_than_state)
# [1] 20

summary(data_join)


##%######################################################%##
#                                                          #
####                        Load                        ####
#                                                          #
##%######################################################%##

write_csv(data_join, path = 'data/output/diversity_econ.csv')
