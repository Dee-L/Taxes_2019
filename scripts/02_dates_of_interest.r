# Load requirements
source("01_my_fxns_this_project.r")

earliest_year <-
  openxlsx::read.xlsx("../inputs/02_years_of_interest.xlsx")[["earliest.year"]]

filing_year <-
  openxlsx::read.xlsx("../inputs/02_years_of_interest.xlsx")[["filing_year"]]

start_date <- as.Date(paste0(earliest_year, '-01-01'))

end_date <- as.Date(paste0(filing_year, '-12-31'))

dates_of_interest <- #df of dates
  data.frame("Date" = seq(from = start_date,
                          to = end_date,
                          by = "day"))

dates_of_interest$Date %<>% #format for later merging
  as.Date %>%
  lubridate::ymd(.)


save(earliest_year, filing_year, start_date, end_date, dates_of_interest,
     file = "../outputs/02_dates_of_interest.rda")