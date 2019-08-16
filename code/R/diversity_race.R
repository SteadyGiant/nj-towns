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

# get race counts for county subdivisions in NJ
# https://factfinder.census.gov/bkmk/table/1.0/en/ACS/17_5YR/B02001/0400000US34.06000
race_cosub = get_acs(geography = 'county subdivision',
                     table = 'B02001',
                     year = 2017,
                     state = 'NJ',
                     survey = 'acs5')

# get hispanic origin counts for county subdivisions in NJ
# https://factfinder.census.gov/bkmk/table/1.0/en/ACS/17_5YR/B03003/0400000US34.06000
hisp_cosub = get_acs(geography = 'county subdivision',
                     table = 'B03003',
                     year = 2017,
                     output = 'wide',
                     state = 'NJ',
                     survey = 'acs5')

# get statewide race counts for NJ
# https://factfinder.census.gov/bkmk/table/1.0/en/ACS/17_5YR/B02001/0400000US34
race_state = get_acs(geography = 'state',
                     table = 'B02001',
                     year = 2017,
                     state = 'NJ',
                     survey = 'acs5')


##%######################################################%##
#                                                          #
####                      Universe                      ####
#                                                          #
##%######################################################%##

race_uni = race_cosub %>%
  # Keep only population & counts by race. That's rows 1-8.
  group_by(GEOID) %>%
  slice(1:8) %>%
  mutate(population = estimate[variable == 'B02001_001']) %>%
  ungroup() %>%
  filter(
    # only want incorporated towns
    !grepl('County subdivisions not defined', NAME),
    # drop pop
    variable != 'B02001_001'
  )

# save to display later in a summary
MED_POP = median(race_uni$population)

race_uni %<>%
  # keep towns w/ population at or above median
  filter(population >= MED_POP)


##%######################################################%##
#                                                          #
####                     Transform                      ####
#                                                          #
##%######################################################%##

race_clean = race_uni %>%
  mutate(NAME = gsub(', New Jersey$', '', NAME)) %>%
  separate(col = NAME,
           into = c('municipality', 'county'),
           sep = ', ') %>%
  mutate(county = gsub(' County$', '', county)) %>%
  # this isn't that serious
  select(-moe)

# calculate statewide racial diversity
STATE_RACIAL_DIVERSITY = race_state %>%
  slice(2:8) %>%
  mutate(estimate = estimate / sum(estimate)) %>%
  summarize(racial_diversity = 1 - sum(estimate^2)) %>%
  pull(racial_diversity)

# calculate racial diversity index for each town, & other stuff
race_agg = race_clean %>%
  group_by(GEOID, municipality, county, population) %>%
  mutate(pct = estimate / population) %>%
  summarize(pct_white = pct[variable == 'B02001_002'],
            pct_black = pct[variable == 'B02001_003'],
            pct_natam = pct[variable == 'B02001_004'],
            pct_asian = pct[variable == 'B02001_005'],
            pct_pacis = pct[variable == 'B02001_006'],
            pct_other = pct[variable == 'B02001_007'],
            pct_multi = pct[variable == 'B02001_008'],
            racial_diversity = 1 - sum(pct^2)) %>%
  ungroup() %>%
  mutate(racial_diversity_rank = min_rank(desc(racial_diversity)),
         state_racial_diversity = STATE_RACIAL_DIVERSITY,
         more_racial_diverse_than_state = if_else(
           racial_diversity > state_racial_diversity, 1, 0
         )) %>%
  arrange(racial_diversity_rank)


hisp_clean = hisp_cosub %>%
  mutate(pct_not_hispanic = B03003_002E / B03003_001E,
         pct_hispanic = B03003_003E / B03003_001E) %>%
  select(-c(NAME, matches('[0-9]')))


data_out = race_agg %>%
  left_join(hisp_clean,
            by = 'GEOID')


##%######################################################%##
#                                                          #
####                      Validate                      ####
#                                                          #
##%######################################################%##

# compare resutls to original NJ.com article
# https://www.nj.com/data/2019/03/how-racially-diverse-is-your-town-look-up-using-our-tool.html

MED_POP
# [1] 8244
STATE_RACIAL_DIVERSITY
# [1] 0.5069469
median(data_out$racial_diversity)
# [1] 0.3641735
sum(data_out$more_racial_diverse_than_state)
# [1] 74

summary(data_out)


##%######################################################%##
#                                                          #
####                        Load                        ####
#                                                          #
##%######################################################%##

write.csv(x = data_out,
          file = here::here('data/output/NJ_diversity_race.csv'),
          row.names = FALSE)
