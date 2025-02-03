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

path_ce_2022 <- glue::glue("Documents/ce_{year}.csv")
path_ce_2023 <- glue::glue("Documents/ce_{year}.csv")
path_ce_2024 <- glue::glue("Documents/ce_{year}.csv")
path_ref <- glue::glue(("Data/sismar/smi_cpn_2024.csv"))

df <- clean_sisma_csv(path_ce_2022)
df_ref <- process_sisma_export(path_ref)
df_eng <- read_csv("Documents/ce_indicators.csv")


df1 <- df |>
  left_join(df_eng, by = c("indicator" = "indicator")) |>
  select(!indicator) |>
  rename(periodo = period,
         provincia = snu,
         distrito = psnu,
         us = sitename,
         valor = value) |>
  mutate(periodo_coorte = NA) |>
  select(
    sisma_uid,
    provincia,
    distrito,
    us,
    periodo,
    periodo_coorte,
    indicador,
    fonte,
    disagregacao,
    disagregacao_sub,
    sub_grupo,
    sexo,
    idade,
    idade_agrupada,
    resultado_estado,
    valor
  )


df1 |>
  write_csv("Dataout/bills_data_2.csv",
            na = "")

setdiff(names(df1), names(df_ref))
setdiff(names(df_ref), names(df1))

