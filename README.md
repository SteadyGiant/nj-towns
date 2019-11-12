# nj-towns

A bunch of datasets about New Jersey’s towns and the code I used to build them.
Check [my blog](https://everetr.github.io/) for summaries and graphics.

## Contents

* [`data/output`](data/output) - All datasets. The important ones:
    * [`best_towns.csv`](data/output/best_towns.csv) - "Best Towns for Families
    2019" rankings from 
    [NJ Families magazine](https://www.njfamily.com/new-jerseys-best-towns-for-families-the-list-2019/),
    with income, density, & diversity measures from datasets below added
    * [`crime.csv`](data/output/crime.csv) - Crime counts & rates from the
    [FBI](https://www.fbi.gov/services/cjis/ucr/publications#Crime-in%20the%20U.S.)
    * [`density.csv`](data/output/density.csv) - 
    [Population](https://factfinder.census.gov/bkmk/table/1.0/en/ACS/17_5YR/B01003/0400000US34.06000),
    [square mileage](https://factfinder.census.gov/bkmk/table/1.0/en/DEC/10_SF1/G001/0400000US34.06000),
    density, & rankings calculated from ACS data
    * [`diversity_econ.csv`](data/output/diversity_econ.csv) - Economic 
    diversity calculated from
    [ACS data](https://factfinder.census.gov/bkmk/table/1.0/en/ACS/17_5YR/S1901/0100000US|0400000US34.06000)
    * [`diversity_race.csv`](data/output/diversity_race.csv) - Racial diversity
    calculated from 
    [ACS data](https://factfinder.census.gov/bkmk/table/1.0/en/ACS/17_5YR/B02001/0400000US34.06000)
* [`code/`](code/) - Scripts that built the datasets
    * [`__plan__.R`](code/__plan__.R) - Run all lines of this to build all 
    datasets
* [`reports/`](reports/)
    * [`data_sources.md`](reports/data_sources.md) - Details about the sources f
    or each dataset
    * [`methodology.md`](reports/methodology.md) - Details about decisions I 
    made while building the datasets

## TODO

1.  [Segregation](https://fivethirtyeight.com/features/the-most-diverse-cities-are-often-the-most-segregated/)
2.  [Housing construction](https://www.census.gov/econ/construction.html)
3.  School districts datasets?

## License

[GNU GPL 3](LICENSE.md) for code.
[CC-BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/)
for content except code.

## Code of Conduct

Please note that the ‘nj-towns’ project is released with a
[Contributor Code of Conduct](CODE_OF_CONDUCT.md). By contributing to this 
project, you agree to abide by its terms.
