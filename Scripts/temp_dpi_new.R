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



# LOAD & MUNGE -------------------------------------------------------------------


# FUNCTION ----------------------------------------------------------------

path_dpi <- glue::glue("Data/disa/Relatorio Mensal de DPI December 2024 template.xlsx")
month <- "2024-12-20"


df_dpi <- process_disa_dpi(file = path_dpi,
                           period = month,
                           type = "new")

# df_dpi <- process_disa_dpi(file = path_dpi,
#                            period = month,
#                            type = "new")


# OTHER -------------------------------------------------------------------


write_csv(df_dpi, glue("Data/disa/processed/disa_dpi_{month}.csv"),
          na = "")


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

