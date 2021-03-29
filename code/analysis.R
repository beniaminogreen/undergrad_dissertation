# Load Libraries for Analysis
library(tidyverse)
library(lubridate)
# Load utility functions
source("utils.R")

# Creat tidy dataframe of years / markets in which sinclair was present
sinclair_raw <- tibble(filename = list.files(path = "../data/sinclair_data/", full.names = T, pattern = "*.csv")) %>%
  mutate(
    year = str_extract(filename, "[0-9]+") %>% as.double(),
    data = filename %>% map(~ read_csv(.x, locale = locale(encoding = "UTF-8"))),
    data = map(data, ~ rename_with(.x, ~ gsub("\n", "", .x))),
    data = map(data, ~ .x %>% rename_with(tolower)),
    data = map(data, ~ .x %>% dplyr::select(market))
  ) %>%
  unnest(data) %>%
  select(-filename) %>%
  mutate(
    sinclair_present = T,
    market = tolower(gsub("[^A-z]", "", market))
  ) %>%
  filter(market != "")

# Loads in Traslation dictionary of market names in the Sinclair
# dataset to DMA codes
sinclair_codes <- read_csv("sinclair_names.csv")

# checks that the sinclair codes table has all markets from the sinclair present dataset
stopifnot(
  all(sinclair_raw$market %in% sinclair_codes$market),
  all(sinclair_codes$market %in% sinclair_raw$market)
)

# Adds codes to sinclair present datset
sinclair_present <- sinclair_raw %>%
  inner_join(sinclair_codes) %>%
  select(-market)

# checks no observtations were lost in merge
stopifnot(nrow(sinclair_raw) == nrow(sinclair_present))
# checks there are no duplicate rows
stopifnot(!any(duplicated(sinclair_present)))

# Loads in Traslation dictionary of DMA codes to Standardized names
dma_names <- read_csv("../data/dma_list.csv")

# Fills in data to include stations where sinclair was not present
sinclair_data <- sinclair_present %>%
  complete(code = dma_names$code, year = 2004:2020) %>%
  arrange(code) %>%
  replace_na(list(sinclair_present = F))


# checks there is an observation for every year and  in the datset
stopifnot({
    sinclair_data %>% anti_join(expand.grid(code = dma_names$code, year = 2004:2020)) %>%
        nrow() == 0
})
# checks there are no duplicate rows
stopifnot(!any(duplicated(sinclair_data)))

# write out to csv file
write_csv(sinclair_data, "../data/clean_sinclair_data")

# Not done annotating / updating after here
################################################################################
between_data <- read_csv("../data/between.csv") %>%
  pivot_longer(-code, names_to = "term", values_to = "overall") %>%
  mutate(term = censor_string(term))

search_data <- read_csv("searches.csv") %>%
  mutate(year = year(date)) %>%
  mutate(term = censor_string(term)) %>%
  group_by(year, code, term) %>%
  nest() %>%
  mutate(
    score = data %>% map_dbl(~ mean(.x$score, na.rm = T)),
    code = str_extract(code, "[0-9]+") %>% as.numeric()
  )

search_data <- search_data %>%
  dplyr::select(-data) %>%
  distinct(term, code, year, .keep_all = TRUE) %>%
  pivot_wider(names_from = term, values_from = score) %>%
  mutate(overall_score = rowSums(across(everything()), na.rm = T))


full_data <- search_data %>%
  right_join(sinclair_data) %>%
  filter(year != 2021)

lm(overall_score ~ as.factor(year) + as.factor(code) + sinclair_present + year:as.factor(code), data = full_data) %>%
  summary()
