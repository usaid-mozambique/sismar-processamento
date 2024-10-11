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
  path_smi_cpn <- glue::glue("Data/sismar/smi_cpn_{year}.csv")
  path_smi_mat <- glue::glue("Data/sismar/smi_mat_{year}.csv")
  path_smi_ccr <- glue::glue("Data/sismar/smi_ccr_{year}.csv")
  path_smi_cpp <- glue::glue("Data/sismar/smi_cpp_{year}.csv")
  path_smi_ccd <- glue::glue("Data/sismar/smi_ccd_{year}.csv")
  path_smi_ccs <- glue::glue("Data/sismar/smi_ccs_{year}.csv")
  path_smi_ug <- glue::glue("Data/sismar/smi_ug_{year}.csv")
  path_smi_pf <- glue::glue("Data/sismar/smi_pf_{year}.csv")
  path_smi_pf_int <- glue::glue("Data/sismar/smi_pf_int_{year}.csv")

  # output paths
  output_smi_cpn <- glue::glue("Data/sismar/processed/smi_cpn_{year}.txt")
  output_smi_mat <- glue::glue("Data/sismar/processed/smi_mat_{year}.txt")
  output_smi_ccr <- glue::glue("Data/sismar/processed/smi_ccr_{year}.txt")
  output_smi_cpp <- glue::glue("Data/sismar/processed/smi_cpp_{year}.txt")
  output_smi_ccd <- glue::glue("Data/sismar/processed/smi_ccd_{year}.txt")
  output_smi_ccs <- glue::glue("Data/sismar/processed/smi_ccs_{year}.txt")
  output_smi_ug <- glue::glue("Data/sismar/processed/smi_ug_{year}.txt")
  output_smi_pf <- glue::glue("Data/sismar/processed/smi_pf_{year}.txt")
  output_smi_pf_int <- glue::glue("Data/sismar/processed/smi_pf_int_{year}.txt")

  # PROCESS YEARLY FILES -------------------------------------------------------------------

  df_smi_cpn <- process_sisma_export(path_smi_cpn)

  df_smi_mat <- process_sisma_export(path_smi_mat)

  df_smi_ccr <- process_sisma_export(path_smi_ccr)

  df_smi_cpp <- process_sisma_export(path_smi_cpp)

  df_smi_ccd <- process_sisma_export(path_smi_ccd)

  df_smi_ccs <- process_sisma_export(path_smi_ccs)

  df_smi_ug <- process_sisma_export(path_smi_ug)

  df_smi_pf <- process_sisma_export(path_smi_pf)

  df_smi_pf_int <- process_sisma_export(path_smi_pf_int)

  # WRITE YEARLY FILES -----------------------------------------------------------

  write_tsv(df_smi_cpn,
            output_smi_cpn)

  write_tsv(df_smi_mat,
            output_smi_mat)

  write_tsv(df_smi_ccr,
            output_smi_ccr)

  write_tsv(df_smi_cpp,
            output_smi_cpp)

  write_tsv(df_smi_ccd,
            output_smi_ccd)

  write_tsv(df_smi_ccs,
            output_smi_ccs)

  write_tsv(df_smi_ug,
            output_smi_ug)

  write_tsv(df_smi_pf,
            output_smi_pf)

  write_tsv(df_smi_pf_int,
            output_smi_pf_int)

# GENERATE HISTORICAL FROM YEARLY -----------------------------------------

  historical_dsf <-
    list.files("Data/sismar/processed/", pattern = "^smi_", full.names = TRUE) %>%
    map(~ read_tsv(.x)) %>%
    reduce(rbind)
    # attach_meta_pepfar_ip() |>
    # attach_meta_mq()

# WRITE HISTORICAL TO DISK ------------------------------------------------

  write_tsv(
    historical_dsf,
    "Dataout/db_dsf.txt",
    na = ""
  )
