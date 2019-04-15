Methodology
================
Everet Rummel

# Background

*New Jersey Family* magazine created a list of [“New Jersey’s Best Towns
for
Families”](https://www.njfamily.com/New-Jerseys-Best-Towns-for-Families/)
(full list
[here](https://www.njfamily.com/new-jerseys-best-towns-for-families-the-list-2019/).
An [obvious
question](https://twitter.com/hobokenurbanist/status/1114592402336100355)
arose: How dense and racially diverse are the top towns in this list?

# Objectives

Using most recent, highest quality data available:

  - Calculate a measure of racial diversity for all municipalities in
    New Jersey
  - Calculate population density for all municipalities in New Jersey
  - Calculate diversity/density rank and percentile for all
    municipalities

# Code

I did everything in [`code/R/calculate.R`](./code/R/calculate.R). See
that script for all the details. See below for a summary in English.

# Source Data

American Community Survey, 5-year Public Use Micro Sample, 2013-2017.
The Census Bureau provides estimates for county subdivisions, which
basically equal municipalities, so I use those summary tables.

## Variables

### Race, Population

[Table B03002: HISPANIC OR LATINO ORIGIN BY
RACE](https://factfinder.census.gov/bkmk/table/1.0/en/ACS/17_5YR/B03002/0400000US34.06000).

### Land area

[American
FactFinder](https://factfinder.census.gov/bkmk/table/1.0/en/DEC/10_SF1/GCTPH1.ST16/0400000US34)
only provides *rounded* land area. For more accurate land area data, I
downloaded the [2017 TIGER/Line
shapefile](https://www.census.gov/geographies/mapping-files/time-series/geo/tiger-line-file.2017.html)
for New Jersey (see: [direct download
link](https://www2.census.gov/geo/tiger/TIGER2017/COUSUB/tl_2017_34_cousub.zip)).

# Universe

Each record is a county subdivision, which I’m calling a “municipality”
here.

I exclude municipalities with populations lower than the median, 36.4%.

# Calculations

To measure diversity, I calculate the [Gini-Simpson
Index](https://en.wikipedia.org/wiki/Diversity_index#Gini%E2%80%93Simpson_index).
If any economists are reading this, the Gini-Simpson Index is one minus
the [Herfindahl–Hirschman
Index](https://en.wikipedia.org/wiki/Herfindahl_index). Hereafter, I’ll
refer to it as the “Diversity Index” in title-case.

The value of the Diversity Index for a given municipality can be
interpreted as the probability that two randomly selected residents are
of a different race. For example: Two random residents in Jersey City
have a ~75% chance of identifying as different races.

The Diversity Index is calculate as follows:

\(D = 1 - \sum_{i = 1}^{N} p_i\)

where \(p_i\) is the percent of the total municipality population
identifying as racial group \(i\), and \(N\) is the total number of
racial groups.

There are 7 racial groups in the ACS: White, Black or African American,
American Indian and Alaska Native, Asian, Native Hawaiian and Other
Pacific Islander, Two or more races, and Some other race. Because
“Hispanic” is not a racial group (according to the Census Bureau’s
admittedly imperfect definitions), **I do not use the Hispanic grouping
to calculate the Diversity Index.** In doing so, I’m not leaving out
Hispanic people. If you glance at the [“HISPANIC OR LATINO ORIGIN BY
RACE”](https://factfinder.census.gov/bkmk/table/1.0/en/ACS/17_5YR/B03002)
summary table, you’ll notice most people identifying as “some other
race” are Hispanic/Latinx in origin. All other Hispanic/Latinx people
identify as White, Black, Asian, etc, and so they’re included in the
count of the race with which they identify.\[^5\]

# Validation

My results can be compared to the Diversity Index calculated for every
municipality in New Jersey by NJ.com’s [Disha
Raychaudhuri](https://twitter.com/Disha_RC) in [this
article](https://www.nj.com/data/2019/02/the-25-most-racially-diverse-towns-in-nj-ranked.html).
My rankings match theirs almost exactly. My calculations are off by
about a hundredth of a percentage point for each municipality. They
claim to have followed [this
methodology](https://www.usatoday.com/story/news/nation/2014/10/21/diversity-index-data-how-we-did-report/17432103/)
for calculating the Diversity Index from ACS data, but I matched their
results by *not* following that methodology.

Note: While Raychaudhuri excludes municipalities with populations lower
than 10,000, I exclude those with populations lower than the median.

# My Environment

Here are the R packages directly loaded in this analysis:

``` r
library(dplyr)
library(readr)
library(scales)
library(sf)
```

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
    ##  [9] rlang_0.3.4      stringr_1.4.0    tools_3.5.3      grid_3.5.3      
    ## [13] xfun_0.6         e1071_1.7-1      DBI_1.0.0        class_7.3-15    
    ## [17] htmltools_0.3.6  yaml_2.2.0       assertthat_0.2.1 digest_0.6.18   
    ## [21] tibble_2.1.1     crayon_1.3.4     purrr_0.3.2      glue_1.3.1      
    ## [25] evaluate_0.13    rmarkdown_1.12   stringi_1.4.3    compiler_3.5.3  
    ## [29] pillar_1.3.1     classInt_0.3-1   pkgconfig_2.0.2

# Results

The full cleaned dataset output by `calculate.R` is in
`data/output/NJ_20132017_dive_dens.csv`. The following results come from
this dataset, unless stated otherwise.

The 10 most diverse municipalities in New
Jersey:

| Municipality             | County    | Population, 2013-17 | Diversity Index | Population density | Diversity Index rank | Pop. density rank | Diversity Index percentile | Pop. density percentile | pct Asian | pct Black | pct White | pct Other race | pct Native American | pct Pacific Islander | pct Two or more | pct Hispanic | pct Non-Hispanic |
| :----------------------- | :-------- | ------------------: | --------------: | -----------------: | -------------------: | ----------------: | -------------------------: | ----------------------: | --------: | --------: | --------: | -------------: | ------------------: | -------------------: | --------------: | -----------: | ---------------: |
| Jersey City city         | Hudson    |              265932 |       0.7382005 |          17974.864 |                    1 |                 9 |                  1.0000000 |               0.9717314 | 0.2539221 | 0.2398658 | 0.3540717 |      0.1156837 |           0.0039070 |            0.0005753 |       0.0319743 |    0.2881827 |        0.7118173 |
| Atlantic City city       | Atlantic  |               39075 |       0.7233136 |           3631.802 |                    2 |               121 |                  0.9964664 |               0.5759717 | 0.1822649 | 0.3623800 | 0.3197441 |      0.0902623 |           0.0035061 |            0.0000000 |       0.0418426 |    0.2926935 |        0.7073065 |
| Paterson city            | Passaic   |              147890 |       0.7212596 |          17578.400 |                    3 |                10 |                  0.9929329 |               0.9681979 | 0.0392048 | 0.2776861 | 0.2997160 |      0.3275137 |           0.0011292 |            0.0000000 |       0.0547502 |    0.6073095 |        0.3926905 |
| Pennsauken township      | Camden    |               35863 |       0.6980178 |           3422.544 |                    4 |               128 |                  0.9893993 |               0.5512367 | 0.0738365 | 0.2659566 | 0.4382511 |      0.1800742 |           0.0048239 |            0.0012548 |       0.0358029 |    0.3187408 |        0.6812592 |
| Hackensack city          | Bergen    |               44673 |       0.6925415 |          10658.585 |                    5 |                31 |                  0.9858657 |               0.8939929 | 0.1046493 | 0.2525015 | 0.4583082 |      0.1468896 |           0.0043651 |            0.0000000 |       0.0332863 |    0.3815280 |        0.6184720 |
| Lindenwold borough       | Camden    |               17481 |       0.6865866 |           4479.986 |                    6 |                95 |                  0.9823322 |               0.6678445 | 0.0147017 | 0.3403695 | 0.3952863 |      0.1952978 |           0.0000000 |            0.0000000 |       0.0543447 |    0.2758995 |        0.7241005 |
| North Plainfield borough | Somerset  |               22092 |       0.6835520 |           7869.070 |                    7 |                43 |                  0.9787986 |               0.8515901 | 0.0617871 | 0.2053232 | 0.4604834 |      0.2395890 |           0.0008148 |            0.0000000 |       0.0320025 |    0.4708944 |        0.5291056 |
| Piscataway township      | Middlesex |               57695 |       0.6827511 |           3071.286 |                    8 |               139 |                  0.9752650 |               0.5123675 | 0.3803449 | 0.1984227 | 0.3628217 |      0.0244735 |           0.0018546 |            0.0009013 |       0.0311812 |    0.1134240 |        0.8865760 |
| Camden city              | Camden    |               75550 |       0.6793024 |           8471.227 |                    9 |                39 |                  0.9717314 |               0.8657244 | 0.0317670 | 0.4539643 | 0.2121774 |      0.2593647 |           0.0063137 |            0.0007015 |       0.0357114 |    0.4848312 |        0.5151688 |
| Englewood city           | Bergen    |               28509 |       0.6741533 |           5788.112 |                   10 |                73 |                  0.9681979 |               0.7455830 | 0.1232944 | 0.3076572 | 0.4578554 |      0.0696271 |           0.0027711 |            0.0000000 |       0.0387948 |    0.2451507 |        0.7548493 |

The 10 least diverse municipalities in New
Jersey:

| Municipality           | County   | Population, 2013-17 | Diversity Index | Population density | Diversity Index rank | Pop. density rank | Diversity Index percentile | Pop. density percentile | pct Asian | pct Black | pct White | pct Other race | pct Native American | pct Pacific Islander | pct Two or more | pct Hispanic | pct Non-Hispanic |
| :--------------------- | :------- | ------------------: | --------------: | -----------------: | -------------------: | ----------------: | -------------------------: | ----------------------: | --------: | --------: | --------: | -------------: | ------------------: | -------------------: | --------------: | -----------: | ---------------: |
| Audubon borough        | Camden   |                8736 |       0.1050283 |          5894.1254 |                  274 |                70 |                  0.0353357 |               0.7561837 | 0.0016026 | 0.0386905 | 0.9451694 |      0.0040064 |           0.0000000 |                    0 |       0.0105311 |    0.0215201 |        0.9784799 |
| Pequannock township    | Morris   |               15499 |       0.1029539 |          2283.9020 |                  275 |               165 |                  0.0318021 |               0.4204947 | 0.0142590 | 0.0014840 | 0.9467062 |      0.0180012 |           0.0037422 |                    0 |       0.0158075 |    0.0833602 |        0.9166398 |
| Wall township          | Monmouth |               26020 |       0.1017452 |           848.7185 |                  276 |               231 |                  0.0282686 |               0.1872792 | 0.0099539 | 0.0339354 | 0.9470792 |      0.0030361 |           0.0000000 |                    0 |       0.0059954 |    0.0321291 |        0.9678709 |
| Beachwood borough      | Ocean    |               11193 |       0.0988250 |          4050.9557 |                  277 |               106 |                  0.0247350 |               0.6289753 | 0.0032163 | 0.0127758 | 0.9488966 |      0.0148307 |           0.0008934 |                    0 |       0.0193871 |    0.0781739 |        0.9218261 |
| Wantage township       | Sussex   |               11062 |       0.0987186 |           165.7101 |                  278 |               283 |                  0.0212014 |               0.0035336 | 0.0117519 | 0.0082264 | 0.9487434 |      0.0002712 |           0.0000000 |                    0 |       0.0310071 |    0.0549629 |        0.9450371 |
| Berkeley township      | Ocean    |               41676 |       0.0894888 |           975.6271 |                  279 |               224 |                  0.0176678 |               0.2120141 | 0.0156445 | 0.0149007 | 0.9539063 |      0.0062386 |           0.0011277 |                    0 |       0.0081822 |    0.0591228 |        0.9408772 |
| Lacey township         | Ocean    |               28444 |       0.0603786 |           341.1660 |                  280 |               268 |                  0.0141343 |               0.0565371 | 0.0118478 | 0.0081915 | 0.9692026 |      0.0068204 |           0.0002461 |                    0 |       0.0036915 |    0.0473914 |        0.9526086 |
| Upper township         | Cape May |               11990 |       0.0471160 |           193.3220 |                  281 |               282 |                  0.0106007 |               0.0070671 | 0.0027523 | 0.0073394 | 0.9760634 |      0.0032527 |           0.0000000 |                    0 |       0.0105922 |    0.0222686 |        0.9777314 |
| Ocean township         | Ocean    |                8838 |       0.0465866 |           418.8719 |                  282 |               263 |                  0.0070671 |               0.0742049 | 0.0045259 | 0.0049785 | 0.9763521 |      0.0000000 |           0.0055442 |                    0 |       0.0085992 |    0.0243268 |        0.9756732 |
| Point Pleasant borough | Ocean    |               18519 |       0.0320661 |          5304.7268 |                  283 |                79 |                  0.0035336 |               0.7243816 | 0.0016740 | 0.0038879 | 0.9838004 |      0.0043739 |           0.0004860 |                    0 |       0.0057778 |    0.0461148 |        0.9538852 |

The 10 densest
municipalities:

| Municipality           | County  | Population, 2013-17 | Diversity Index | Population density | Diversity Index rank | Pop. density rank | Diversity Index percentile | Pop. density percentile | pct Asian | pct Black | pct White | pct Other race | pct Native American | pct Pacific Islander | pct Two or more | pct Hispanic | pct Non-Hispanic |
| :--------------------- | :------ | ------------------: | --------------: | -----------------: | -------------------: | ----------------: | -------------------------: | ----------------------: | --------: | --------: | --------: | -------------: | ------------------: | -------------------: | --------------: | -----------: | ---------------: |
| Guttenberg town        | Hudson  |               11733 |       0.5815861 |           60788.43 |                   39 |                 1 |                  0.8657244 |               1.0000000 | 0.0744055 | 0.0334953 | 0.5837382 |      0.2635302 |           0.0057956 |            0.0000000 |       0.0390352 |    0.6584846 |        0.3415154 |
| Union City city        | Hudson  |               69815 |       0.4514594 |           54246.15 |                  100 |                 2 |                  0.6501767 |               0.9964664 | 0.0409081 | 0.0483420 | 0.7207477 |      0.1554967 |           0.0044833 |            0.0008164 |       0.0292058 |    0.7958748 |        0.2041252 |
| West New York town     | Hudson  |               53345 |       0.5670316 |           53652.70 |                   48 |                 3 |                  0.8339223 |               0.9929329 | 0.0620489 | 0.0338738 | 0.5953135 |      0.2688537 |           0.0021745 |            0.0019308 |       0.0358047 |    0.7694817 |        0.2305183 |
| Hoboken city           | Hudson  |               54117 |       0.3018175 |           43286.62 |                  174 |                 4 |                  0.3886926 |               0.9893993 | 0.0929283 | 0.0271818 | 0.8290740 |      0.0164089 |           0.0001109 |            0.0000185 |       0.0342776 |    0.1621856 |        0.8378144 |
| Cliffside Park borough | Bergen  |               24861 |       0.5122879 |           26011.57 |                   71 |                 5 |                  0.7526502 |               0.9858657 | 0.1673706 | 0.0325409 | 0.6689594 |      0.1016854 |           0.0007642 |            0.0005229 |       0.0281566 |    0.3005913 |        0.6994087 |
| Passaic city           | Passaic |               71057 |       0.6026179 |           22680.72 |                   31 |                 6 |                  0.8939929 |               0.9823322 | 0.0337616 | 0.0990754 | 0.5694724 |      0.2458027 |           0.0113852 |            0.0007740 |       0.0397287 |    0.7319335 |        0.2680665 |
| Irvington township     | Essex   |               54715 |       0.2395346 |           18775.34 |                  204 |                 7 |                  0.2826855 |               0.9787986 | 0.0149136 | 0.8684821 | 0.0641872 |      0.0420360 |           0.0003655 |            0.0002924 |       0.0097231 |    0.0961893 |        0.9038107 |
| Weehawken township     | Hudson  |               14268 |       0.4201864 |           18282.59 |                  116 |                 8 |                  0.5936396 |               0.9752650 | 0.0998738 | 0.0397393 | 0.7501402 |      0.0599944 |           0.0065882 |            0.0000000 |       0.0436641 |    0.3760163 |        0.6239837 |
| Jersey City city       | Hudson  |              265932 |       0.7382005 |           17974.86 |                    1 |                 9 |                  1.0000000 |               0.9717314 | 0.2539221 | 0.2398658 | 0.3540717 |      0.1156837 |           0.0039070 |            0.0005753 |       0.0319743 |    0.2881827 |        0.7118173 |
| Paterson city          | Passaic |              147890 |       0.7212596 |           17578.40 |                    3 |                10 |                  0.9929329 |               0.9681979 | 0.0392048 | 0.2776861 | 0.2997160 |      0.3275137 |           0.0011292 |            0.0000000 |       0.0547502 |    0.6073095 |        0.3926905 |

The 10
sparsest:

| Municipality         | County     | Population, 2013-17 | Diversity Index | Population density | Diversity Index rank | Pop. density rank | Diversity Index percentile | Pop. density percentile | pct Asian | pct Black | pct White | pct Other race | pct Native American | pct Pacific Islander | pct Two or more | pct Hispanic | pct Non-Hispanic |
| :------------------- | :--------- | ------------------: | --------------: | -----------------: | -------------------: | ----------------: | -------------------------: | ----------------------: | --------: | --------: | --------: | -------------: | ------------------: | -------------------: | --------------: | -----------: | ---------------: |
| Waterford township   | Camden     |               10749 |       0.2356335 |           298.5652 |                  210 |               274 |                  0.2614841 |               0.0353357 | 0.0034422 | 0.0403758 | 0.8712438 |      0.0373988 |           0.0000000 |            0.0000000 |       0.0475393 |    0.0589822 |        0.9410178 |
| Franklin township    | Gloucester |               16579 |       0.2892155 |           296.9550 |                  179 |               275 |                  0.3710247 |               0.0318021 | 0.0245491 | 0.0675553 | 0.8385307 |      0.0409554 |           0.0000000 |            0.0000000 |       0.0284094 |    0.0687617 |        0.9312383 |
| Millstone township   | Monmouth   |               10522 |       0.1956913 |           287.5632 |                  231 |               276 |                  0.1872792 |               0.0282686 | 0.0381106 | 0.0191028 | 0.8952671 |      0.0186276 |           0.0016157 |            0.0020909 |       0.0251853 |    0.0664322 |        0.9335678 |
| Middle township      | Cape May   |               18623 |       0.2933582 |           264.9062 |                  177 |               277 |                  0.3780919 |               0.0247350 | 0.0134243 | 0.1182946 | 0.8317135 |      0.0114375 |           0.0008592 |            0.0000000 |       0.0242711 |    0.0598722 |        0.9401278 |
| Hamilton township    | Atlantic   |               26663 |       0.5576664 |           240.3487 |                   53 |               278 |                  0.8162544 |               0.0212014 | 0.0680344 | 0.1945768 | 0.6284364 |      0.0548700 |           0.0111390 |            0.0007876 |       0.0421558 |    0.1545588 |        0.8454412 |
| Southampton township | Burlington |               10274 |       0.1261181 |           234.0944 |                  263 |               279 |                  0.0742049 |               0.0176678 | 0.0050613 | 0.0268639 | 0.9341055 |      0.0154760 |           0.0000000 |            0.0000000 |       0.0184933 |    0.0435079 |        0.9564921 |
| Plumsted township    | Ocean      |                8509 |       0.1065713 |           217.4172 |                  273 |               280 |                  0.0388693 |               0.0141343 | 0.0082266 | 0.0373722 | 0.9444118 |      0.0056411 |           0.0000000 |            0.0000000 |       0.0043483 |    0.0881420 |        0.9118580 |
| Pittsgrove township  | Salem      |                9009 |       0.1821425 |           200.6520 |                  235 |               281 |                  0.1731449 |               0.0106007 | 0.0084360 | 0.0599401 | 0.9020979 |      0.0133200 |           0.0008880 |            0.0000000 |       0.0153180 |    0.0428460 |        0.9571540 |
| Upper township       | Cape May   |               11990 |       0.0471160 |           193.3220 |                  281 |               282 |                  0.0106007 |               0.0070671 | 0.0027523 | 0.0073394 | 0.9760634 |      0.0032527 |           0.0000000 |            0.0000000 |       0.0105922 |    0.0222686 |        0.9777314 |
| Wantage township     | Sussex     |               11062 |       0.0987186 |           165.7101 |                  278 |               283 |                  0.0212014 |               0.0035336 | 0.0117519 | 0.0082264 | 0.9487434 |      0.0002712 |           0.0000000 |            0.0000000 |       0.0310071 |    0.0549629 |        0.9450371 |
