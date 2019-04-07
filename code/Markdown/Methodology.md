Methodology
================
Everet Rummel

Background
==========

*New Jersey Family* magazine created a list of ["New Jersey's Best Towns for Families"](https://www.njfamily.com/New-Jerseys-Best-Towns-for-Families/). An [obvious question](https://twitter.com/hobokenurbanist/status/1114592402336100355) arose: How dense and racially diverse are the top towns in this list?

Objectives
==========

Using most recent, highest quality data available:

-   Calculate a measure of racial diversity for all municipalities in New Jersey
-   Calculate population density for all municipalities in New Jersey
-   Calculate diversity/density rank and percentile for all municipalities

Code
====

I did everything in `code/R/calculate.R`. See that script for all the details. See below for a summary in English.

Source Data
===========

American Community Survey, 5-year Public Use Micro Sample, 2013-2017. The Census Bureau provides estimates for county subdivisions, which basically equal municipalities, so I use those summary tables.

Variables
---------

### Race, Population

[Table B03002: HISPANIC OR LATINO ORIGIN BY RACE](https://factfinder.census.gov/bkmk/table/1.0/en/ACS/17_5YR/B03002/0400000US34.06000).

### Land area

[American FactFinder](https://factfinder.census.gov/bkmk/table/1.0/en/DEC/10_SF1/GCTPH1.ST16/0400000US34) only provides *rounded* land area. For more accurate land area data, I downloaded the [2017 TIGER/Line shapefile](https://www.census.gov/geographies/mapping-files/time-series/geo/tiger-line-file.2017.html) for New Jersey (see: [direct download link](https://www2.census.gov/geo/tiger/TIGER2017/COUSUB/tl_2017_34_cousub.zip)).

Universe
========

Each record is a county subdivision, which I'm calling a "municipality" here.

I exclude municipalities with populations lower than the median, 8,244.

Calculations
============

To measure diversity, I calculate the [Gini-Simpson Index](https://en.wikipedia.org/wiki/Diversity_index#Gini%E2%80%93Simpson_index). If any economists are reading this, the Gini-Simpson Index is one minus the [Herfindahl–Hirschman Index](https://en.wikipedia.org/wiki/Herfindahl_index). Hereafter, I'll refer to it as the "Diversity Index" in title-case.

The value of the Diversity Index for a given municipality can be interpreted as the probability that two randomly selected residents are of a different race. For example: Two random residents in Jersey City have a ~75% chance of identifying as different races.

The Diversity Index is calculate as follows:

$D = 1 - \\sum\_{i = 1}^{N} p\_i$

where *p*<sub>*i*</sub> is the percent of the total municipality population identifying as racial group *i*, and *N* is the total number of racial groups.

There are 7 racial groups in the Census: White, Black or African American, American Indian and Alaska Native, Asian, Native Hawaiian and Other Pacific Islander, Two or more races, or Some other race. If you glance at the [HISPANIC OR LATINO ORIGIN BY RACE](https://factfinder.census.gov/bkmk/table/1.0/en/ACS/17_5YR/B03002/0400000US34.06000) table, you'll notice many people identifying with Hispanic ethnicity identify as "Some other race".

Special Note About Hispanic Individuals
---------------------------------------

Because "Hispanic" is an ethnicity, not a racial group (according to the Census Bureau's admittedly imperfect definitions), **I do not use the Hispanic variable to calculate the Diversity Index.** In doing so, I'm not leaving out Hispanic people. Most of the people identifying as "some other race" are Hispanic. All other Hispanic people identify as white, black, asian, etc, and so they're included in the count of the race with which they identify.

Validation
==========

My results can be compared to the Diversity Index calculated for every municipality in New Jersey by NJ.com's [Disha Raychaudhuri](https://twitter.com/Disha_RC) in [this article](https://www.nj.com/data/2019/02/the-25-most-racially-diverse-towns-in-nj-ranked.html). My rankings match theirs almost exactly. My calculations are off by about a hundredth of a percentage point for each municipality. They claim to have followed [this methodology](https://www.usatoday.com/story/news/nation/2014/10/21/diversity-index-data-how-we-did-report/17432103/) for calculating the Diversity Index from ACS data, but I matched their results by *not* following that methodology.

Note: While Raychaudhuri excludes municipalities with populations lower than 10,000, I exclude those with populations lower than the median, 8,244.

My Environment
==============

Here are the R packages directly loaded in this analysis:

``` r
library(dplyr)
```

    ## 
    ## Attaching package: 'dplyr'

    ## The following objects are masked from 'package:stats':
    ## 
    ##     filter, lag

    ## The following objects are masked from 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

``` r
library(readr)
library(scales)
```

    ## 
    ## Attaching package: 'scales'

    ## The following object is masked from 'package:readr':
    ## 
    ##     col_factor

``` r
library(sf)
```

    ## Linking to GEOS 3.7.0, GDAL 2.4.0, PROJ 5.2.0

Here is my session info:

``` r
sessionInfo()
```

    ## R version 3.5.3 (2019-03-11)
    ## Platform: x86_64-pc-linux-gnu (64-bit)
    ## Running under: Ubuntu 18.04.2 LTS
    ## 
    ## Matrix products: default
    ## BLAS: /usr/lib/x86_64-linux-gnu/blas/libblas.so.3.7.1
    ## LAPACK: /usr/lib/x86_64-linux-gnu/lapack/liblapack.so.3.7.1
    ## 
    ## locale:
    ##  [1] LC_CTYPE=en_US.UTF-8       LC_NUMERIC=C              
    ##  [3] LC_TIME=en_US.UTF-8        LC_COLLATE=en_US.UTF-8    
    ##  [5] LC_MONETARY=en_US.UTF-8    LC_MESSAGES=en_US.UTF-8   
    ##  [7] LC_PAPER=en_US.UTF-8       LC_NAME=C                 
    ##  [9] LC_ADDRESS=C               LC_TELEPHONE=C            
    ## [11] LC_MEASUREMENT=en_US.UTF-8 LC_IDENTIFICATION=C       
    ## 
    ## attached base packages:
    ## [1] stats     graphics  grDevices utils     datasets  methods   base     
    ## 
    ## other attached packages:
    ## [1] sf_0.7-3      scales_1.0.0  readr_1.3.1   dplyr_0.8.0.1 knitr_1.22   
    ## 
    ## loaded via a namespace (and not attached):
    ##  [1] Rcpp_1.0.1       magrittr_1.5     units_0.6-2      hms_0.4.2       
    ##  [5] tidyselect_0.2.5 munsell_0.5.0    colorspace_1.4-1 R6_2.4.0        
    ##  [9] rlang_0.3.3      stringr_1.4.0    tools_3.5.3      grid_3.5.3      
    ## [13] xfun_0.6         e1071_1.7-1      DBI_1.0.0        class_7.3-15    
    ## [17] htmltools_0.3.6  yaml_2.2.0       digest_0.6.18    assertthat_0.2.1
    ## [21] tibble_2.1.1     crayon_1.3.4     purrr_0.3.2      glue_1.3.1      
    ## [25] evaluate_0.13    rmarkdown_1.12   stringi_1.4.3    compiler_3.5.3  
    ## [29] pillar_1.3.1     classInt_0.3-1   pkgconfig_2.0.2

Results
=======

The full cleaned dataset output by `calculate.R` is in `data/output/NJ_20132017_diversity_density.csv`. The following results come from this dataset, unless stated otherwise.

The 10 most diverse municipalities in New Jersey:

| Municipality     | Diversity Index |  Population density|  Diversity Index rank|  Pop. density rank|  Diversity Index percentile|  Pop. density percentile|  Population, 2013-17|  Square miles| pct Asian | pct Black | pct Two or more | pct Native American | pct Other race | pct Pacific Islander | pct White | pct Hispanic | pct Non-Hispanic |
|:-----------------|:----------------|-------------------:|---------------------:|------------------:|---------------------------:|------------------------:|--------------------:|-------------:|:----------|:----------|:----------------|:--------------------|:---------------|:---------------------|:----------|:-------------|:-----------------|
| Jersey City      | 73.8%           |               17975|                     1|                  9|                         100|                       97|               265932|     14.794660| 25.4%     | 24.0%     | 3.2%            | 0.4%                | 11.6%          | 0.1%                 | 35.4%     | 28.8%        | 71.2%            |
| Atlantic City    | 72.3%           |                3632|                     2|                121|                         100|                       58|                39075|     10.759121| 18.2%     | 36.2%     | 4.2%            | 0.4%                | 9.0%           | 0.0%                 | 32.0%     | 29.3%        | 70.7%            |
| Paterson         | 72.1%           |               17578|                     3|                 10|                          99|                       97|               147890|      8.413166| 3.9%      | 27.8%     | 5.5%            | 0.1%                | 32.8%          | 0.0%                 | 30.0%     | 60.7%        | 39.3%            |
| Pennsauken       | 69.8%           |                3423|                     4|                128|                          99|                       55|                35863|     10.478463| 7.4%      | 26.6%     | 3.6%            | 0.5%                | 18.0%          | 0.1%                 | 43.8%     | 31.9%        | 68.1%            |
| Hackensack       | 69.3%           |               10659|                     5|                 31|                          99|                       89|                44673|      4.191269| 10.5%     | 25.3%     | 3.3%            | 0.4%                | 14.7%          | 0.0%                 | 45.8%     | 38.2%        | 61.8%            |
| Lindenwold       | 68.7%           |                4480|                     6|                 95|                          98|                       67|                17481|      3.902021| 1.5%      | 34.0%     | 5.4%            | 0.0%                | 19.5%          | 0.0%                 | 39.5%     | 27.6%        | 72.4%            |
| North Plainfield | 68.4%           |                7869|                     7|                 43|                          98|                       85|                22092|      2.807447| 6.2%      | 20.5%     | 3.2%            | 0.1%                | 24.0%          | 0.0%                 | 46.0%     | 47.1%        | 52.9%            |
| Piscataway       | 68.3%           |                3071|                     8|                139|                          98|                       51|                57695|     18.785289| 38.0%     | 19.8%     | 3.1%            | 0.2%                | 2.4%           | 0.1%                 | 36.3%     | 11.3%        | 88.7%            |
| Camden           | 67.9%           |                8471|                     9|                 39|                          97|                       87|                75550|      8.918425| 3.2%      | 45.4%     | 3.6%            | 0.6%                | 25.9%          | 0.1%                 | 21.2%     | 48.5%        | 51.5%            |
| Englewood        | 67.4%           |                5788|                    10|                 73|                          97|                       75|                28509|      4.925441| 12.3%     | 30.8%     | 3.9%            | 0.3%                | 7.0%           | 0.0%                 | 45.8%     | 24.5%        | 75.5%            |

The 10 least diverse municipalities in New Jersey:

| Municipality   | Diversity Index |  Population density|  Diversity Index rank|  Pop. density rank|  Diversity Index percentile|  Pop. density percentile|  Population, 2013-17|  Square miles| pct Asian | pct Black | pct Two or more | pct Native American | pct Other race | pct Pacific Islander | pct White | pct Hispanic | pct Non-Hispanic |
|:---------------|:----------------|-------------------:|---------------------:|------------------:|---------------------------:|------------------------:|--------------------:|-------------:|:----------|:----------|:----------------|:--------------------|:---------------|:---------------------|:----------|:-------------|:-----------------|
| Audubon        | 10.5%           |                5894|                   274|                 70|                           4|                       76|                 8736|      1.482154| 0.2%      | 3.9%      | 1.1%            | 0.0%                | 0.4%           | 0.0%                 | 94.5%     | 2.2%         | 97.8%            |
| Pequannock     | 10.3%           |                2284|                   275|                165|                           3|                       42|                15499|      6.786193| 1.4%      | 0.1%      | 1.6%            | 0.4%                | 1.8%           | 0.0%                 | 94.7%     | 8.3%         | 91.7%            |
| Wall           | 10.2%           |                 849|                   276|                231|                           3|                       19|                26020|     30.657986| 1.0%      | 3.4%      | 0.6%            | 0.0%                | 0.3%           | 0.0%                 | 94.7%     | 3.2%         | 96.8%            |
| Beachwood      | 9.9%            |                4051|                   277|                106|                           2|                       63|                11193|      2.763052| 0.3%      | 1.3%      | 1.9%            | 0.1%                | 1.5%           | 0.0%                 | 94.9%     | 7.8%         | 92.2%            |
| Wantage        | 9.9%            |                 166|                   278|                283|                           2|                        0|                11062|     66.755147| 1.2%      | 0.8%      | 3.1%            | 0.0%                | 0.0%           | 0.0%                 | 94.9%     | 5.5%         | 94.5%            |
| Berkeley       | 8.9%            |                 976|                   279|                224|                           2|                       21|                41676|     42.717142| 1.6%      | 1.5%      | 0.8%            | 0.1%                | 0.6%           | 0.0%                 | 95.4%     | 5.9%         | 94.1%            |
| Lacey          | 6.0%            |                 341|                   280|                268|                           1|                        6|                28444|     83.372914| 1.2%      | 0.8%      | 0.4%            | 0.0%                | 0.7%           | 0.0%                 | 96.9%     | 4.7%         | 95.3%            |
| Upper          | 4.7%            |                 193|                   281|                282|                           1|                        1|                11990|     62.020870| 0.3%      | 0.7%      | 1.1%            | 0.0%                | 0.3%           | 0.0%                 | 97.6%     | 2.2%         | 97.8%            |
| Ocean          | 4.7%            |                 419|                   282|                263|                           1|                        7|                 8838|     21.099528| 0.5%      | 0.5%      | 0.9%            | 0.6%                | 0.0%           | 0.0%                 | 97.6%     | 2.4%         | 97.6%            |
| Point Pleasant | 3.2%            |                5305|                   283|                 79|                           0|                       72|                18519|      3.491037| 0.2%      | 0.4%      | 0.6%            | 0.0%                | 0.4%           | 0.0%                 | 98.4%     | 4.6%         | 95.4%            |

The 10 densest municipalities:

``` r
diversity_density %>%
  arrange(-`Population density`) %>%
  head(n = 10) %>%
  knitr::kable()
```

| Municipality   | Diversity Index |  Population density|  Diversity Index rank|  Pop. density rank|  Diversity Index percentile|  Pop. density percentile|  Population, 2013-17|  Square miles| pct Asian | pct Black | pct Two or more | pct Native American | pct Other race | pct Pacific Islander | pct White | pct Hispanic | pct Non-Hispanic |
|:---------------|:----------------|-------------------:|---------------------:|------------------:|---------------------------:|------------------------:|--------------------:|-------------:|:----------|:----------|:----------------|:--------------------|:---------------|:---------------------|:----------|:-------------|:-----------------|
| Guttenberg     | 58.2%           |               60788|                    39|                  1|                          87|                      100|                11733|     0.1930137| 7.4%      | 3.3%      | 3.9%            | 0.6%                | 26.4%          | 0.0%                 | 58.4%     | 65.8%        | 34.2%            |
| Union City     | 45.1%           |               54246|                   100|                  2|                          65|                      100|                69815|     1.2870037| 4.1%      | 4.8%      | 2.9%            | 0.4%                | 15.5%          | 0.1%                 | 72.1%     | 79.6%        | 20.4%            |
| West New York  | 56.7%           |               53653|                    48|                  3|                          83|                       99|                53345|     0.9942650| 6.2%      | 3.4%      | 3.6%            | 0.2%                | 26.9%          | 0.2%                 | 59.5%     | 76.9%        | 23.1%            |
| Hoboken        | 30.2%           |               43287|                   174|                  4|                          39|                       99|                54117|     1.2502015| 9.3%      | 2.7%      | 3.4%            | 0.0%                | 1.6%           | 0.0%                 | 82.9%     | 16.2%        | 83.8%            |
| Cliffside Park | 51.2%           |               26012|                    71|                  5|                          75|                       99|                24861|     0.9557670| 16.7%     | 3.3%      | 2.8%            | 0.1%                | 10.2%          | 0.1%                 | 66.9%     | 30.1%        | 69.9%            |
| Passaic        | 60.3%           |               22681|                    31|                  6|                          89|                       98|                71057|     3.1329254| 3.4%      | 9.9%      | 4.0%            | 1.1%                | 24.6%          | 0.1%                 | 56.9%     | 73.2%        | 26.8%            |
| Irvington      | 24.0%           |               18775|                   204|                  7|                          28|                       98|                54715|     2.9141952| 1.5%      | 86.8%     | 1.0%            | 0.0%                | 4.2%           | 0.0%                 | 6.4%      | 9.6%         | 90.4%            |
| Weehawken      | 42.0%           |               18283|                   116|                  8|                          59|                       98|                14268|     0.7804147| 10.0%     | 4.0%      | 4.4%            | 0.7%                | 6.0%           | 0.0%                 | 75.0%     | 37.6%        | 62.4%            |
| Jersey City    | 73.8%           |               17975|                     1|                  9|                         100|                       97|               265932|    14.7946597| 25.4%     | 24.0%     | 3.2%            | 0.4%                | 11.6%          | 0.1%                 | 35.4%     | 28.8%        | 71.2%            |
| Paterson       | 72.1%           |               17578|                     3|                 10|                          99|                       97|               147890|     8.4131661| 3.9%      | 27.8%     | 5.5%            | 0.1%                | 32.8%          | 0.0%                 | 30.0%     | 60.7%        | 39.3%            |

The 10 sparsest:

``` r
diversity_density %>%
  arrange(-`Population density`) %>%
  tail(n = 10) %>%
  knitr::kable()
```

| Municipality | Diversity Index |  Population density|  Diversity Index rank|  Pop. density rank|  Diversity Index percentile|  Pop. density percentile|  Population, 2013-17|  Square miles| pct Asian | pct Black | pct Two or more | pct Native American | pct Other race | pct Pacific Islander | pct White | pct Hispanic | pct Non-Hispanic |
|:-------------|:----------------|-------------------:|---------------------:|------------------:|---------------------------:|------------------------:|--------------------:|-------------:|:----------|:----------|:----------------|:--------------------|:---------------|:---------------------|:----------|:-------------|:-----------------|
| Waterford    | 23.6%           |                 299|                   210|                274|                          26|                        4|                10749|      36.00219| 0.3%      | 4.0%      | 4.8%            | 0.0%                | 3.7%           | 0.0%                 | 87.1%     | 5.9%         | 94.1%            |
| Franklin     | 28.9%           |                 297|                   179|                275|                          37|                        3|                16579|      55.83001| 2.5%      | 6.8%      | 2.8%            | 0.0%                | 4.1%           | 0.0%                 | 83.9%     | 6.9%         | 93.1%            |
| Millstone    | 19.6%           |                 288|                   231|                276|                          19|                        3|                10522|      36.59022| 3.8%      | 1.9%      | 2.5%            | 0.2%                | 1.9%           | 0.2%                 | 89.5%     | 6.6%         | 93.4%            |
| Middle       | 29.3%           |                 265|                   177|                277|                          38|                        2|                18623|      70.30035| 1.3%      | 11.8%     | 2.4%            | 0.1%                | 1.1%           | 0.0%                 | 83.2%     | 6.0%         | 94.0%            |
| Hamilton     | 55.8%           |                 240|                    53|                278|                          82|                        2|                26663|     110.93464| 6.8%      | 19.5%     | 4.2%            | 1.1%                | 5.5%           | 0.1%                 | 62.8%     | 15.5%        | 84.5%            |
| Southampton  | 12.6%           |                 234|                   263|                279|                           7|                        2|                10274|      43.88828| 0.5%      | 2.7%      | 1.8%            | 0.0%                | 1.5%           | 0.0%                 | 93.4%     | 4.4%         | 95.6%            |
| Plumsted     | 10.7%           |                 217|                   273|                280|                           4|                        1|                 8509|      39.13673| 0.8%      | 3.7%      | 0.4%            | 0.0%                | 0.6%           | 0.0%                 | 94.4%     | 8.8%         | 91.2%            |
| Pittsgrove   | 18.2%           |                 201|                   235|                281|                          17|                        1|                 9009|      44.89862| 0.8%      | 6.0%      | 1.5%            | 0.1%                | 1.3%           | 0.0%                 | 90.2%     | 4.3%         | 95.7%            |
| Upper        | 4.7%            |                 193|                   281|                282|                           1|                        1|                11990|      62.02087| 0.3%      | 0.7%      | 1.1%            | 0.0%                | 0.3%           | 0.0%                 | 97.6%     | 2.2%         | 97.8%            |
| Wantage      | 9.9%            |                 166|                   278|                283|                           2|                        0|                11062|      66.75515| 1.2%      | 0.8%      | 3.1%            | 0.0%                | 0.0%           | 0.0%                 | 94.9%     | 5.5%         | 94.5%            |
