#!/usr/bin/env Rscript
cat('\014')


##############
### Params ###
##############

DATA_READ_DIR  = './data/input/'
DATA_WRITE_DIR = './data/output/'


#############
### Setup ###
#############

library(dplyr)
library(readr)
library(readxl)
library(scales)
library(sf)

options(scipen = 999)


##############
### Import ###
##############

fips_nj_co =
  read_excel('./data/input/all-geocodes-v2017.xlsx',
             skip = 4) %>%
  filter(`State Code (FIPS)` == '34'
         & `Summary Level` == '050') %>%
  mutate(`Area Name (including legal/statistical area description)` =
           gsub(' County', '', `Area Name (including legal/statistical area description)`))

cousubs =
  sf::st_read(dsn = paste0(DATA_READ_DIR,
                           'tl_2017_34_cousub/tl_2017_34_cousub.shp')) %>%
  mutate(GEOID = as.character(GEOID),
         COUNTYFP = as.character(COUNTYFP),
         # https://www.metric-conversions.org/area/square-meters-to-square-miles.htm
         sq_miles = ALAND * 0.00000038610)

race =
  read_csv('./data/input/ACS_17_5YR_B03002/ACS_17_5YR_B03002.csv') %>%
  mutate(GEOID         = as.character(GEO.id2),
         asian_pct     = (HD01_VD06 + HD01_VD16) / HD01_VD01,
         black_pct     = (HD01_VD04 + HD01_VD14) / HD01_VD01,
         multi_pct     = (HD01_VD09 + HD01_VD19) / HD01_VD01,
         natam_pct     = (HD01_VD05 + HD01_VD15) / HD01_VD01,
         other_pct     = (HD01_VD08 + HD01_VD18) / HD01_VD01,
         pacis_pct     = (HD01_VD07 + HD01_VD17) / HD01_VD01,
         white_pct     = (HD01_VD03 + HD01_VD13) / HD01_VD01,
         asian_pct_2   = (HD01_VD06 + HD01_VD16) / (HD01_VD01 - (HD01_VD08 + HD01_VD18)),
         black_pct_2   = (HD01_VD04 + HD01_VD14) / (HD01_VD01 - (HD01_VD08 + HD01_VD18)),
         multi_pct_2   = (HD01_VD09 + HD01_VD19) / (HD01_VD01 - (HD01_VD08 + HD01_VD18)),
         natam_pct_2   = (HD01_VD05 + HD01_VD15) / (HD01_VD01 - (HD01_VD08 + HD01_VD18)),
         pacis_pct_2   = (HD01_VD07 + HD01_VD17) / (HD01_VD01 - (HD01_VD08 + HD01_VD18)),
         white_pct_2   = (HD01_VD03 + HD01_VD13) / (HD01_VD01 - (HD01_VD08 + HD01_VD18)),
         hispan_pct    = HD01_VD12 / HD01_VD01,
         nonhispan_pct = HD01_VD02 / HD01_VD01,
         race_homog    = asian_pct^2 + black_pct^2 + multi_pct^2 + natam_pct^2 + other_pct^2 + pacis_pct^2 + white_pct^2,
         race_homog_2  = asian_pct_2^2 + black_pct_2^2 + multi_pct_2^2 + natam_pct_2^2 + pacis_pct_2^2 + white_pct_2^2,
         ethn_homog    = hispan_pct^2 + nonhispan_pct^2,
         homog         = race_homog_2 * ethn_homog,
         diversity     = 1 - race_homog,
         diversity_2   = 1 - homog)


############
### Join ###
############

data_join = cousubs %>%
  left_join(
    select(fips_nj_co,
           `County Code (FIPS)`,
           county_name = `Area Name (including legal/statistical area description)`),
    by = c('COUNTYFP' = 'County Code (FIPS)')) %>%
  left_join(
    select(race,
           GEOID:diversity_2,
           pop1317 = HD01_VD01),
    by = 'GEOID'
  ) %>%
  # Compare density to
  # https://factfinder.census.gov/bkmk/table/1.0/en/DEC/10_SF1/GCTPH1.ST16/0400000US34
  mutate(density = pop1317 / sq_miles)


################
### Universe ###
################

data_uni = data_join %>%
  filter(NAME != 'County subdivisions not defined')

median(data_uni$pop1317)
# [1] 8244
median(data_uni$density)
# [1] 2163.473

data_uni = data_uni %>%
  # filter(pop1317 >= median(pop1317))
  filter(pop1317 >= 1000)

median(data_uni$pop1317)
# [1] 18622
median(data_uni$density)
# [1] 2957.973


##############
### Export ###
##############

get_diversity_pctile = ecdf(data_uni$diversity)
get_density_pctile   = ecdf(data_uni$density)

data_out = data_uni %>%
  as_tibble() %>%
  mutate(diversity_rank   = min_rank(-diversity),
         density_rank     = min_rank(-density),
         diversity_pctile = get_diversity_pctile(diversity),
         density_pctile   = get_density_pctile(density),
         density          = scales::comma(density, accuracy = 1)) %>%
  arrange(-diversity) %>%
  mutate_at(.vars = vars(diversity_pctile, density_pctile),
            .funs = ~ scales::percent(., accuracy = 1, suffix = '')) %>%
  mutate_at(.vars = vars(diversity, asian_pct:nonhispan_pct),
            .funs = ~ scales::percent(., accuracy = 0.1)) %>%
  select(Municipality = NAMELSAD,
         County = county_name,
         `Diversity Index` = diversity,
         `Population density` = density,
         `Diversity Index rank` = diversity_rank,
         `Pop. density rank` = density_rank,
         `Diversity Index percentile` = diversity_pctile,
         `Pop. density percentile` = density_pctile,
         `Population, 2013-17` = pop1317,
         `Square miles` = sq_miles,
         `pct Asian` = asian_pct,
         `pct Black` = black_pct,
         `pct Two or more` = multi_pct,
         `pct Native American` = natam_pct,
         `pct Other race` = other_pct,
         `pct Pacific Islander` = pacis_pct,
         `pct White` = white_pct,
         `pct Hispanic` = hispan_pct,
         `pct Non-Hispanic` = nonhispan_pct)

write_csv(x = data_out,
          path = paste0(DATA_WRITE_DIR, 'NJ_20132017_diversity_density.csv'))
