library(tidyverse)
library(sismar)
library(janitor)
library(mozR)
library(glamr)
library(openxlsx)
library(googledrive)

# FUNCTION ----------------------------------------------------------------


map_var <- function(path, data) {
  df <- readr::read_csv(path)

  var_sisma <- names(df)
  df <- janitor::clean_names(df)
  var_sismar <- names(df)

  df <- tibble::tibble(var_sisma = var_sisma,
                       var_sismar = var_sismar)

  extracted <- stringr::str_extract(path, "(?<=sismar/).*?(?=_20)")

  df <- df %>%
    dplyr::mutate(area = stringr::str_to_upper(extracted)) %>%
    dplyr::left_join(data, dplyr::join_by(var_sismar == indicator)) |>
    add_missing_vars()

  return(df)

}


# PROCESS -----------------------------------------------------------------


p <- c("Data/sismar/tarv_2025.csv",
       "Data/sismar/ats_autoteste_2025.csv",
       "Data/sismar/ajm_hc_mm_2025.csv",
       "Data/sismar/apss_2025.csv",
       "Data/sismar/ats_ci_lig_2025.csv",
       "Data/sismar/ats_hist_chave_2025.csv",
       "Data/sismar/ats_resultados_2025.csv",
       "Data/sismar/ats_saaj_cm_2025.csv",
       "Data/sismar/ats_smi_2025.csv",
       "Data/sismar/ats_smi_ccs_ccd_2025.csv",
       "Data/sismar/bes_2025.csv",
       "Data/sismar/dah_2025.csv",
       "Data/sismar/its_2025.csv",
       "Data/sismar/prep_2025.csv",
       "Data/sismar/smi_ccd_2025.csv",
       "Data/sismar/smi_ccr_2025.csv",
       "Data/sismar/smi_ccs_2025.csv",
       "Data/sismar/smi_cpn_2025.csv",
       "Data/sismar/smi_mat_2025.csv",
       "Data/sismar/smi_pav_2025.csv",
       "Data/sismar/smi_pf_2025.csv",
       "Data/sismar/smi_pf_int_2025.csv",
       "Data/sismar/smi_ug_2025.csv"
       )


maps <- list(data_sisma_hiv_tarv_map,
             data_sisma_ats_autoteste_map,
             data_sisma_hiv_ajmhcmm_map,
             data_sisma_hiv_apss_map,
             data_sisma_ats_ci_map,
             data_sisma_ats_hist_map,
             data_sisma_ats_results_map,
             data_sisma_ats_saaj_map,
             data_sisma_ats_smi_map,
             data_sisma_ats_ccsd_map,
             data_sisma_bes_map,
             data_sisma_hiv_dah_map,
             data_sisma_hiv_its_map,
             data_sisma_hiv_prep_map,
             data_sisma_smi_ccd_map,
             data_sisma_smi_ccr_map,
             data_sisma_smi_ccs_map,
             data_sisma_smi_cpn_map,
             data_sisma_smi_mat_map,
             data_sisma_smi_pav_map,
             data_sisma_smi_pf_map,
             data_sisma_smi_pf_int_saaj_ape_map,
             data_sisma_smi_ug_map
             )


e <- c("periodid",
       "periodname",
       "periodcode",
       "perioddescription",
       "orgunitlevel1",
       "orgunitlevel2",
       "orgunitlevel3",
       "orgunitlevel4",
       "organisationunitid",
       "organisationunitname",
       "organisationunitcode",
       "organisationunitdescription")


result <- map2(p, maps, ~ map_var(.x, data = .y))

result_df <- bind_rows(result) |>
  filter(!var_sismar %in% e) |>
  select(!c(var_sismar, period_cohort)) |>
  rename(indicador_resumo = var_sisma,
         indicador_sismar = indicator_new,
         idade = age,
         idade_agrupada = age_coarse,
         sexo = sex,
         disagregacao = disaggregate,
         fonte = source,
         sub_grupo = sub_group,
         resultado_estado = result_status,
         disagregacao_sub = disaggregate_sub) |>
  relocate(area, .before = everything()) |>
  mutate(area = case_when(
    area == "TARV" ~ "HIV TARV",
    area == "ATS_AUTOTESTE" ~ "HIV ATS-AUTOTESTE",
    area == "AJM_HC_MM" ~ "HIV AJM HC MM",
    area == "APSS" ~ "HIV APSS",
    area == "ATS_CI_LIG" ~ "HIV ATS",
    area == "ATS_HIST_CHAVE" ~ "HIV ATS",
    area == "ATS_RESULTADOS" ~ "HIV ATS",
    area == "ATS_SAAJ_CM" ~ "HIV ATS SAAJ/CM",
    area == "ATS_SMI" ~ "HIV ATS SMI",
    area == "ATS_SMI_CCS_CCD" ~ "HIV ATS CCS/CCD",
    area == "BES" ~ "BES",
    area == "DAH" ~ "HIV DAH",
    area == "ITS" ~ "HIV ITS",
    area == "PREP" ~ "HIV PREP",
    area == "SMI_CCD" ~ "SMI CCD",
    area == "SMI_CCR" ~ "SMI CCR",
    area == "SMI_CCS" ~ "SMI CCS",
    area == "SMI_CPN" ~ "SMI CPN",
    area == "SMI_MAT" ~ "SMI Maternidade",
    area == "SMI_PAV" ~ "SMI PAV",
    area == "SMI_PF" ~ "SMI PF",
    area == "SMI_PF_INT" ~ "SMI PF",
    area == "SMI_UG" ~ "SMI UG",
    .default = area
  ))



result_df2 <- result_df |>
  filter(!is.na(indicador_sismar))


write_csv(result_df2,
          "Documents/sismar_indicator_mapping.csv",
          na = "")





