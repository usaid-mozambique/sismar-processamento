
# DEPENDENCIES ------------------------------------------------------------

library(tidyverse)
library(mozR)
library(glamr)
library(googlesheets4)
library(googledrive)
library(fs)
library(lubridate)
library(janitor)
library(readxl)
library(openxlsx)
library(glue)
library(gt)
load_secrets()

# GLOBAL VARIABLES --------------------------------------------------------

# define google drive id
googlesheet_file_id <- "https://docs.google.com/spreadsheets/d/1JyENA4JjNStPl-3gf6GRAAI7WjrE0-dy/edit?gid=1703158176#gid=1703158176"

# define file type
file_type <- tempfile(fileext = ".xlsx")

# fetch google drive excel
drive_download(as_id(googlesheet_file_id),
               path = file_type,
               overwrite = TRUE)

# pull sheet names file
sheet_names <- excel_sheets(file_type)
sheet_names <- sheet_names[!sheet_names %in% c("Sheet2", "January 31")]


# read and bind sheet data
df <- map_dfr(sheet_names, ~ read_excel(file_type, sheet = .x) %>% mutate(sheet_name = .x)) |>
  filter(snu %in% c("Sofala", "Manica", "Tete", "Niassa")) |>
  select(!c(`N de dias de Semana Aberto (1-5)`,
            `Estimativa da percentagem de pessoal presente na US? (%)`,
            `US Aberta mas inaccessivel`)
  ) |>
  clean_names()

t <- unique(df$data)

df |>
  write_csv("Dataout/protest_effects.csv",
            na = "")


# CDC Data ----------------------------------------------------------------

file_path <- "Data/WeeklyMonitoring_Compiled.xlsx"

# Get sheet names
sheets <- excel_sheets(file_path)

# Read all sheets and row bind them
combined_data <- sheets %>%
  set_names() %>%  # Retain sheet names as a reference
  map_df(~ read_xlsx(file_path, sheet = .x, col_types = "guess"), .id = "sheet_name")


cd1 <- combined_data |>
  mutate(Date = ymd(Date)) |>
  clean_names() |>
  rename(data = date) |>
  select(!c(source_name,
            n_de_dias_de_semana_aberto_1_5,
            estimativa_da_percentagem_de_pessoal_presente_na_us_percent,
            afarmacia_registou_rupturas_de_stock_de_testes_rapidos_de_hiv_determine_unigold,
            comments)) |>
  glimpse()


setdiff(names(cd1), names(df))


df_final <- bind_rows(cd1, df) |>
  mutate(value = 1)

df_final |>
  distinct(data)


df_final |>
  write_csv("Dataout/protest_effects.csv",
            na = "")

