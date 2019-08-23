Methodology
================
Everet Rummel
2019-08-22

# Source Data

See *[Data Sources](reports/data_sources.md)* for details.

Data on race, income, and population comes from the American Community
Survey (ACS) 5-year Public Use Micro Sample (PUMS), 2013-2017. This data
source covers years *2012* to 2017. I accessed this data via the Census
Bureau API via the
[`tidycensus`](https://github.com/walkerke/tidycensus) R package.

Land area for every town was obtained from
[TIGER](https://www.census.gov/programs-surveys/geography.html) via the
[`tigris`](https://github.com/walkerke/tigris) R package. The most
recent year for the county subdivisions shapefile was 2015 at the time
of this analysis.

# Source Code

See the `[code](code)` folder. `[00_plan.R](code/00_plan.R)` runs all
code, reproduces all results, renders all reports, and details the steps
of the analysis. Run this file *only* if you want to reproduce what I
did.

Source code for all reports (`data_sources.md`, `methodology.md`, etc)
lives in `[code/markdown](code/markdown)`.

# Universe

Each record is a county subdivision, which I’m calling a “municipality”
here.

In all datasets, I exclude municipalities with populations lower than
1,000. In the past, I used the median town population as the cutoff, but
that seemed a bit high, and doing so excluded some interesting findings
from the results.

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
count of the race with which they identify.

# Validation

My racial diversity results can be compared to those calculated by
NJ.com’s [Disha Raychaudhuri](https://twitter.com/Disha_RC) in [this
article](https://www.nj.com/data/2019/02/the-25-most-racially-diverse-towns-in-nj-ranked.html).
My rankings match theirs almost exactly. My calculations are off by
about a hundredth of a percentage point for each municipality. They
claim to have followed [this
methodology](https://www.usatoday.com/story/news/nation/2014/10/21/diversity-index-data-how-we-did-report/17432103/)
for calculating the Diversity Index from ACS data, but I matched their
results by *not* following that methodology. See my code for details.

Note: While Raychaudhuri excludes municipalities with populations lower
than 10,000, I exclude those with populations lower than 1,000.

My economic diversity results can be compared to those calculated by
NJ.com’s [Disha Raychaudhuri](https://twitter.com/Disha_RC) in [this
article](https://www.nj.com/data/2019/04/nj-towns-are-increasingly-becoming-rich-or-poor-is-the-middle-class-disappearing.html).
Once again, I’m able to almost exactly match their results.

# My Environment

Below are the R packages directly loaded in this analysis. See
`code/01_packages.R` for the most up-to-date list, just in case.

``` r
library(dplyr)
library(here)
library(magrittr)
library(readr)
library(rvest)
library(tidycensus)
library(tidyr)
library(tigris)
library(units)
```

Here is my session info after running all lines of `00_plan.R`:

``` r
sessionInfo()
```

    ## R version 3.6.1 (2019-07-05)
    ## Platform: x86_64-pc-linux-gnu (64-bit)
    ## Running under: Ubuntu 18.04.3 LTS
    ## 
    ## Matrix products: default
    ## BLAS:   /usr/lib/x86_64-linux-gnu/blas/libblas.so.3.7.1
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
    ##  [1] units_0.6-4      tigris_0.8.2     tidyr_0.8.3      tidycensus_0.9.2
    ##  [5] rvest_0.3.4      xml2_1.2.2       rmarkdown_1.15   readr_1.3.1     
    ##  [9] magrittr_1.5     dplyr_0.8.3      here_0.1        
    ## 
    ## loaded via a namespace (and not attached):
    ##  [1] Rcpp_1.0.2         pillar_1.4.2       compiler_3.6.1    
    ##  [4] class_7.3-15       tools_3.6.1        uuid_0.1-2        
    ##  [7] zeallot_0.1.0      digest_0.6.20      packrat_0.5.0     
    ## [10] jsonlite_1.6       lattice_0.20-38    evaluate_0.14     
    ## [13] tibble_2.1.3       pkgconfig_2.0.2    rlang_0.4.0       
    ## [16] DBI_1.0.0          rstudioapi_0.10    yaml_2.2.0        
    ## [19] curl_4.0           rgdal_1.4-4        xfun_0.9          
    ## [22] e1071_1.7-2        stringr_1.4.0      httr_1.4.1        
    ## [25] knitr_1.24         vctrs_0.2.0        hms_0.5.0         
    ## [28] rappdirs_0.3.1     grid_3.6.1         classInt_0.4-1    
    ## [31] rprojroot_1.3-2    tidyselect_0.2.5   glue_1.3.1        
    ## [34] sf_0.7-7           R6_2.4.0           foreign_0.8-72    
    ## [37] sp_1.3-1           selectr_0.4-1      purrr_0.3.2       
    ## [40] maptools_0.9-5     backports_1.1.4    htmltools_0.3.6   
    ## [43] assertthat_0.2.1   KernSmooth_2.23-15 stringi_1.4.3     
    ## [46] crayon_1.3.4
