setwd("C:\\Users\\Hannah\\Documents\\Thesis\\data")

pacman::p_load(haven)
pacman::p_load(devtools)
# devtools::install_github("Guidowe/occupationcross")
library(occupationcross)
library(tidyverse)
library(rlang) 
library(tidyr)
library(dplyr)
# install.packages("tidyverse")
# install.packages("tidyr")
# install.packages("rlang")

data <- read_dta("cleandata.dta")

data <- data.frame(data)
crossed_base <- reclassify_to_isco08(base = data,
                                     variable = occupation_typea,
                                     classif_origin = "ISCO88",
                                     add_major_groups = T,
                                     code_titles = T)

crossed_base <- reclassify_to_isco08(base = data,
                                     variable = occupation_typea,
                                     classif_origin = "ISCO88",
                                     code_titles = T)

finished_data <- crossed_base %>% rename(isco08 = ISCO.08)

write_dta(finished_data, "Rcrosswalkedonly2345.dta")




