
library(tidyverse)
library(arrow)
library(duckdb)
library(duckplyr)
library(bench)

path_sisma <- "Dataout/db_sisma.txt"

# create duckdb connection
con <- dbConnect(duckdb::duckdb(), ":memory:")  # Use in-memory or specify a file path

# import sisma dataset as arrow
arrow_table <- read_delim_arrow(path_sisma, delim = "\t")  # Change delim if needed

duckdb::dbWriteTable(con, "db_sisma", arrow_table, overwrite = TRUE)

tbl_sisma <- tbl(con, "db_sisma")

df_sisma <- tbl_sisma %>%
  collect()  # `collect()` brings the result into R as a tibble

write_parquet(df_sisma, "Dataout/db_sisma.parquet")


dbDisconnect(con, shutdown = TRUE)
