library(tidyverse)
library(lubridate)

sinclair_data <- tibble(filename = list.files(path = "data/sinclair_data", full.names = T, pattern = "*.csv")) %>%
  mutate(
    year = str_extract(filename, "[0-9]+") %>% as.double(),
    data = filename %>% map(~ read_csv(.x, locale = locale(encoding = "UTF-8"))),
    data = map(data, ~ rename_with(.x, ~ gsub("\n", "", .x))),
    data = map(data, ~ .x %>% rename_with(tolower)),
    data = map(data, ~ .x %>% select(market))
  ) %>%
  unnest(data) %>%
  mutate(
    sinclair_present = T,
    market = gsub("[\n]","",market)
  )

dma_names <- read_csv("data/dma_list.csv")
sinclair_codes <- read_csv("sinclair_names.csv")

sinclair_data <- full_join(sinclair_codes, sinclair_data) %>%
    select(-filename)

sinclair_data <- sinclair_data %>% complete(code = dma_names$code, year = 2005:2021) %>%
    replace_na(list(sinclair_present = F)) %>%
    select(-market)

sinclair_data <- sinclair_data %>% right_join(dma_names)

between_data <- read_csv("between.csv") %>%
    select(-code) %>%
    rename("code" = "geoCode")

search_data <- read_csv("searches.csv") %>%
    mutate(year = year(date)) %>%
      group_by(year, name) %>%
      nest() %>%
      mutate(
             score = data %>% map_dbl(~ mean(.x$score, na.rm = T)),
             code = str_extract(name,"[0-9]+") %>% as.numeric()
      )

search_data <- between_data %>% full_join(search_data) %>%
    mutate(score = score * economist / 100)



full_data <- search_data %>% right_join(sinclair_data)

full_data %>%
    ggplot(aes(x=year,y=score)) +
    facet_wrap(~name)

lm(score ~ as.factor(year) + sinclair_present + as.factor(name),data=full_data) %>%
    summary()

