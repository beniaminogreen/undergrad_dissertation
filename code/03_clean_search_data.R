library(tidyverse)

# Get datframe of searches by DMA
scores <- tibble(file = list.files(path = "data", pattern = "scaled_word.*", full.names = T)) %>%
  mutate(data = map(file, read_csv)) %>%
  mutate(data = map2(data, file, ~ .x %>% mutate(term = str_extract(.y, "word_[0-9]")))) %>%
  unnest(data) %>%
  pivot_longer(as.character(2004:2020), names_to = "year", values_to = "score") %>%
  select(-file) %>%
  pivot_wider(names_from = term, values_from = score) %>%
  mutate(year = as.numeric(year))
stopifnot(nrow(scores) == 3570)

# Put different search terms on the same scale
scales <- read_csv("data/between_region_comparisons.csv")

scaled_data <- full_join(scores, scales) %>%
  mutate(
         sword_1 = word_1/mean(word_1)
  )

stopifnot(nrow(scaled_data) == 3570)

sinclair_data <- read_csv("../data/clean_sinclair_data.csv")

# Join sinclair to google trends data
full_data <- full_join(sinclair_data, scaled_data)

stopifnot(nrow(full_data) == 3570)

#Save dataset to be used in paper
full_data %>% write_csv("../data/clean_search_data.csv")
