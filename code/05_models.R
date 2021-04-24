#!/usr/bin/Rscript
library(tidyverse)
library(biglm)

search_data <- read_csv("../data/clean_search_data.csv")
stopifnot(nrow(search_data) == 3570)

print("Estimating Model 1 / 15")
model_1 <- lm(sword_1 ~ as.factor(year) + as.factor(code) + sinclair_present, data = search_data)

print("Estimating Model 2 / 15")
model_2 <- lm(sword_1 ~ as.factor(year) + as.factor(code) + as.factor(code):year + sinclair_present, data = search_data)

print("Estimating Model 3 / 15")
model_3 <- lm(sword_1 ~ as.factor(year) + as.factor(code) + as.factor(years_before), data = search_data)

# loads clean_iat_data
load("../data/clean_iat_data.Rdata")

clean_iat_data <- clean_iat_data %>%
  mutate(
    code = as.factor(code),
    factor_year = as.factor(year),
    years_before = as.factor(years_before)
  ) %>%
  as.data.frame()

big_model <- function (form, dfr) {
    chunks <- split(dfr, (as.numeric(rownames(dfr)) - 1) %/% 500000)
    chunks[[1]] <- biglm(form, data = chunks[[1]])
    model <- reduce(chunks, update)
    return(model)
}

print("Estimating Model 7 / 15")
model_7 <- big_model(d_biep.white_good_all ~ factor_year + code + sinclair_present, clean_iat_data)

print("Estimating Model 8 / 15")
model_8 <- big_model(d_biep.white_good_all ~ factor_year + code + code:year + sinclair_present, clean_iat_data)

print("Estimating Model 9 / 15")
model_9 <- big_model(d_biep.white_good_all ~ factor_year + code + years_before , clean_iat_data)

iat_white_nonhisp <- clean_iat_data %>%
    filter(race == 6, ethnicityomb == 2) %>%
      as.data.frame()

print("Estimating Model 10 / 15")
model_10 <- big_model(d_biep.white_good_all ~ factor_year + code + sinclair_present, iat_white_nonhisp)

print("Estimating Model 11 / 15")
model_11 <- big_model(d_biep.white_good_all ~ factor_year + code + code:year + sinclair_present, iat_white_nonhisp)

print("Estimating Model 12 / 15")
model_12 <- big_model(d_biep.white_good_all ~ factor_year + code + years_before , iat_white_nonhisp)


model_13 <- big_model(tblack_0to10 ~ factor_year + code + sinclair_present, clean_iat_data)

print("Estimating Model 14 / 15")
model_14 <- big_model(tblack_0to10 ~ factor_year + code + code:year + sinclair_present, clean_iat_data)

print("Estimating Model 16 / 15")
model_15 <- big_model(tblack_0to10 ~ factor_year + code + years_before , clean_iat_data)

print("Estimating Model 16 / 15")
model_16 <- big_model(tblack_0to10 ~ factor_year + code + sinclair_present, iat_white_nonhisp)

print("Estimating Model 17 / 15")
model_17 <- big_model(tblack_0to10 ~ factor_year + code + code:year + sinclair_present, iat_white_nonhisp)

print("Estimating Model 18 / 15")
model_18 <- big_model(tblack_0to10 ~ factor_year + code + years_before , iat_white_nonhisp)

save(
     model_1,
     model_2,
     model_3,
     model_7,
     model_8,
     model_9,
     model_10,
     model_11,
     model_12,
     model_12,
     model_13,
     model_14,
     model_15,
     model_16,
     model_17,
     model_18,
     file = "../data/models.Rdata")

