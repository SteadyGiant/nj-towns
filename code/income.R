#!/usr/bin/env Rscript

library(dplyr)
library(here)
library(readr)
library(tidycensus)
library(tidyr)

options(scipen = 999)

census_api_key(Sys.getenv('CENSUS_API_KEY'))

# https://factfinder.census.gov/bkmk/table/1.0/en/ACS/17_5YR/B19013/0400000US34.06000
mhi_cosub = get_acs(table = 'B19013',
                    geography = 'county subdivision',
                    state = 'NJ',
                    year = 2017,
                    survey = 'acs5',
                    cache_table = TRUE)

mhi_cosub_uni = mhi_cosub %>%
  filter(!grepl('County subdivisions not defined', NAME))

mhi_cosub_clean = mhi_cosub_uni %>%
  separate(col = NAME,
           into = c('municipality', 'county', 'state'),
           sep = ', ') %>%
  mutate(county = gsub(' County$', '', county)) %>%
  select(-c(state, variable, moe)) %>%
  rename(mhi = estimate)

write_csv(x = mhi_cosub_clean,
          path = here::here('data/output/NJ_mhi.csv'))
