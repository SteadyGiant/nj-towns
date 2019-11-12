#!/usr/bin/env Rscript

library(dplyr)
library(readr)
library(tidycensus)
library(tidyr)

options(scipen = 999)
census_api_key(Sys.getenv('CENSUS_API_KEY'))

# get median household income
# https://factfinder.census.gov/bkmk/table/1.0/en/ACS/17_5YR/B19013/0400000US34.06000
data_in = get_acs(table = 'B19013',
                  geography = 'county subdivision',
                  state = 'NJ',
                  year = 2017,
                  survey = 'acs5')

data_uni = data_in %>%
  # incorporated towns
  filter(!grepl('County subdivisions not defined', NAME))

data_out = data_uni %>%
  separate(col = NAME,
           into = c('municipality', 'county', 'state'),
           sep = ', ') %>%
  mutate(county = gsub(' County$', '', county)) %>%
  select(-c(state, variable, moe)) %>%
  rename(mhi = estimate)

write_csv(data_out, path = './data/output/mhi.csv')
