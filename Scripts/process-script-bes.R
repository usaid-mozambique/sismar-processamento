# PROJECT:
# AUTHOR:   J. Lara | USAID
# PURPOSE:
# REF ID:   447e9ada
# LICENSE:  MIT
# DATE:     2024-09-20
# UPDATED:

# DEPENDENCIES ------------------------------------------------------------

library(tidyverse)
library(sismar)
library(janitor)
library(mozR)
library(glamr)
library(openxlsx)
library(googledrive)
load_secrets()

# GLOBAL VARIABLES --------------------------------------------------------

ref_id <- "447e9ada"

# USER INPUT --------------------------------------------------------------

year <- "2022"

# INPUT/OUTPUT PATHS ------------------------------------------------------------

# input paths
path_bes_results <- glue::glue("Data/sismar/bes_{year}.csv")


# output paths
output_bes <- glue::glue("Data/sismar/processed/bes_{year}.txt")

# PROCESS PORTUGUESE-------------------------------------------------------------------

df <- process_sisma_export(path_bes_results) |> #fix!!!!!!!! #ok
  write_tsv(output_bes, na = "")

# WRITE MONTHLY TO DISK ---------------------------------------------------


