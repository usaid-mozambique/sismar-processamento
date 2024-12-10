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
library(openxlsx)
library(sismar)
library(mozR)

# GLOBAL VARIABLES --------------------------------------------------------


ref_id <- "3443d374"

period <- "2024-09-20"
path_cv <- glue::glue("Data/disa/Relatorio Mensal de Carga Viral Setembro 2024.xlsx")
path_dpi <- glue::glue("Data/disa/Relatorio Mensal de DPI Setembro 2024.xlsx")


# LOAD & MUNGE -------------------------------------------------------------------


df_cv <- process_disa_cv(path_cv, period)
df_dpi <- process_disa_dpi(path_dpi, period)


# WRITE MONTHLY TO DISK -----------------------------------------------------------

write_csv(df_cv, glue("Data/disa/processed/disa_cv_{period}.csv"))
write_csv(df_dpi, glue("Data/disa/processed/disa_dpi_{period}.csv"))

# COMPILE MONTHLY DATA -----------------------------------------------------------

compile_disa_cv <-
  list.files("Data/disa/processed/", pattern = "^disa_cv", full.names = TRUE) |>
  map(~ read_csv(.x)) |>
  reduce(rbind)

compile_disa_dpi <-
  list.files("Data/disa/processed/", pattern = "^disa_dpi", full.names = TRUE) |>
  map(~ read_csv(.x)) |>
  reduce(rbind)

# WRITE COMPILED DATA TO DISK -----------------------------------------------------


write_csv(compile_disa_cv, "Dataout/disa_cv.csv")
write_csv(compile_disa_dpi, "Dataout/disa_dpi.csv")


# US MAPPING CHECK --------------------------------------------------------


df_id_check <- id_check_disa(compile_disa_cv,
                             period_window = 1)

write.xlsx(df_id_check,
           {"Documents/disa_id_check.xlsx"},
           overwrite = TRUE)

