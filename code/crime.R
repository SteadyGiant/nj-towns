#!/usr/bin/env Rscript

library(dplyr)
library(readr)
library(stringr)

# CIUS doesn't provide GEOIDs or counties for towns. Will have to import a xwalk
# & join by town names later.
ids =
  read_csv('./data/output/diversity_econ.csv') %>%
  select(GEOID, municipality, county) %>%
  mutate(
    municipality = municipality %>%
      str_replace_all(
        c(' city$| borough$| town$| village$| Village township$' = '',
          'township' = 'Township',
          'Belleville Township' = 'Belleville',
          'Bloomfield Township' = 'Bloomfield',
          'Irvington Township' = 'Irvington',
          'Montclair Township' = 'Montclair',
          'City of Orange Township' = 'Orange',
          'Verona Township' = 'Verona',
          'West Orange Township' = 'West Orange')
      ),
    municipality = case_when(
      GEOID == '3401524840' ~ 'Franklin Township, Gloucester County',
      GEOID == '3403524900' ~ 'Franklin Township, Somerset County',
      GEOID == '3400129280' ~ 'Hamilton Township, Atlantic County',
      GEOID == '3402129310' ~ 'Hamilton Township, Mercer County',
      GEOID == '3402139510' ~ 'Lawrence Township, Mercer County',
      GEOID == '3402347280' ~ 'Monroe Township, Gloucester County',
      GEOID == '3401547250' ~ 'Monroe Township, Middlesex County',
      GEOID == '3402554270' ~ 'Ocean Township, Monmouth County',
      GEOID == '3401577180' ~ 'Washington Township, Gloucester County',
      GEOID == '3402777240' ~ 'Washington Township, Morris County',
      TRUE ~ municipality
    )
  )

# get UCR/CIUS data
source('./code/functions/cius.R')
cius = get_agencies(years = 2006:2018)

data_in = cius %>%
  filter(!is.na(population)) %>%
  mutate(
    city = city %>%
      str_replace_all(
          # typos
        c('Burlinton' = 'Burlington', # 2007
          'Glouchester' = 'Gloucester', # 2010
          # Standardize names. Some changed in later years' files.
          ' Borough| Village| County Police Department|[0-9]' = '',
          'Monroe Township$' = 'Monroe Township, Gloucester County',
          'Orange City' = 'Orange',
          'Springfield Township, Union County|^Springfield$' = 'Springfield Township',
          'Washington Township, Mercer County' = 'Robbinsville Township',
          'West Paterson' = 'Woodland Park')
      )
  ) %>%
  rename(municipality = city)

# Princeton Borough absorbed Princeton Township after 2010.
# Combine their pops & crimes in 2010 data.
princetons = data_in %>%
  filter(grepl('Princeton', municipality)) %>%
  group_by(year) %>%
  summarize_at(.vars = vars(-municipality),
               ~ sum(.)) %>%
  ungroup() %>%
  mutate(municipality = 'Princeton')

data_cln = data_in %>%
  filter(!grepl('Princeton', municipality)) %>%
  bind_rows(princetons) %>%
  select(municipality, year, everything()) %>%
  arrange(municipality, year) %>%
  group_by(year)

rm(princetons)

# Newark missing data for 2015
# data_cln %>%
#   count(municipality) %>%
#   filter(n != 13) %>%
#   View()

# median pop over all years
median(data_cln$population)
# [1] 9594.5

# Universe:
#   - At least 10k residents
data_uni = data_cln %>%
  group_by(municipality) %>%
  filter(all(population >= 10000)) %>%
  ungroup()

# Following Pew:
#   - define vicrime rate as vicrimes per 1k residents
#   - show % changes in crime rates, not %pt changes
# https://www.pewresearch.org/fact-tank/2019/10/17/facts-about-crime-in-the-u-s/
data_out = data_uni %>%
  # group for calculting pct changes
  group_by(municipality) %>%
  mutate(
    violent_per1k = (violent_crime / population) * 1000,
    violent_per1k_pct_chg = (violent_per1k / lag(violent_per1k)) - 1,
    property_per1k = (property_crime / population) * 1000,
    property_per1k_pct_chg = (property_per1k / lag(property_per1k)) - 1
  ) %>%
  ungroup() %>%
  mutate(
    state_violent_crime_per1k =
      (sum(violent_crime, na.rm = TRUE) / sum(population, na.rm = TRUE)) * 1000,
    state_property_crime_per1k =
      (sum(property_crime, na.rm = TRUE) / sum(population, na.rm = TRUE)) * 1000
  ) %>%
  left_join(ids, by = 'municipality') %>%
  select(GEOID, municipality, county, year, everything())

write_csv(data_out, path = './data/output/crime.csv')
