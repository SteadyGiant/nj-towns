# https://www.jtimm.net/2021/08/13/census-2020-some-quick-visuals/
# https://github.com/CoryMcCartan/PL94171
# https://corymccartan.github.io/PL94171/articles/PL94171.html

library(dplyr)
library(PL94171)
library(readr)
library(tigris)

# Get county subdivision (municipality) names.
nj_cosubd = tigris::county_subdivisions("NJ", year = 2020) %>%
  sf::st_drop_geometry() %>%
  dplyr::select(GEOID, municipality = NAME)
# Get county names.
nj_co = tigris::counties("NJ", year = 2020) %>%
  sf::st_drop_geometry() %>%
  dplyr::select(COUNTYFP, county = NAME)

# Get decennial data for county subdivisions.
# https://www2.census.gov/programs-surveys/decennial/2020/data/01-Redistricting_File--PL_94-171/New_Jersey/
pl = PL94171::pl_url("NJ", 2020) |>
  PL94171::pl_read() |>
  # print(PL94171::pl_geog_levels)
  PL94171::pl_subset(sumlev = "060")|>
  PL94171::pl_select_standard(clean_names = TRUE)

calc = function(dat, front_cols = NULL) {
  dat %>%
    dplyr::filter(pop > 0) %>%
    dplyr::mutate(
      dplyr::across(pop_hisp:pop_two, `/`, pop, .names = "pct_{.col}")
    ) %>%
    dplyr::rename_with(~gsub("_pop", "", .), dplyr::starts_with("pct_pop")) %>%
    dplyr::rowwise() %>%
    dplyr::mutate(
      diversity = 1 - sum(dplyr::c_across(dplyr::starts_with("pct_"))^2)
    ) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(diversity_rank = dplyr::min_rank(dplyr::desc(diversity))) %>%
    dplyr::arrange(diversity_rank) %>%
    dplyr::rename(county_fips = county) %>%
    dplyr::left_join(nj_co, by = c("county_fips" = "COUNTYFP")) %>%
    dplyr::select(
      dplyr::all_of(front_cols),
      county,
      county_fips,
      diversity,
      diversity_rank,
      dplyr::starts_with("pct_"),
      dplyr::starts_with("pop_")
    )
}

muni = pl %>%
  calc("GEOID") %>%
  dplyr::left_join(nj_cosubd, by = "GEOID") %>%
  dplyr::relocate(municipality)
counties = pl %>%
  dplyr::group_by(county) %>%
  dplyr::summarise(dplyr::across(dplyr::starts_with("pop"), sum)) %>%
  dplyr::ungroup() %>%
  calc() %>%
  dplyr::rename(FIPS = county_fips)

readr::write_csv(muni, "data/diversity_race_municipality.csv")
readr::write_csv(counties, "data/diversity_race_county.csv")
