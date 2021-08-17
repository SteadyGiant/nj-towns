#!/usr/bin/env Rscript

library(dplyr)
library(readr)
library(tidycensus)
library(tidyr)
library(tigris)
library(units)

options(scipen = 999,
        tigris_class = 'sf')
census_api_key(Sys.getenv('CENSUS_API_KEY'))


##%######################################################%##
#                                                          #
####                      Extract                       ####
#                                                          #
##%######################################################%##

# get population
# https://factfinder.census.gov/bkmk/table/1.0/en/ACS/17_5YR/B01003/0400000US34.06000
pop_cosub = get_acs(table = 'B01003',
                    geography = 'county subdivision',
                    state = 'NJ',
                    year = 2017,
                    survey = 'acs5')

# get geographic size
# https://factfinder.census.gov/bkmk/table/1.0/en/DEC/10_SF1/G001/0400000US34.06000
#
# must use tigris instead of tidycensus
# https://github.com/walkerke/tidycensus/issues/164
#
# 2015 most recent shapefile, according to
# https://github.com/walkerke/tigris/blob/master/README.md
geo_cosub =
  county_subdivisions(state = 'NJ', year = 2015) %>%
  as_tibble()


##%######################################################%##
#                                                          #
####                      Universe                      ####
#                                                          #
##%######################################################%##

pop_cosub_uni = pop_cosub %>%
  filter(
    # incorporated towns
    !grepl('County subdivisions not defined', NAME)
    # population at least 1k
    & estimate >= 1000
  )


##%######################################################%##
#                                                          #
####                     Transform                      ####
#                                                          #
##%######################################################%##

pop_cosub_clean = pop_cosub_uni %>%
  separate(col = NAME,
           into = c('municipality', 'county', 'state'),
           sep = ', ') %>%
  mutate(county = gsub(' County$', '', county)) %>%
  select(GEOID, municipality, county,
         population = estimate)

geo_cosub_clean = geo_cosub %>%
  select(GEOID,
         sq_m = ALAND) %>%
  mutate(sq_m = set_units(sq_m, 'm^2'),
         sq_mi = set_units(sq_m, 'mi^2') %>% as.numeric()) %>%
  select(-sq_m)

data_join =
  left_join(pop_cosub_clean, geo_cosub_clean,
            by = 'GEOID') %>%
  mutate(density = population / sq_mi,
         density_rank = min_rank(desc(density)))

data_out = data_join %>%
  arrange(density_rank)


##%######################################################%##
#                                                          #
####                      Validate                      ####
#                                                          #
##%######################################################%##

summary(data_out)


##%######################################################%##
#                                                          #
####                        Load                        ####
#                                                          #
##%######################################################%##

write_csv(data_out, path = './data/output/density.csv')
