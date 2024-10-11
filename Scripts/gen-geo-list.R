# PROJECT:
# AUTHOR:   J. Lara | USAID
# PURPOSE:
# REF ID:   b6ecd4ba
# LICENSE:  MIT
# DATE:     2024-09-23
# UPDATED:

# DEPENDENCIES ------------------------------------------------------------

library(tidyverse)
library(gagglr)
library(janitor)
library(glue)
library(googledrive)
library(googlesheets4)
library(sismar)
library(mozR)


# GLOBAL VARIABLES --------------------------------------------------------

ref_id <- "b6ecd4ba"

# LOAD DATA ------------------------------------------------------------------

df <- read_csv("Documents/us_sisma_clean.csv")

# MUNGE -------------------------------------------------------------------

# fetch misau_site_list geo
map_geo_us <- googlesheets4::read_sheet(googlesheets4::as_sheets_id("1cs8dC6OIFsjIJPIew3puPd1NkjGVeijz4jRnk3yiMR4"),
                                        sheet = "map_us_coord") |>
    dplyr::select(sisma_uid = organisationunitid,
                  latitude,
                  longitude) |>
    dplyr::filter(!is.na(latitude))


df1 <- df |>
  left_join(map_geo_us, by = "sisma_uid") |>
  select(sisma_uid, latitude, longitude) |>
  filter(!is.na(latitude) & !is.na(longitude))


write_csv(df1, "Documents/data_geo_us.csv",
          na = "")
