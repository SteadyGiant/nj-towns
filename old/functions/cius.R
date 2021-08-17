#!/usr/bin/env Rscript

library(httr)
library(purrr)
library(readxl)
library(tibble)


get_agencies = function(years = 2006:2018) {

  # Available years: https://www.fbi.gov/services/cjis/ucr/publications
  # Data for years 2005 & prior will require more extensive cleaning.
  tables = tibble(year = 2006:2018,
                  url = c('https://www2.fbi.gov/ucr/cius2006/data/documents/06tbl08nj.xls',
                          'https://www2.fbi.gov/ucr/cius2007/data/documents/07tbl08nj.xls',
                          'https://www2.fbi.gov/ucr/cius2008/data/documents/08tbl08nj.xls',
                          'https://www2.fbi.gov/ucr/cius2009/data/documents/09tbl08nj.xls',
                          'https://ucr.fbi.gov/crime-in-the-u.s/2010/crime-in-the-u.s.-2010/tables/table-8/10tbl08nj.xls/output.xls',
                          'https://ucr.fbi.gov/crime-in-the-u.s/2011/crime-in-the-u.s.-2011/tables/table8statecuts/table_8_offenses_known_to_law_enforcement_new_jersey_by_city_2011.xls/output.xls',
                          'https://ucr.fbi.gov/crime-in-the-u.s/2012/crime-in-the-u.s.-2012/tables/8tabledatadecpdf/table-8-state-cuts/table_8_offenses_known_to_law_enforcement_by_new_jersey_by_city_2012.xls/output.xls',
                          'https://ucr.fbi.gov/crime-in-the-u.s/2013/crime-in-the-u.s.-2013/tables/table-8/table-8-state-cuts/table_8_offenses_known_to_law_enforcement_new_jersey_by_city_2013.xls/output.xls',
                          'https://ucr.fbi.gov/crime-in-the-u.s/2014/crime-in-the-u.s.-2014/tables/table-8/table-8-by-state/Table_8_Offenses_Known_to_Law_Enforcement_by_New_Jersey_by_City_2014.xls/output.xls',
                          'https://ucr.fbi.gov/crime-in-the-u.s/2015/crime-in-the-u.s.-2015/tables/table-8/table-8-state-pieces/table_8_offenses_known_to_law_enforcement_new_jersey_by_city_2015.xls/output.xls',
                          # For 2016 only, Table 6 contains city-level data, not Table 8.
                          'https://ucr.fbi.gov/crime-in-the-u.s/2016/crime-in-the-u.s.-2016/tables/table-6/table-6-state-cuts/new-jersey.xls/output.xls',
                          'https://ucr.fbi.gov/crime-in-the-u.s/2017/crime-in-the-u.s.-2017/tables/table-8/table-8-state-cuts/new-jersey.xls/output.xls',
                          'https://ucr.fbi.gov/crime-in-the-u.s/2018/crime-in-the-u.s.-2018/tables/table-8/table-8-state-cuts/new-jersey.xls/output.xls'))

  to_download = subset(tables,
                       year %in% years)

  map2_df(.x = to_download$url,
          .y = to_download$year,
          ~{
            Sys.sleep(1) # be nice
            path = tempfile(fileext = '.xls')
            GET(.x[1], write_disk(path))
            xl = path %>%
              read_excel(skip = 5, col_names = FALSE) %>%
              subset(select = c(1:12))
            xl$year = .y
            unlink(path) # delete temp file

            xl
          }) %>%
    `names<-`(c('city',
                'population',
                'violent_crime',
                'murder_manslaughter',
                'rape',
                'robbery',
                'assault',
                'property_crime',
                'burglary',
                'theft',
                'vehicle_theft',
                'arson',
                'year'))

}
