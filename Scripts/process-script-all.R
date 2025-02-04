# PROJECT:
# AUTHOR:   J. Lara | USAID
# PURPOSE:
# REF ID:   447e9ada
# LICENSE:  MIT
# DATE:     2024-09-20
# UPDATED: 2024-12-10

# DEPENDENCIES ------------------------------------------------------------

library(tidyverse)
library(sismar)
library(glue)
library(fs)
library(janitor)
library(mozR)
library(glamr)
library(openxlsx)
library(googledrive)
load_secrets()

# GLOBAL VARIABLES --------------------------------------------------------

ref_id <- "447e9ada"

# USER INPUT --------------------------------------------------------------

year <- "2024"

# INPUT/OUTPUT PATHS ------------------------------------------------------------

# define input file repo
path_repo_input <- "Data/sismar/"

# survey input files
path_inputs <- list.files(
  path_repo_input,
  pattern = glue("_{year}\\.csv$"),
  full.names = TRUE
)

# generate list of input files
list_inputs <-
  path_inputs |>
  set_names() |> # set names to match file input paths
  map(~ {
    safe_data <- possibly(read_csv, otherwise = NULL)(.x)
    if (!is.null(safe_data)) {
      safe_data |> mutate(
        repository_path = path_repo_input,
        file_size = file.info(.x)$size,
        modified_time = file.info(.x)$mtime
      )
    } else {
      warning(glue("Failed to read file: {.x}"))
      NULL
    }
  }
)


# interate process_sisma_export() over each file path input
processed_data <-
  list_inputs |>
  imap(~ {
    processed <- sismar::process_sisma_export(.y) # .y is for file path processing
    processed |> mutate(file_name = .y) # add variable for file name and path
  }) |>
  bind_rows() |>
  mutate(file_name = str_replace(file_name, "/sismar/", "/sismar/processed2/")) # modify file_name to output destination


# write processed files individually to disk
processed_data |>
  group_by(file_name) |>
  group_walk(~ {
    output_file <- str_replace(.y$file_name, "\\.csv$", ".txt")
    write_tsv(.x, file = output_file, na = "NA")
    message(glue("File written: {output_file}"))
  })


# GENERATE HISTORICAL FROM YEARLY -----------------------------------------

historical_sisma <-
  list.files("Data/sismar/processed2/", full.names = TRUE) %>%
  map(~ read_tsv(.x)) %>%
  reduce(rbind)

# WRITE HISTORICAL TO DISK ------------------------------------------------

write_tsv(
  historical_sisma,
  "Dataout/db_sisma.txt",
  na = ""
)
