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
    join_col = municipality %>%
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
    join_col = case_when(
      GEOID == '3401322385' ~ 'Fairfield Township, Essex County',
      GEOID == '3401524840' ~ 'Franklin Township, Gloucester County',
      GEOID == '3401924870' ~ 'Franklin Township, Hunterdon County',
      GEOID == '3403524900' ~ 'Franklin Township, Somerset County',
      GEOID == '3401528185' ~ 'Greenwich Township, Gloucester County',
      GEOID == '3404128260' ~ 'Greenwich Township, Warren County',
      GEOID == '3400129280' ~ 'Hamilton Township, Atlantic County',
      GEOID == '3402129310' ~ 'Hamilton Township, Mercer County',
      GEOID == '3402139510' ~ 'Lawrence Township, Mercer County',
      GEOID == '3400543290' ~ 'Mansfield Township, Burlington County',
      GEOID == '3404143320' ~ 'Mansfield Township, Warren County',
      GEOID == '3402347280' ~ 'Monroe Township, Gloucester County',
      GEOID == '3401547250' ~ 'Monroe Township, Middlesex County',
      GEOID == '3402554270' ~ 'Ocean Township, Monmouth County',
      GEOID == '3402954300' ~ 'Ocean Township, Ocean County',
      GEOID == '3400569990' ~ 'Springfield Township, Burlington County',
      GEOID == '3403970020' ~ 'Springfield Township, Union County',
      GEOID == '3400377135' ~ 'Washington Township, Bergen County',
      GEOID == '3401577180' ~ 'Washington Township, Gloucester County',
      GEOID == '3402777240' ~ 'Washington Township, Morris County',
      GEOID == '3404177300' ~ 'Washington Township, Warren County',
      TRUE ~ join_col
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
          ' Burough' = '', # Hopewell, 2017
          # wrong
          "Carney's Point Township" = 'Carneys Point Township',
          # Standardize names. Some changed in later years' files.
          ' Borough| Village| County Police Department|[0-9]' = '',
          'Bordentown City' = 'Bordentown',
          'Burlington City' = 'Burlington',
          'Monroe Township$' = 'Monroe Township, Gloucester County',
          'Orange City' = 'Orange',
          'Peapack-Gladstone' = 'Peapack and Gladstone',
          'Washington Township, Mercer County' = 'Robbinsville Township',
          'West Paterson' = 'Woodland Park')
      ),
    # Springfield Townships are particularly annoying
    city = case_when(
      grepl('Springfield', city)
      & population > 10000 ~ 'Springfield Township, Union County',
      grepl('Springfield', city)
      & population < 10000 ~ 'Springfield Township, Burlington County',
      TRUE ~ city
    )
  )

# Princeton Borough absorbed Princeton Township after 2010.
# Combine their pops & crimes in 2010 data.
princetons = data_in %>%
  filter(grepl('Princeton', city)) %>%
  group_by(year) %>%
  summarize_at(.vars = vars(-city),
               ~ sum(.)) %>%
  ungroup() %>%
  mutate(city = 'Princeton')

data_cln = data_in %>%
  filter(!grepl('Princeton', city)) %>%
  bind_rows(princetons) %>%
  select(city, year, everything()) %>%
  arrange(city, year) %>%
  group_by(year)

rm(princetons)

# Newark missing data for 2015
# data_cln %>%
#   count(city) %>%
#   filter(n != 13) %>%
#   View()

# median pop over all years
# median(data_cln$population)
# [1] 9594.5

# Universe:
#   - At least 1k residents
data_uni = data_cln %>%
  group_by(city) %>%
  filter(all(population >= 1000)) %>%
  ungroup()

# Following Pew:
#   - define vicrime rate as vicrimes per 1k residents
#   - show % changes in crime rates, not %pt changes
# https://www.pewresearch.org/fact-tank/2019/10/17/facts-about-crime-in-the-u-s/
data_out = data_uni %>%
  # group for calculting pct changes
  group_by(city) %>%
  mutate(
    violent_per1k = (violent_crime / population) * 1000,
    violent_per1k_pct_chg = (violent_per1k / lag(violent_per1k)) - 1,
    property_per1k = (property_crime / population) * 1000,
    property_per1k_pct_chg = (property_per1k / lag(property_per1k)) - 1
  ) %>%
  ungroup() %>%
  mutate(
    state_violent_crime_per1k =
      (sum(violent_crime, na.rm = TRUE) / population) * 1000,
    state_property_crime_per1k =
      (sum(property_crime, na.rm = TRUE) / population) * 1000
  ) %>%
  left_join(ids, by = c('city' = 'join_col')) %>%
  select(-city) %>%
  select(GEOID, municipality, county, year, everything())

# Ship Bottom has no counterpart in ACS(?). Oh well.

write_csv(data_out, path = './data/output/crime.csv')
