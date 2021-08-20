# https://www.jtimm.net/2021/08/13/census-2020-some-quick-visuals/
# https://github.com/CoryMcCartan/PL94171
# https://corymccartan.github.io/PL94171/articles/PL94171.html

library(dplyr)
library(PL94171)
library(readr)
library(tigris)

# Get decennial data for county subdivisions.
# https://www2.census.gov/programs-surveys/decennial/2020/data/01-Redistricting_File--PL_94-171/New_Jersey/
# NOTE: The warning message is wrong. 2020 PL files have been released.
pl = PL94171::pl_url("NJ", 2020) %>%
  PL94171::pl_read() %>%
  # print(PL94171::pl_geog_levels)
  PL94171::pl_subset(sumlev = "060") %>%
  PL94171::pl_select_standard(clean_names = TRUE)

# Get county names.
nj_co = tigris::counties("NJ", year = 2020) %>%
  sf::st_drop_geometry() %>%
  dplyr::select(FIPS = COUNTYFP, county = NAME)
# Get county subdivision (municipality) names.
nj_cosub = tigris::county_subdivisions("NJ", year = 2020) %>%
  sf::st_drop_geometry() %>%
  dplyr::select(GEOID, municipality = NAME)


# Get group proportions, diversity index, rankings, & geography stats.
calc = function(dat) {
  dat %>%
    dplyr::mutate(
      dplyr::across(pop_hisp:pop_two, `/`, pop, .names = "pct_{.col}")
    ) %>%
    dplyr::rename_with(~gsub("_pop", "", .), dplyr::starts_with("pct_pop")) %>%
    dplyr::rowwise() %>%
    dplyr::mutate(
      diversity = 1 - sum(dplyr::c_across(dplyr::starts_with("pct_"))^2)
    ) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(
      diversity_rank = dplyr::min_rank(dplyr::desc(diversity)),
      median_diversity = median(diversity)
    ) %>%
    dplyr::arrange(diversity_rank)
}


muni = pl %>%
  # Someone else made this decision for me:
  # https://www.nj.com/data/2019/02/the-25-most-racially-diverse-towns-in-nj-ranked.html
  dplyr::filter(pop > 10000) %>%
  calc() %>%
  dplyr::rename(FIPS = county) %>%
  # Add municipality names.
  dplyr::left_join(nj_cosub, by = "GEOID") %>%
  # Add county names.
  dplyr::left_join(nj_co, by = "FIPS") %>%
  dplyr::rename(name = municipality) %>%
  dplyr::mutate(level = "municipality")
counties = muni %>%
  dplyr::group_by(name = county, FIPS) %>%
  dplyr::summarise(dplyr::across(dplyr::starts_with("pop"), sum)) %>%
  dplyr::ungroup() %>%
  calc() %>%
  dplyr::mutate(level = "county")
state = counties %>%
  dplyr::summarise(dplyr::across(dplyr::starts_with("pop"), sum)) %>%
  calc() %>%
  dplyr::select(-diversity_rank) %>%
  dplyr::mutate(level = "state", name = "New Jersey")
data_out = dplyr::bind_rows(muni, counties, state) %>%
  dplyr::select(
    level,
    name,
    GEOID,
    county,
    FIPS,
    diversity_rank,
    diversity,
    median_diversity,
    dplyr::starts_with("pct"),
    pop,
    dplyr::starts_with("pop_")
  )

readr::write_csv(data_out, "data/diversity_race.csv")
