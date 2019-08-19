
<!-- README.md is generated from README.Rmd. Please edit that file -->

# nj-towns

This repo contains a bunch of datasets about New Jersey’s towns and the
code I used to build them. Check [my blog](https://everetr.github.io/)
for articles and visualizations. Contributions to this repo are welcome.

The datasets are in the `data/output` folder. Use `code/00_plan.R` to
build all datasets and render all reports in this repo.

[Data sources.](data/data_sources.md)

[Methodology.](reports/Methodology.md)

## Datasets

  - `NJ_best_towns.csv` - *New Jersey Family* magazine ranked the [“Best
    Towns for
    Families”](https://www.njfamily.com/new-jerseys-best-towns-for-families-the-list-2019/)
    in our state. This dataset includes those rankings, as well as data
    on racial and economic diversity, median household income, and
    population density. The add-ons are because I intend to write a blog
    post with this dataset eventually.

  - `NJ_density.csv` - Population, land area, and population density
    rankings.

  - `NJ_diversity_econ.csv` - Economic diversity index and rankings, as
    well as median household income.

  - `NJ_diversity_race.csv` - Racial groups, racial diversity index, and
    rankings.

## TODO

1.  [Segregation](https://fivethirtyeight.com/features/the-most-diverse-cities-are-often-the-most-segregated/)
2.  [Housing
    construction](https://www.census.gov/econ/construction.html)
3.  School districts datasets?

## Code of Conduct

Please note that the ‘nj-towns’ project is released with a [Contributor
Code of Conduct](CODE_OF_CONDUCT.md). By contributing to this project,
you agree to abide by its terms.
