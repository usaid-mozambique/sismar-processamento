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

# GLOBALS -----------------------------------------------------------------

path_cpn <- "Data/smi_cpn.csv"
path_mat <- "Data/smi_mat.csv"
path_pav <- "Data/smi_pav.csv"

# CPN --------------------------------------------------------------------


df_cpn_data <- clean_sisma_csv(path_cpn) |>
  parse_sisma_smi_cpn() |>
  set_language() |>
  filter(indicador == "CPN_MG_CON1_MES") |>
  pivot_wider(names_from = "periodo", values_from = "valor", values_fill = list(valor = NA)) |>
  group_by(across(c(sisma_uid, provincia, distrito, us, indicador))) |>
  summarise(across(
    c(`2022-01-01`:`2024-12-01`),
    ~ ifelse(all(is.na(.x)), NA, sum(.x, na.rm = TRUE))
  )) |>
  ungroup()

df_cpn_count <- df_cpn_data |>
  mutate(count_district = rowSums(across(where(is.numeric)), na.rm = TRUE)) |>
  filter(count_district > 0) |>
  group_by(across(c(provincia, distrito))) |>
  summarise(count = n()) |>
  ungroup()

df_cpn <- df_cpn_data |>
  left_join(df_cpn_count, by = c("provincia", "distrito")) |>
  relocate(count, .before = everything())

rm(df_cpn_data, df_cpn_count)

# MAT --------------------------------------------------------


df_mat_data <- clean_sisma_csv(path_mat) |>
  parse_sisma_smi_mat() |>
  set_language() |>
  filter(indicador == "MAT_PARTOS_US") |>
  pivot_wider(names_from = "periodo", values_from = "valor", values_fill = list(valor = NA)) |>
  group_by(across(c(sisma_uid, provincia, distrito, us, indicador))) |>
  summarise(across(
    c(`2022-01-01`:`2024-12-01`),
    ~ ifelse(all(is.na(.x)), NA, sum(.x, na.rm = TRUE))
  )) |>
  ungroup()

df_mat_count <- df_mat_data |>
  mutate(count_district = rowSums(across(where(is.numeric)), na.rm = TRUE)) |>
  filter(count_district > 0) |>
  group_by(across(c(provincia, distrito))) |>
  summarise(count = n()) |>
  ungroup()

df_mat <- df_mat_data |>
  left_join(df_mat_count, by = c("provincia", "distrito")) |>
  relocate(count, .before = everything())

rm(df_mat_data, df_mat_count)


# PAV ---------------------------------------------------------------------


df_pav_data <- clean_sisma_csv(path_pav) |>
  parse_sisma_smi_pav() |>
  set_language() |>
  filter(indicador == "PAV_DPT_HEP_HIB_1D",
         disagregacao == "Brigada Movel") |>
  pivot_wider(names_from = "periodo", values_from = "valor", values_fill = list(valor = NA)) |>
  group_by(across(c(sisma_uid, provincia, distrito, us, indicador))) |>
  summarise(across(
    c(`2022-01-01`:`2024-12-01`),
    ~ ifelse(all(is.na(.x)), NA, sum(.x, na.rm = TRUE))
  )) |>
  ungroup()


df_pav_count <- df_pav_data |>
  mutate(count_district = rowSums(across(where(is.numeric)), na.rm = TRUE)) |>
  filter(count_district > 0) |>
  group_by(across(c(provincia, distrito))) |>
  summarise(count = n()) |>
  ungroup()

df_pav <- df_pav_data |>
  left_join(df_mat_count, by = c("provincia", "distrito")) |>
  relocate(count, .before = everything())

rm(df_pav_data, df_pav_count)

# MERGE -------------------------------------------------------------------


# dfs <- mget(ls(pattern = "^df_"), envir = .GlobalEnv)
# df <- bind_rows(dfs, .id = "source") |> rm(dfs)

df <- bind_rows(df_cpn, df_mat, df_pav)


df |>
  write_csv("Dataout/reporting_rates.csv",
            na = "")




# MAT --------------------------------------------------------


df_mat <- df |>
  filter(indicador == "MAT_PARTOS_US") |>
  pivot_wider(names_from = "periodo", values_from = "valor", values_fill = list(valor = NA)) |>
  group_by(across(c(sisma_uid, provincia, distrito, us, indicador))) |>
  summarise(across(c(`1/1/2022`:`12/1/2024`), sum, na.rm = TRUE)) |>
  ungroup()

df_mat_count <- df_mat |>
  group_by(across(c(provincia, distrito))) |>
  summarise(count = n()) |>
  ungroup()

df_mat_distrito <- df_mat |>
  mutate(across(`1/1/2022`:`12/1/2024`, ~ if_else(is.na(.) | . == 0, 0, 1))) |>
  group_by(across(c(provincia, distrito))) |>
  summarise(across(c(`1/1/2022`:`12/1/2024`), sum, na.rm = TRUE)) |>
  ungroup() |>
  left_join(df_mat_count, by = c("provincia", "distrito")) |>
  mutate(across(c(`1/1/2022`:`12/1/2024`), ~ . / count, .names = "RR_{.col}"),
         sector = "MAT")


# PAV ---------------------------------------------------------------------

df_pav <- df |>
  filter(indicador == "PAV_SARAMPO_RUBEOLA") |>
  pivot_wider(names_from = "periodo", values_from = "valor", values_fill = list(valor = NA)) |>
  group_by(across(c(sisma_uid, provincia, distrito, us, indicador))) |>
  summarise(across(c(`1/1/2022`:`12/1/2024`), sum, na.rm = TRUE)) |>
  ungroup()

df_pav_count <- df_pav |>
  group_by(across(c(provincia, distrito))) |>
  summarise(count = n()) |>
  ungroup()

df_pav_distrito <- df_pav |>
  mutate(across(`1/1/2022`:`12/1/2024`, ~ if_else(is.na(.) | . == 0, 0, 1))) |>
  group_by(across(c(provincia, distrito))) |>
  summarise(across(c(`1/1/2022`:`12/1/2024`), sum, na.rm = TRUE)) |>
  ungroup() |>
  left_join(df_pav_count, by = c("provincia", "distrito")) |>
  mutate(across(c(`1/1/2022`:`12/1/2024`), ~ . / count, .names = "RR_{.col}"),
         sector = "PAV")



# COMPILE -----------------------------------------------------------------

df_compile <- bind_rows(df_cpn_distrito,
                        df_mat_distrito,
                        df_pav_distrito) |>
  relocate(sector, .before = everything()) |>
  write_csv("Documents/reporting_rates_compile.csv")


# MAL ---------------------------------------------------------------------


df_mal <- df |>
  filter(indicador == "MAL_CE") |>
  pivot_wider(names_from = "periodo", values_from = "valor", values_fill = list(valor = NA)) |>
  group_by(across(c(sisma_uid, provincia, distrito, us, indicador))) |>
  summarise(across(c(`1/1/2022`:`12/1/2024`), sum, na.rm = TRUE)) |>
  ungroup()

df_mal_count <- df_mal |>
  group_by(across(c(provincia, distrito))) |>
  summarise(count = n()) |>
  ungroup()

df_pav_distrito <- df_pav |>
  mutate(across(`1/1/2022`:`12/1/2024`, ~ if_else(is.na(.) | . == 0, 0, 1))) |>
  group_by(across(c(provincia, distrito))) |>
  summarise(across(c(`1/1/2022`:`12/1/2024`), sum, na.rm = TRUE)) |>
  ungroup() |>
  left_join(df_pav_count, by = c("provincia", "distrito")) |>
  mutate(across(c(`1/1/2022`:`12/1/2024`), ~ . / count, .names = "RR_{.col}"),
         sector = "MAT")





df_cpn_distrito |>
  write_csv("Dataout/reporting_rates_cpn.csv",
            na = "")

