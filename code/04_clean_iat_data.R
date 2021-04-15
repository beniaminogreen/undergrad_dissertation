#!/usr/bin/Rscript
library(tidyverse)

#Load in all years of IAT data, consolidate race into a single column
full_iat_data <- list.files(path = "data", pattern = "race.*.csv", full.names = T) %>%
  map_dfr(read.csv) %>%
  tibble() %>%
  unite("race", raceomb:raceomb_002, sep = "", na.rm = T, remove = T) %>%
  rename_with(tolower) %>%
  group_by(state)

#Get estimates of bias by state
full_iat_data %>%
    filter(race == 6, ethnicityomb == 2) %>%
  summarize(iat = mean(d_biep.white_good_all, na.rm = T), sbp5 = mean(sbp5, na.rm = T)) %>%
  select(state, iat, sbp5) %>%
  write_csv("../data/iat_state_data.csv")

#Read in mapping of DMA codes to state codes
dma_to_zip <- read_csv("data/DMA-zip.csv") %>%
  select(-ZIPCODE) %>%
  distinct()

#Read in mapping of DMA codes to state codes
state_to_no <- read_csv("data/state_info.csv")

#Create FIPS county code column
iat_by_county <- full_join(state_to_no, full_iat_data) %>%
  mutate(
    countyno = countyno %>% str_pad(3, pad = "0"),
    FIPS = str_pad(paste0(state.no, countyno), 5, pad = "0")
  )

#Test column / join was created correctly without dropping any observations
stopifnot(nrow(iat_by_county) == nrow(full_iat_data))
rm(state_to_no, full_iat_data)

# Add DMA column to IAT data
iat_by_dma <- iat_by_county %>% right_join(dma_to_zip)
rm(iat_by_county, dma_to_zip)

# make dolumn names pretty and conforming with other datasets
iat_by_dma <- rename_with(iat_by_dma, ~ tolower(gsub(" ", "_", .x, fixed = TRUE))) %>%
  rename(code = dma_code) %>%
  mutate(code = as.numeric(code))

sinclair_data <- read_csv("../data/clean_sinclair_data.csv")

clean_iat_data <- right_join(sinclair_data, iat_by_dma)
stopifnot(nrow(iat_by_dma) == nrow(clean_iat_data))

save(clean_iat_data, file = "../data/clean_iat_data.Rdata")
