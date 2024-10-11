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

  year <- "2024"

  # INPUT/OUTPUT PATHS ------------------------------------------------------------

  # input paths
  path_ats_results <- glue::glue("Data/sismar/ats_resultados_{year}.csv")
  path_ats_hist <- glue::glue("Data/sismar/ats_hist_chave_{year}.csv")
  path_ats_ci <- glue::glue("Data/sismar/ats_ci_lig_{year}.csv")
  path_ats_ccsd <- glue::glue("Data/sismar/ats_smi_ccs_ccd_{year}.csv")
  path_ats_saaj <- glue::glue("Data/sismar/ats_saaj_cm_{year}.csv")
  path_ats_smi <- glue::glue("Data/sismar/ats_smi_{year}.csv")
  path_ats_auto <- glue::glue("Data/sismar/ats_autoteste_{year}.csv")
  path_hiv_dah <- glue::glue("Data/sismar/dah_{year}.csv")
  path_hiv_tarv <- glue::glue("Data/sismar/tarv_{year}.csv")
  path_hiv_prep <- glue::glue("Data/sismar/prep_{year}.csv")
  path_hiv_apss <- glue::glue("Data/sismar/apss_{year}.csv")
  path_hiv_its <- glue::glue("Data/sismar/its_{year}.csv")
  path_hiv_ajmhcmm <- glue::glue("Data/sismar/ajm_hc_mm_{year}.csv")
  path_smi_cpn <- glue::glue("Data/sismar/smi_cpn_{year}.csv")
  path_smi_ccr <- glue::glue("Data/sismar/smi_ccr_{year}.csv")

  # output paths
  output_ats <- glue::glue("Data/sismar/processed/ats_{year}.txt")
  output_ats_auto <- glue::glue("Data/sismar/processed/ats_autoteste_{year}.txt")
  output_hiv_tarv <- glue::glue("Data/sismar/processed/hiv_tarv_{year}.txt")
  output_hiv_dah <- glue::glue("Data/sismar/processed/hiv_dah_{year}.txt")
  output_hiv_prep <- glue::glue("Data/sismar/processed/hiv_prep_{year}.txt")
  output_hiv_apss <- glue::glue("Data/sismar/processed/hiv_apss_{year}.txt")
  output_hiv_its <- glue::glue("Data/sismar/processed/hiv_its_{year}.txt")
  output_hiv_ajmhcmm <- glue::glue("Data/sismar/processed/ajm_hc_mm_{year}.txt")
  output_smi_ccr <- glue::glue("Data/sismar/processed/smi_ccr_{year}.txt")



  # PROCESS PORTUGUESE-------------------------------------------------------------------

  df_ats <- bind_rows(process_sisma_export(path_ats_results),
                      process_sisma_export(path_ats_hist),
                      process_sisma_export(path_ats_ci),
                      process_sisma_export(path_ats_ccsd),
                      process_sisma_export(path_ats_saaj),
                      process_sisma_export(path_ats_smi)) |>
    write_tsv(output_ats)


  df_autoteste <- process_sisma_export(path_ats_auto) |>
    write_tsv(output_ats_auto)


  df_apss <- process_sisma_export(path_hiv_apss) |>
    write_tsv(output_hiv_apss)


  df_its <- process_sisma_export(path_hiv_its) |>
    write_tsv(output_hiv_its)


  df_prep <- process_sisma_export(path_hiv_prep) |>
    write_tsv(output_hiv_prep)


  df_tarv <- process_sisma_export(path_hiv_tarv) |>
    write_tsv(output_hiv_tarv)


  df_dah <- process_sisma_export(path_hiv_dah) |>
    write_tsv(output_hiv_dah)


  df_ajmhcmm <- process_sisma_export(path_hiv_ajmhcmm) |>
    write_tsv(output_hiv_ajmhcmm)


  df_smi_cpn <- process_sisma_export(path_smi_cpn) |>
    write_tsv(output_smi_cpn)


  df_smi_ccr <- process_sisma_export(path_smi_ccr) |>
    write_tsv(output_smi_ccr)


# WRITE MONTHLY TO DISK ---------------------------------------------------

  historical_hiv <-
    list.files("Data/sismar/processed/", pattern = "^hiv|^ats|^ajm_hc_mm|^smi_cpn|^smi_ccr", full.names = TRUE) %>%
    map(~ read_tsv(.x)) %>%
    reduce(rbind)
    # attach_meta_pepfar_ip() |>
    # attach_meta_mq()
