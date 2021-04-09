#!/usr/bin/Rscript
library(tidyverse)

full_iat_data <- list.files(path="data", pattern = "race.*.csv", full.names=T) %>%
    map_dfr(read.csv) %>%
    tibble() %>%
    unite("race", raceomb:raceomb_002, sep = "", na.rm = T, remove = T) %>%
    rename_with(tolower) %>%
    filter(race == "6", ethnicityomb == 2) %>%
    group_by(state)

dma_to_zip <- read_csv("data/DMA-zip.csv") %>%
    select(-ZIPCODE) %>%
    distinct()

state_to_no <- read_csv("data/state_info.csv")

iat_by_county <- full_join(state_to_no, full_iat_data) %>%
    mutate(countyno = countyno %>% str_pad(3, pad="0"),
    FIPS = str_pad(paste0(state.no, countyno), 5, pad = "0"))
stopifnot(nrow(iat_by_county) == nrow(full_iat_data))
rm(state_to_no, full_iat_data)

iat_by_dma <- iat_by_county %>% right_join(dma_to_zip)
rm(iat_by_county, dma_to_zip)

# iat_state_data <- full_iat_data %>%
#   summarize(iat = mean(d_biep.white_good_all, na.rm = T), sbp5 = mean(sbp5, na.rm = T)) %>%
#   select(state, iat, sbp5)


# write_csv(iat_state_data, "../data/iat_state_data.csv")

iat_by_dma <- rename_with(iat_by_dma, ~ tolower(gsub(" ", "_", .x, fixed = TRUE))) %>%
    rename(code = dma_code)

sinclair_data <- read_csv("../data/clean_sinclair_data.csv") %>%
    mutate(code = as.character(code))

fully <- full_join(sinclair_data, iat_by_dma)
rm(iat_by_dma)

model_2 <- lm(d_biep.white_good_all ~ years_before + as.factor(year) + as.factor(code), data=fully)

print(summary(model_2))

