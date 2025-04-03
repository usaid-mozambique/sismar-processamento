# PROJECT:
# AUTHOR:   J. Lara | USAID
# PURPOSE:
# REF ID:   fd5f23e4
# LICENSE:  MIT
# DATE:     2025-04-03
# UPDATED:

# DEPENDENCIES ------------------------------------------------------------

  library(tidyverse)
  library(readxl)
  library(gagglr)
  library(janitor)
  library(glue)
  library(googledrive)
  library(googlesheets4)
  library(sismar)

# GLOBAL VARIABLES --------------------------------------------------------



# LOAD DATA ------------------------------------------------------------------

df <- read_excel("Data/nsimam/informacao_do_estado_de_stock_030625.xlsx")
map <- read_excel("Documents/lmis_sisma_map.xlsx")


# MUNGE -------------------------------------------------------------------

glimpse(df)

data_nsimam_sitelist <- map |>
  select(!c(provincia, distrito, fonte, disagregacao, latitude, longitude))

df1 <- df |>
  clean_names() |>
  left_join(data_nsimam_sitelist, join_by(nome_da_instalacao == nsimam_uid)) |>
  mutate(provincia = str_to_title(provincia)) |>
  select(
    sisma_uid,
    provincia,
    distrito,
    "us" = nome_da_instalacao,
    "tipo_us" = tipo_de_instalacao,

    programa,
    "data_ultima_actualizacao" = ultima_atualizacao,
    "data_validade_mais_curta" = prazo_de_validade_mais_curto,
    "producto_codigo" = codigo_do_produto,
    "produto_nome" = nome_do_produto,

    "stock_estado" = estado_de_stock,
    "stock_existente" = total_do_stock_existente,
    "stock_valor" = valor_total,
    "stock_meses" = meses_de_stock,
    "stock_consumo_medio_mensal" = cmm)

write_csv(df1, "Documents/nsimam_clean.csv", na = "")


