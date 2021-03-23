library(tidyverse)
library(lubridate)

source("utils.R")

sinclair_data <- tibble(filename = list.files(path = "data/sinclair_data", full.names = T, pattern = "*.csv")) %>%
  mutate(
    year = str_extract(filename, "[0-9]+") %>% as.double(),
    data = filename %>% map(~ read_csv(.x, locale = locale(encoding = "UTF-8"))),
    data = map(data, ~ rename_with(.x, ~ gsub("\n", "", .x))),
    data = map(data, ~ .x %>% rename_with(tolower)),
    data = map(data, ~ .x %>% dplyr::select(market))
  ) %>%
  unnest(data) %>%
  mutate(
    sinclair_present = T,
    market = gsub("\n","",market)
  )

dma_names <- read_csv("data/dma_list.csv")
sinclair_codes <- read_csv("sinclair_names.csv")

sinclair_data <- sinclair_data %>% full_join(sinclair_codes) %>%
    dplyr::select(-filename, -market)

sinclair_data <- sinclair_data %>%
    complete(code = dma_names$code, year = 2005:2020) %>%
    arrange(code) %>%
    replace_na(list(sinclair_present = F)) %>%
    left_join(dma_names)

between_data <- read_csv("between.csv") %>%
    pivot_longer(-code, names_to="term", values_to="overall") %>%
    mutate(term = censor_string(term))

search_data <- read_csv("searches.csv") %>%
    mutate(year = year(date)) %>%
    mutate(term = censor_string(term)) %>%
    group_by(year, code, term) %>%
    nest() %>%
    mutate(
         score = data %>% map_dbl(~ mean(.x$score, na.rm = T)),
         code = str_extract(code,"[0-9]+") %>% as.numeric()
    )

search_data <- search_data %>% dplyr::select(-data) %>%
    distinct(term, code, year, .keep_all = TRUE) %>%
    pivot_wider(names_from = term, values_from=score) %>%
    mutate(overall_score = rowSums(across(everything()), na.rm=T))


full_data <- search_data %>% right_join(sinclair_data) %>%
    filter(year != 2021)

lm(overall_score ~ as.factor(year) + as.factor(code) + sinclair_present + year:as.factor(code), data = full_data) %>%
    summary()
