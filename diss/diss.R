## ----echo=FALSE, warn=FALSE, include=FALSE------------------------------------
# Set options to knit this document, load libraries
knitr::opts_chunk$set(out.width="100%", message=F, cache=T,echo=F, warn=F, include=F)
library(tidyverse)
library(sf)
library(broom)
library(stargazer)


## -----------------------------------------------------------------------------
# Load and create data to show markets Sinclair has expanded to / moved out of
sinclair_expansions <- read_csv("../data/clean_sinclair_data") %>%
    nest(-code) %>%
    mutate(
           any_true =  data %>% map_lgl(~any(.$sinclair_present)),
           any_false =  data %>% map_lgl(~any(!.$sinclair_present)),
           changed = any_true & any_false
    )

dma_boundaries <- st_read("../data/dma_boundaries/dma_boundary.shp")
dma_boundaries <- merge(dma_boundaries, sinclair_expansions, by.x="dma0", by.y="code")


## ----include = T--------------------------------------------------------------
# Plot markets Sinclair has expanded to / moved out of
ggplot() +
    geom_sf(data=dma_boundaries, aes(fill=changed), alpha=.5) +
    scale_fill_manual(values  = c(NA, "blue")) +
    ggtitle("Map of Sinclair Stations That Bought or Sold in 2004-2021") +
    theme_void()


## -----------------------------------------------------------------------------
full_data <- read_csv("../data/full_data.csv") %>%
    mutate(code = as.factor(code))

full_data %>%
    nest(-code) %>%
    mutate(
           any_true =  data %>% map_lgl(~any(.$sinclair_present)),
           any_false =  data %>% map_lgl(~any(!.$sinclair_present)),
           changed = any_true & any_false
    ) %>%
    unnest()  %>%
    arrange(changed,years_before) %>%
    mutate(group_num = as.integer(factor(code, levels = unique(.$code)))) %>%
    ungroup() %>%
    mutate(col = interaction(changed,sinclair_present)) %>%
ggplot(aes(x=year,y=group_num,fill=col)) +
geom_raster()




## -----------------------------------------------------------------------------

model_1 <- lm(sword1 ~ as.factor(year) + code + sinclair_present, data = full_data)

model_2 <- lm(sword1 ~ as.factor(year) + code + code:year+ sinclair_present, data = full_data)

model_3 <- lm(sword1 ~ as.factor(year) + as.factor(code) + as.factor(years_before), data = full_data)



## ----include=TRUE, results="asis"---------------------------------------------
stargazer(model_1, model_2,
          omit=c('^as\\.factor\\(year\\)[0-9]{4}$',
                 "^code[0-9]{3}$",
                 "^code[0-9]{3}\\:year$"
                 ),
	title = "Fixed-Effect Model Results",
	dep.var.labels = c("Frequency of Google Searches for \\wone"),
	covariate.labels = c("Sinclair Present", "Constant"),
	add.lines =list(c("Year Fixed Effects", "Yes", "Yes"),c("Region Fixed Effects", "Yes", "Yes"), c("Region / Year Fixed Effects", "No", "Yes")),
           table.placement="H")


## ----include =T, warn = FALSE-------------------------------------------------
model_3 %>%
  tidy() %>%
  na.omit() %>%
  filter(grepl("years_before", term)) %>%
  mutate(term = as.numeric(gsub("[^0-9\\-]+", "", term))) %>%
  ggplot(aes(x = term, y = estimate)) +
  geom_point() +
  geom_errorbar(aes(ymin = estimate - 1.96 * std.error, ymax = estimate + 1.96 * std.error)) +
  geom_hline(aes(yintercept=0), linetype=2) +
  geom_vline(aes(xintercept=0)) +
  xlab("Years Relative to Sinclair Acquisition") +
  ylab("Estimated Effect of Acquisition on Number of Racially-Charged Google Searches")


## ----include =T, warn = FALSE-------------------------------------------------
full_data <- full_data %>%
    mutate(years_before_5 = cut(years_before,c(-100,seq(-15,25,5)),right=F))

model_4 <- lm(sword1 ~ as.factor(year) + as.factor(code) + as.factor(years_before_5), data = full_data)

model_4 %>%
  tidy() %>%
  na.omit() %>%
  filter(grepl("years_before", term)) %>%
  mutate(term = gsub(".*\\[", "[", term)) %>%
  ggplot(aes(x = term, y = estimate)) +
  geom_point() +
  geom_errorbar(aes(ymin = estimate - 1.96 * std.error, ymax = estimate + 1.96 * std.error)) +
  geom_hline(aes(yintercept=0), linetype=2) +
  geom_vline(aes(xintercept="[0,5)"),linetype=2) +
  xlab("Years Relative to Sinclair Acquisition") +
  ylab("Estimated Effect of Acquisition on Number of Racially-Charged Google Searches")



## ----echo=FALSE, include=T----------------------------------------------------
# Pull R code out of this document to put into the appendix
code <- knitr::purl("diss.Rnw", quiet=T)

