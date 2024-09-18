# PROJECT:
# AUTHOR:   J. Lara | USAID
# PURPOSE:
# REF ID:   3443d374
# LICENSE:  MIT
# DATE:     2024-09-18
# UPDATED:

# DEPENDENCIES ------------------------------------------------------------

library(tidyverse)
library(gagglr)
library(janitor)
library(glue)
library(googledrive)
library(googlesheets4)
library(readxl)
library(sismar)
library(mozR)

# GLOBAL VARIABLES --------------------------------------------------------


ref_id <- "3443d374"

period <- "2024-08-20"
path_cv <- glue::glue("Data/disa/Relatorio Mensal de Carga Viral Agosto 2024.xlsx")
path_dpi <- glue::glue("Data/disa/Relatorio Mensal de DPI Agosto 2024.xlsx")


# LOAD DATA ------------------------------------------------------------------

df_cv <- process_disa_cv(path_cv, period)
df_dpi <- process_disa_dpi(path_dpi, period)

# MUNGE -------------------------------------------------------------------
