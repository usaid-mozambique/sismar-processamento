library(tidyverse)
library(sismar)
library(janitor)

path <- "Data/sismar/bes_test.csv"

df <- process_sisma_export(path)

df <- read_csv("Data/sismar/bes_test.csv") |>
  clean_names() |>
  pivot_longer(cols = starts_with("bes_"), names_to = "indicator", values_to = "value") |>
  distinct(indicator)

patterns <- c("[_0_4]", "[_15]")

df_eng <- df |>
  mutate(indicator_new = indicator,
         indicator_new = str_remove_all(indicator_new, "_0_4"),
         indicator_new = str_remove_all(indicator_new, "_5_14"),
         indicator_new = str_remove_all(indicator_new, "_15"),
         indicator_new = str_remove_all(indicator_new, "_9_23"),
         indicator_new = str_remove_all(indicator_new, "_9"),
         indicator_new = str_remove_all(indicator_new, "_24_meses"),
         indicator_new = str_remove_all(indicator_new, "_5"),
         indicator_new = str_remove_all(indicator_new, "_anos"),
         indicator_new = str_remove_all(indicator_new, "_meses"),
         indicator_new = str_remove_all(indicator_new, "_animal"),
         indicator_new = str_remove_all(indicator_new, "_flacida_aguda"),
         indicator_new = str_replace(indicator_new, "_nao_vacinados", "_nao_vac"),
         indicator_new = str_replace(indicator_new, "_recem_nascidos", "_rn"),
         indicator_new = str_to_upper(indicator_new),
         age =  case_when(str_detect(indicator, "_0_4_") ~ "00-04",
                          str_detect(indicator, "_15_") ~ "15+",
                          str_detect(indicator, "_9_23_") ~ "09-24m",
                          str_detect(indicator, "_9_") ~ "<09m",
                          str_detect(indicator, "_24_meses_") ~ "<02",
                          str_detect(indicator, "_5_") ~ "<05",
                          str_detect(indicator, "_5_14_") ~ "05-14"),
         age_coarse = case_match(age, c("00-04", "<05", "<02", "09-24m", "<09m") ~ "<15",
                                 "15+" ~ "15+"),
         source = "BES")



unique(df_eng$indicator_new)

write_csv(df_eng,
          "Documents/bes_indicators.csv",
          na = ""
          )


data_dah <- read_csv("Documents/data dah.csv") |>
  clean_names() |>
  names() |>
  as_tibble() |>
  write_csv("Documents/dah_eng.csv", na = "")
