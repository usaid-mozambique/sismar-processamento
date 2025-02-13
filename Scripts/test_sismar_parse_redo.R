library(tidyverse)
library(sismar)
library(readxl)

year <- "2024"

# INPUT/OUTPUT PATHS ------------------------------------------------------------

# input paths
path_ats_results <- glue::glue("Data/sismar/ats_resultados_{year}.csv")


ensure_columns <- function(df, required_cols) {
  missing_cols <- setdiff(required_cols, names(df))  # Identify missing columns
  df <- df %>%
    mutate(across(all_of(required_cols[required_cols %in% names(df)]), ~ .)) %>%  # Keep existing columns unchanged
    mutate(across(all_of(missing_cols), ~ NA))  # Create missing columns with NA

  return(df)
}


# LOAD DATA ---------------------------------------------------------------


data_sisma_ats_results_map <- read_excel("C:/Users/jlara/Downloads/sisma_var_mapping (22).xlsx",
                                         sheet = "data_sisma_ats_results_map")

ref <- clean_sisma_csv(path_ats_results) |>
  parse_sisma_ats_results()


df <- clean_sisma_csv(path_ats_results) |>
  dplyr::filter(!is.na(value)) |>
  dplyr::left_join(data_sisma_ats_results_map, by = "indicator") |>
  dplyr::mutate(
    indicator = "ATS_TST",
    source = "LdR ATS",
    age_coarse = dplyr::case_when(age == "<01"   ~ "<15",
                                  age == "01-09" ~ "<15",
                                  age == "10-14" ~ "<15"),
    age_coarse = tidyr::replace_na(age_coarse, "15+"))


required_cols <- c("disaggregate_sub", "period_cohort", "sub_group", "period")
missing_cols <- setdiff(required_cols, names(df))


df <- df |>
    bind_cols(tibble(!!!setNames(rep(list(NA), length(missing_cols)), missing_cols)))




add_missing_vars <- function(df) {

  # Required variables
  required_cols <- c("period_cohort",
                     "age",
                     "age_coarse",
                     "sex",
                     "sub_group",
                     "result_status",
                     "disaggregate",
                     "disaggregate_sub"
  )

  # Identify missing variables
  missing_cols <- setdiff(required_cols, names(df))

  # Define NA values with explicit types
  add_cols <- list(
    period_cohort = as.Date(NA),
    age = NA_character_,
    age_coarse = NA_character_,
    sex = NA_character_,
    result_status = NA_character_,
    disaggregate = NA_character_,
    disaggregate_sub = NA_character_,
    sub_group = NA_character_
  )

  # Ensure missing variables exist with the correct data types
  df <- df |>
    bind_cols(tibble(!!!setNames(lapply(missing_cols, function(col) add_cols[[col]]), missing_cols)))

  return(df)

}











# Ensure the columns exist, adding them with NA if they don't
df <- df %>%
  mutate(across(all_of(required_cols), ~ if_else(is.na(.), ., NA_real_), .names = "temp_{.col}")) %>%
  rename_with(~ sub("temp_", "", .), starts_with("temp_"))

