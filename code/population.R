#!/usr/bin/env Rscript

library(dplyr)
library(here)
library(magrittr)
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
                    survey = 'acs5',
                    cache_table = TRUE)

# get geography info
# https://factfinder.census.gov/bkmk/table/1.0/en/DEC/10_SF1/G001/0400000US34.06000
#
# must use tigris instead of tidycensus
# https://github.com/walkerke/tidycensus/issues/164
#
# 2015 most recent shapefile, according to
# https://github.com/walkerke/tigris/blob/master/README.md
geo_cosub =
  county_subdivisions(state = 'NJ',
                      year = 2015) %>%
  as_tibble()


##%######################################################%##
#                                                          #
####                      Universe                      ####
#                                                          #
##%######################################################%##

pop_cosub_uni = pop_cosub %>%
  # incorporated towns
  filter(!grepl('County subdivisions not defined', NAME))

# get median pop for validation later
MED_POP = median(pop_cosub_uni$estimate)

pop_cosub_uni %<>%
  # population at least 1k
  filter(estimate >= 1000)


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
         sq_mi = sq_m,
         sq_km = sq_m)

# convert units
units(geo_cosub_clean$sq_mi) = with(ud_units, 'mi^2')
geo_cosub_clean$sq_mi = as.numeric(geo_cosub_clean$sq_mi)
units(geo_cosub_clean$sq_km) = with(ud_units, 'km^2')
geo_cosub_clean$sq_km = as.numeric(geo_cosub_clean$sq_km)

geo_cosub_clean$sq_m = as.numeric(geo_cosub_clean$sq_m)


### Join data

data_join = pop_cosub_clean %>%
  left_join(geo_cosub_clean,
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

MED_POP
# [1] 8244


##%######################################################%##
#                                                          #
####                        Load                        ####
#                                                          #
##%######################################################%##

write_csv(data_out,
          here::here('data/output/NJ_density.csv'))
