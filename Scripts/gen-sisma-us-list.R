# PROJECT:
# AUTHOR:   J. Lara | USAID
# PURPOSE:
# REF ID:   f861b309
# LICENSE:  MIT
# DATE:     2024-09-19
# UPDATED:

# DEPENDENCIES ------------------------------------------------------------


# GLOBAL VARIABLES --------------------------------------------------------

ref_id <- "f861b309"

# LOAD DATA ------------------------------------------------------------------

df <- read_csv("Documents/us_sisma.csv")

# MUNGE ---------------------------------------------------------------------


df_clean <- df |>
  select(sisma_uid = organisationunitid,
         site_nid = organisationunitcode,
         provincia = orgunitlevel2,
         distrito = orgunitlevel3,
         us = orgunitlevel4) |>
  distinct(.keep_all = TRUE) |>
  arrange(provincia, distrito, us) |>
  filter(distrito != "DISTRITO DE XAI-XAI (EXTINTO)") |>
  mutate(across(c(provincia, distrito, us), ~ stringr::str_to_title(.)),
        us = case_when(
      sisma_uid == "abg5UReivZX" ~ "Privado Dream Comunidade Santo Egidio Zimpeto", # abg5UReivZX has a tab in it which interferes with datapasta tribble
      .default = us)
  )


# EXPORT --------------------------------------------------------------------

write_csv(df_clean, "Documents/us_sisma_clean.csv")
