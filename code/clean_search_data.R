#!/usr/bin/Rscript
# Load Libraries for Analysis
library(tidyverse)
library(lubridate)
library(broom)
# Load utility functions
source("utils.R")

search_data <- read_csv("data/google_trends_data/word_1.csv") %>%
  pivot_longer(-code, names_to = "year", values_to = "word1") %>%
  mutate_all(as.numeric)

stopifnot(nrow(search_data) == 3570)
stopifnot(all(!is.na(search_data)))

write_csv(search_data, "../data/google_trends/word1.csv")

sinclair_data <- read_csv("../data/clean_sinclair_data.csv")
stopifnot(nrow(sinclair_data) == 3570)
stopifnot(all(!is.na(sinclair_data)))

# search_data <- search_data %>%
#   dplyr::select(-data) %>%
#   distinct(term, code, year, .keep_all = TRUE) %>%
#   pivot_wider(names_from = term, values_from = score) %>%
#   mutate(overall_score = rowSums(across(everything()), na.rm = T))
dma_names <- read_csv("data/dma_list.csv")
stopifnot(nrow(dma_names) == 210)

full_data <- search_data %>%
  right_join(sinclair_data) %>%
  full_join(dma_names) %>%
  filter(year != 2021) %>%
  group_by(code) %>%
  mutate(years_before = years_before(sinclair_present)) %>%
  ungroup() %>%
  mutate(sword1 = (word1-mean(word1))/sd(word1)) %>%
  mutate(years_before = relevel(as.factor(years_before),"-99"))

stopifnot(nrow(full_data) == 3570)
stopifnot(all(!is.na(full_data)))

write_csv(full_data, "../data/full_data.csv")
