
library(tidyverse)
library(arrow)
library(duckdb)
library(duckplyr)
library(bench)

# write_parquet(df_sisma, "Dataout/db_sisma.parquet")
path_sisma <- "Dataout/db_sisma.parquet"

# create duckdb connection
con <- dbConnect(duckdb(), ":memory:")

# write arrow into duckdb
dbWriteTable(con,
             "db_sisma",
             read_parquet(path_sisma),
             overwrite = TRUE)  # Write into DuckDB

# create lazy table for analysis
tbl_sisma <- tbl(con, "db_sisma")
glimpse(tbl_sisma)

# test query against lazy table
df_summary <- tbl_sisma %>%
  group_by(provincia) %>%
  summarise(n = n()) %>%
  collect()
