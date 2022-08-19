# Extract trial registration numbers (TRN) from PubMed secondary identifier & PubMed abstract


library(dplyr)

# renv::install("maia-sh/ctregistries")
library(ctregistries)
# renv::install("maia-sh/tidypubmed")
library(tidypubmed)

source(here::here("R", "functions", "extract_pubmed.R"))

publications <- readr::read_csv(here::here("data", "raw", "neuro-validated-pubs.csv"))

# Prepare directory paths
dir_pubmed <- fs::dir_create(here::here("data", "processed", "pubmed"))
dir_trn <- fs::dir_create(here::here("data", "processed", "trn"))

# Get filepaths to all pubmed xmls
pubmed_xmls <- fs::dir_ls(here::here("data", "raw", "pubmed"))


# Secondary identifier ----------------------------------------------------

# Extract secondary ids from pubmed, and find trn and registry
si <-
  pubmed_xmls |>
  purrr::map_dfr(extract_pubmed, datatype = "databanks", quiet = FALSE) |>
  ctregistries::mutate_trn_registry(accession_number)

readr::write_csv(si, fs::path(dir_pubmed, "pubmed-si.csv"))
# si <- readr::read_csv(fs::path(dir_pubmed, "pubmed-si.csv"))


# Visually inspect any mismatching trns and non-registry secondary ids
# 2 non-registry secondary ids
si_trn_mismatches <-
  si |>
  filter(!accession_number %in% trn |
           is.na(trn) |
           !databank %in% registry)


# Tidy trns in secondary ids
trn_si <-
  si |>

  # Remove non-registry secondary ids
  tidyr::drop_na(trn) |>
  select(pmid, registry, trn_detected = trn) |>
  distinct() |>

  # Get number of trn per publication
  group_by(pmid) |>
  mutate(n_detected = row_number()) |>
  ungroup() |>

  # Clean trn
  mutate(
    source = "secondary_id",
    trn_cleaned = purrr::map_chr(trn_detected, ctregistries::clean_trn)
  )

readr::write_csv(trn_si, fs::path(dir_trn, "trn-si.csv"))
# trn_si <- readr::read_csv(fs::path(dir_trn, "trn-si.csv"))

# Abstract ----------------------------------------------------------------

# Extract abstracts from pubmed, and find trn and registry
abs <-
  pubmed_xmls |>
  purrr::map_dfr(extract_pubmed, datatype = "abstract", quiet = FALSE) |>
  ctregistries::mutate_trn_registry(abstract)

readr::write_csv(abs, fs::path(dir_pubmed, "pubmed-abstract.csv"))
# abs <- readr::read_csv(fs::path(dir_pubmed, "pubmed-abstract.csv"))

trn_abs <-
  abs |>
  tidyr::drop_na(trn) |>
  distinct(pmid, registry, trn_detected = trn) |>
  group_by(pmid) |>
  mutate(n_detected = row_number()) |>
  ungroup() |>
  mutate(
    source = "abstract",
    trn_cleaned = purrr::map_chr(trn_detected, ctregistries::clean_trn)
  )

readr::write_csv(trn_abs, fs::path(dir_trn, "trn-abstract.csv"))
# trn_abs <- readr::read_csv(fs::path(dir_trn, "trn-abstract.csv"))


# Combine reported TRNs (secondary id & abstract) -------------------------

trn_combined <-
  bind_rows(trn_si, trn_abs) |>

  distinct(pmid, trn = trn_cleaned, registry, source) |>

  # All records should have a trn
  assertr::assert(assertr::not_na, trn) |>

  # Pivot wider to for one row per TRN with sources as columns
  mutate(value = TRUE) |>
  tidyr::pivot_wider(
    names_from = source, names_prefix = "has_trn_",
    values_from = value, values_fill = FALSE
  )

readr::write_csv(trn_combined, fs::path(dir_trn, "trn-combined.csv"))
# trn_combined <- readr::read_csv(fs::path(dir_trn, "trn-combined.csv"))
