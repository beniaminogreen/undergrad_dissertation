## ----echo=FALSE, warn=FALSE, include=FALSE------------------------------------
# Set options to knit this document, load libraries
knitr::opts_chunk$set(out.width="100%", message=F, cache=T,echo=F, warn=F, include=F)
library(tidyverse)
library(sf)
library(broom)
library(stargazer)


## ----include=T, warn=FALSE----------------------------------------------------
library(ggrepel)

state_iat_data <- read_csv("../data/iat_state_data.csv")
word1_state_data <- read_csv("../data/word1_all_time.csv")

state_iat_searches <- full_join(state_iat_data,word1_state_data) %>%
    mutate(sbp5 = 5 - sbp5) %>%
    drop_na()


## ----include=T----------------------------------------------------------------
ggplot(state_iat_searches, aes(word1, iat, label=state)) +
    geom_text_repel() +
    geom_smooth(method="lm") +
    xlab("Frequency of Google Searches for [Word 1]") +
    ylab("Scaled IAT Score of White Respondents")


## ----include=T----------------------------------------------------------------
ggplot(state_iat_searches, aes(word1, sbp5, label=state)) +
    geom_text_repel() +
    geom_smooth(method="lm") +
    xlab("Frequency of Google Searches for [Word 1]") +
    ylab("Scaled Responses to Prompt 5")


## -----------------------------------------------------------------------------
library(tidyverse)
# Load and create data to show markets Sinclair has expanded to / moved out of
sinclair_expansions <- read_csv("../data/clean_sinclair_data.csv") %>%
    nest(-code) %>%
    mutate(
           any_true =  data %>% map_lgl(~any(.$sinclair_present)),
           any_false =  data %>% map_lgl(~any(!.$sinclair_present)),
           changed = any_true & any_false
    )


dma_boundaries <- st_read("../data/dma_boundaries/dma_boundary.shp")
dma_boundaries <- merge(dma_boundaries, sinclair_expansions, by.x="dma0", by.y="code")


## ----include = T--------------------------------------------------------------
#Plot markets Sinclair has expanded to / moved out of
ggplot() +
    geom_sf(data=dma_boundaries, aes(fill=changed), alpha=.5) +
    scale_fill_manual(values  = c(NA, "blue")) +
    theme_void() +
    theme(legend.pos ="none")


## ----include = T--------------------------------------------------------------
#Plot markets Sinclair has expanded to / moved out of
sinclair_expansions %>%
    unnest() %>%
    unite("fill", changed:sinclair_present, remove = F)  %>%
    mutate(code = fct_reorder2(as.factor(code),as.factor(changed),as.factor(fill))) %>%
    ggplot(aes(year,code, fill=fill)) +
    geom_raster() +
    scale_fill_manual(values = c("green","darkblue","yellow", "purple")) +
    scale_y_discrete(breaks=c()) +
    theme(legend.position = "none")


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
	add.lines =list(c("Year Fixed Effects", "Yes", "Yes"),c("Region Fixed Effects", "Yes", "Yes"), c("Region Time Trends", "No", "Yes")),
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


## ----echo=FALSE, include=T----------------------------------------------------
# Pull R code out of this document to put into the appendix
code <- knitr::purl("diss.Rnw", quiet=T)

