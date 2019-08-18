


# https://factfinder.census.gov/bkmk/table/1.0/en/ACS/17_5YR/B19013/0400000US34.06000
mhi_cosub = get_acs(table = 'B19013',
                    geography = 'county subdivision',
                    state = 'NJ',
                    year = 2017,
                    survey = 'acs5',
                    cache_table = TRUE)
