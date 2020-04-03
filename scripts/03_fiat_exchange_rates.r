# Load requirements
source("01_my_fxns_this_project.r")

requirements_df <-
  data.frame(
    required_rda_files =
      c("../outputs/02_dates_of_interest.rda"),
    
    source_scripts = 
      c("02_dates_of_interest.r"),
    
    stringsAsFactors = F)

load_source_data()

#Load RSelenium driver
start_rD()

#Navigate to the page
rD$client$navigate(paste0(
  "https://www.riksbank.se/sv/statistik/sok-rantor--valutakurser/?g130-SEKEURPMI=on&g130-SEKUSDPMI=on&from=",
  start_date,
  "&to=",
  end_date,
  "&f=Day&c=cAverage&s=Dot")) #take rsd to webpage for fiat x rates for EUR and USD for my selected dates

#Scrape the data
riksbanken_exchange_rates <-
  rD$client$getPageSource()[[1]] %>% #converts full page to pure html now that all info is loaded 
  xml2::read_html(.) %>% #reads the html
  rvest::html_table(., fill = T) %>% #pulls tables
  .[[2]] %>% #the second table is the table I care to scrape
  .[2 : nrow(.) , 2:4] #keeps the columns I care about

# Remove the remote Driver, clean up the "garbage" to free memory, and kill any processes still keeping the port open.
stop_rD()

#Modify the df so it is in the format I need
names(riksbanken_exchange_rates) <- list("Date", "EUR_SEK_", "USD_SEK_")

riksbanken_exchange_rates[["Date"]] %<>% #format for later merging
  as.Date %>%
  lubridate::ymd(.)

riksbanken_exchange_rates[["EUR_SEK_"]] %<>%
  as.character %<>%
  as.numeric 

riksbanken_exchange_rates[["SEK_EUR_"]] <-
  1 / riksbanken_exchange_rates[["EUR_SEK_"]]

riksbanken_exchange_rates[["USD_SEK_"]] %<>%
  as.character %<>%
  as.numeric

riksbanken_exchange_rates[["SEK_USD_"]] <-
  1 / riksbanken_exchange_rates[["USD_SEK_"]]

riksbanken_exchange_rates[["EUR_USD_"]] <-
  riksbanken_exchange_rates[["SEK_USD_"]] / riksbanken_exchange_rates[["SEK_EUR_"]]

riksbanken_exchange_rates[["USD_EUR_"]] <-
  1 / riksbanken_exchange_rates[["EUR_USD_"]]

riksbanken_exchange_rates %<>%
  merge(dates_of_interest,
        all = T)

# Pull in the irs exchange rates
irs_exchange_rates <-
  openxlsx::read.xlsx("../inputs/03_irs_exchange_rates.xlsx")

#save the data
save(riksbanken_exchange_rates, irs_exchange_rates, file = "../outputs/03_fiat_exchange_rates.rda")