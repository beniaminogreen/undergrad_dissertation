#!/usr/bin/Rscript
library(tidyverse)
library(biglm)

search_data <- read_csv("../data/clean_search_data.csv")
stopifnot(nrow(search_data) == 3570)

print("Estimating Model 1 / 18")
google_plain <- lm(sword_1 ~ as.factor(year) + as.factor(code) + sinclair_present, data = search_data)

print("Estimating Model 2 / 18")
google_linear <- lm(sword_1 ~ as.factor(year) + as.factor(code) + as.factor(code):year + sinclair_present, data = search_data)

print("Estimating Model 3 / 18")
google_lead <- lm(sword_1 ~ as.factor(year) + as.factor(code) + as.factor(years_before), data = search_data)

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

print("Estimating Model 5 / 18")
iat_all_plain <- big_model(d_biep.white_good_all ~ factor_year + code + sinclair_present, clean_iat_data)

print("Estimating Model 6 / 18")
iat_all_linear <- big_model(d_biep.white_good_all ~ factor_year + code + code:year + sinclair_present, clean_iat_data)

print("Estimating Model 8 / 18")
iat_all_lead <- big_model(d_biep.white_good_all ~ factor_year + code + years_before, clean_iat_data)

print("Estimating Model 9 / 18")
therm_all_plain <- big_model(tblack_0to10 ~ factor_year + code + sinclair_present, clean_iat_data)

print("Estimating Model 10 / 18")
therm_all_linear <- big_model(tblack_0to10 ~ factor_year + code + code:year + sinclair_present, clean_iat_data)

print("Estimating Model 12 / 18")
therm_all_lead <- big_model(tblack_0to10 ~ factor_year + code + years_before, clean_iat_data)

iat_white_nonhisp <- clean_iat_data %>%
    filter(race == 6, ethnicityomb == 2) %>%
      as.data.frame()

print("Estimating Model 13 / 18")
iat_white_plain <- big_model(d_biep.white_good_all ~ factor_year + code + sinclair_present, iat_white_nonhisp)

print("Estimating Model 14 / 18")
iat_white_linear <- big_model(d_biep.white_good_all ~ factor_year + code + code:year + sinclair_present, iat_white_nonhisp)

print("Estimating Model 16 / 18")
iat_white_lead <- big_model(d_biep.white_good_all ~ factor_year + code + years_before, iat_white_nonhisp)

print("Estimating Model 17 / 18")
therm_white_plain <- big_model(tblack_0to10 ~ factor_year + code + sinclair_present, iat_white_nonhisp)

print("Estimating Model 18 / 18")
therm_white_linear <- big_model(tblack_0to10 ~ factor_year + code + code:year + sinclair_present, iat_white_nonhisp)

print("Estimating Model 20 / 18")
therm_white_lead <- big_model(tblack_0to10 ~ factor_year + code + years_before, iat_white_nonhisp)

save(
    google_plain,
    google_linear,
    google_lead,
    iat_all_plain,
    iat_all_linear,
    iat_all_lead,
    therm_all_plain,
    therm_all_linear,
    therm_all_lead,
    iat_white_plain,
    iat_white_linear,
    iat_white_lead,
    therm_white_plain,
    therm_white_linear,
    therm_white_lead,
     file = "../data/models.Rdata")
