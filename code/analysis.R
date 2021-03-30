#!/usr/bin/Rscript
# Load Libraries for Analysis
library(tidyverse)
library(lubridate)
# Load utility functions
source("utils.R")

between_data <- read_csv("data/google_trends_data/set_1_between_regions.csv") %>%
  pivot_longer(-code, names_to = "term", values_to = "overall") %>%
  mutate(term = censor_string(term))

#Checks there is data for comparing each region
stopifnot(length(unique(between_data$code)) == 210)


search_data <- read_csv("data/google_trends_data/set_1_time_serires.csv") %>%
  mutate(year = year(date)) %>%
  mutate(term = censor_string(term)) %>%
  group_by(year, code, term) %>%
  nest() %>%
  mutate(
    score = data %>% map_dbl(~ mean(.x$score, na.rm = T)),
    code = str_extract(code, "[0-9]+") %>% as.numeric()
  )

#Checks there is trend data for each region
#stopifnot(length(unique(search_data$code)) == 210)

search_data <- search_data %>%
  dplyr::select(-data) %>%
  distinct(term, code, year, .keep_all = TRUE) %>%
  pivot_wider(names_from = term, values_from = score) %>%
  mutate(overall_score = rowSums(across(everything()), na.rm = T))


full_data <- search_data %>%
  right_join(sinclair_data) %>%
  filter(year != 2021)

lm(overall_score ~ as.factor(year) + as.factor(code) + sinclair_present, data = full_data) %>%
  summary()

lm(overall_score ~ as.factor(year) + as.factor(code) + sinclair_present + year:as.factor(code), data = full_data) %>%
  summary()
