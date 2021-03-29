## ----echo=FALSE, warn=FALSE, include=FALSE------------------------------------
# Set options to knit this document, load libraries
knitr::opts_chunk$set(out.width="100%", message=F, cache=T,echo=F, warn=F, include=F)
library(tidyverse)
library(sf)


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


## ----echo=FALSE, include=T----------------------------------------------------
# Pull R code out of this document to put into the appendix
code <- knitr::purl("diss.Rnw", quiet=T)

