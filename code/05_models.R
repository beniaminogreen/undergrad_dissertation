#!/usr/bin/Rscript
library(tidyverse)
library(biglm)

search_data <- read_csv("../data/clean_search_data.csv")
stopifnot(nrow(search_data) == 3570)

print("Estimating Model 1 / 12")
model_1 <- lm(word_1 ~ as.factor(year) + as.factor(code) + sinclair_present, data = search_data)

print("Estimating Model 2 / 12")
model_2 <- lm(word_1 ~ as.factor(year) + as.factor(code) + as.factor(code):year + sinclair_present, data = search_data)

print("Estimating Model 3 / 12")
model_3 <- lm(word_1 ~ as.factor(year) + as.factor(code) + as.factor(years_before), data = search_data)

print("Estimating Model 4 / 12")
model_4 <- lm(score ~ as.factor(year) + as.factor(code) + sinclair_present, data = search_data)

print("Estimating Model 5 / 12")
model_5 <- lm(score ~ as.factor(year) + as.factor(code) + as.factor(code):year + sinclair_present, data = search_data)

print("Estimating Model 6 / 12")
model_6 <- lm(score ~ as.factor(year) + as.factor(code) + as.factor(years_before), data = search_data)

# loads clean_iat_data
load("../data/clean_iat_data.Rdata")

clean_iat_data <- clean_iat_data %>%
  mutate(
    code = as.factor(code),
    factor_year = as.factor(year),
    years_before = as.factor(years_before)
  ) %>%
  as.data.frame()

print("Estimating Model 7 / 12")
chunks_7 <- split(clean_iat_data, (as.numeric(rownames(clean_iat_data)) - 1) %/% 500000)
chunks_7[[1]] <- biglm(d_biep.white_good_all ~ factor_year + code + sinclair_present, data = chunks_7[[1]])
model_7 <- reduce(chunks_7, update)
rm(chunks_7)

print("Estimating Model 8 / 12")
chunks_8 <- split(clean_iat_data, (as.numeric(rownames(clean_iat_data)) - 1) %/% 500000)
chunks_8[[1]] <- biglm(d_biep.white_good_all ~ factor_year + code + code:year + sinclair_present, data = chunks_8[[1]])
model_8 <- reduce(chunks_8, update)
rm(chunks_8)

print("Estimating Model 9 / 12")
chunks_9 <- split(clean_iat_data, (as.numeric(rownames(clean_iat_data)) - 1) %/% 500000)
chunks_9[[1]] <- biglm(d_biep.white_good_all ~ factor_year + code + years_before , data = chunks_9[[1]])
model_9 <- reduce(chunks_9, update)
rm(chunks_9)

iat_white_nonhisp <- clean_iat_data %>%
    filter(race == 6, ethnicityomb == 2) %>%
      as.data.frame()


print("Estimating Model 10 / 12")
chunks_10 <- split(iat_white_nonhisp, (as.numeric(rownames(iat_white_nonhisp)) - 1) %/% 500000)
chunks_10[[1]] <- biglm(d_biep.white_good_all ~ factor_year + code + sinclair_present, data = chunks_10[[1]])
model_10 <- reduce(chunks_10, update)
rm(chunks_10)

print("Estimating Model 11 / 12")
chunks_11 <- split(iat_white_nonhisp, (as.numeric(rownames(iat_white_nonhisp)) - 1) %/% 500000)
chunks_11[[1]] <- biglm(d_biep.white_good_all ~ factor_year + code + code:year + sinclair_present, data = chunks_11[[1]])
model_11 <- reduce(chunks_11, update)
rm(chunks_11)

print("Estimating Model 12 / 12")
chunks_12 <- split(iat_white_nonhisp, (as.numeric(rownames(iat_white_nonhisp)) - 1) %/% 500000)
chunks_12[[1]] <- biglm(d_biep.white_good_all ~ factor_year + code + years_before , data = chunks_12[[1]])
model_12 <- reduce(chunks_12, update)
rm(chunks_12)

save(model_1, model_2, model_3, model_4, model_5, model_6, model_7, model_8, model_9, model_10, model_11, model_12, file = "../data/models.Rdata")

