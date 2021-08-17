Methodology
================
Everet Rummel
2019-11-12

## Source data notes

The ACS 2013-17 sample covers years *2012* to 2017.

## Universe

The ACS has county subdivisions, which I usually call “municipalities”
here. I exclude “County subdivisions not defined” records.

In all datasets with rankings, I exclude municipalities with populations
lower than 1,000. In the past, I used the median town population as the
cutoff, but that seemed a bit high, and doing so excluded some
interesting findings from the results.

## Calculations

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

The Diversity Index is calculated as follows:

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

## Validation

My racial diversity results can be compared to those calculated by
NJ.com’s [Disha Raychaudhuri](https://twitter.com/Disha_RC) in [this
article](https://www.nj.com/data/2019/02/the-25-most-racially-diverse-towns-in-nj-ranked.html).
My rankings match theirs almost exactly. My calculations are off by
about a hundredth of a percentage point for each municipality. They
claim to have followed [this
methodology](https://www.usatoday.com/story/news/nation/2014/10/21/diversity-index-data-how-we-did-report/17432103/)
for calculating the Diversity Index from ACS data, but I matched their
results by *not* following that methodology. See [my
code](code/diversity_race.R) for details.

My economic diversity results can be compared to those calculated by
NJ.com’s [Disha Raychaudhuri](https://twitter.com/Disha_RC) in [this
article](https://www.nj.com/data/2019/04/nj-towns-are-increasingly-becoming-rich-or-poor-is-the-middle-class-disappearing.html).
Once again, I’m able to almost exactly match their results.

Note: While Raychaudhuri excludes municipalities with populations lower
than 10,000, I exclude those with populations lower than 1,000.

## My environment

Here is my session info after running all lines of `__plan__.R`:

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
    ##  [1] rmarkdown_1.16   here_0.1         tibble_2.1.3     readxl_1.3.1    
    ##  [5] purrr_0.3.3      httr_1.4.1       stringr_1.4.0    rvest_0.3.5     
    ##  [9] xml2_1.2.2       units_0.6-5      tigris_0.8.2     tidyr_1.0.0     
    ## [13] tidycensus_0.9.2 readr_1.3.1      dplyr_0.8.3     
    ## 
    ## loaded via a namespace (and not attached):
    ##  [1] Rcpp_1.0.3         cellranger_1.1.0   pillar_1.4.2      
    ##  [4] compiler_3.6.1     class_7.3-15       tools_3.6.1       
    ##  [7] digest_0.6.22      uuid_0.1-2         zeallot_0.1.0     
    ## [10] packrat_0.5.0      evaluate_0.14      jsonlite_1.6      
    ## [13] lattice_0.20-38    lifecycle_0.1.0    pkgconfig_2.0.3   
    ## [16] rlang_0.4.1        cli_1.1.0          DBI_1.0.0         
    ## [19] rstudioapi_0.10    yaml_2.2.0         curl_4.2          
    ## [22] rgdal_1.4-7        xfun_0.10          e1071_1.7-2       
    ## [25] knitr_1.25         vctrs_0.2.0        rappdirs_0.3.1    
    ## [28] hms_0.5.2          rprojroot_1.3-2    classInt_0.4-2    
    ## [31] grid_3.6.1         tidyselect_0.2.5   glue_1.3.1        
    ## [34] sf_0.8-0           R6_2.4.0           foreign_0.8-72    
    ## [37] sp_1.3-2           selectr_0.4-1      magrittr_1.5      
    ## [40] htmltools_0.4.0    ellipsis_0.3.0     backports_1.1.5   
    ## [43] maptools_0.9-8     assertthat_0.2.1   KernSmooth_2.23-16
    ## [46] stringi_1.4.3      crayon_1.3.4
