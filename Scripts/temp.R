library(tidyverse)

indicator_subset <- c(
  "CPN_MG_CON1_MES",
  "MAT_PARTOS_US",
  "CPP_1CON_MES_2DIAS",
  "PAV_SARAMPO_RUBEOLA",
  "PAV_DPT_HEP_HIB_1D",
  "MAT_RN_REANIMADO",
  "MAT_OBITO_CAUSA",
  "MAT_RN_REANIMADO"
)

db_sisma <- read_delim("Dataout/db_sisma.txt",
                       delim = "\t", escape_double = FALSE,
                       trim_ws = TRUE)


db_sisma_sub <- db_sisma |>
  filter(indicador %in% indicator_subset) |>
  write_csv("Dataout/bills_data.csv",
            na = "")
