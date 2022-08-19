# Download PubMed records for publications


# csv of publications from the neuro
# downloaded from https://www.dropbox.com/s/lxjsihhzys7h6r7/cleaned_y2021_oa_info_109.csv?dl=0
# manually added to repository
publications <- readr::read_csv(here::here("data", "raw", "neuro-validated-pubs.csv"))

source(here::here("R", "functions", "download_pubmed.R"))

dir <- fs::dir_create(here::here("data", "raw", "pubmed"))

pmids <-
  publications |>
  tidyr::drop_na(pmid) |>
  dplyr::distinct(pmid) |>
  dplyr::pull()

# If pmids already downloaded, remove those from list to download
if (fs::dir_exists(dir)){

  pmids_downloaded <-
    fs::dir_ls(dir) |>
    fs::path_file() |>
    fs::path_ext_remove() |>
    as.numeric()

  # Check whether pmids downloaded which aren't needed and manually review and remove
  pmids_downloaded_unused <- setdiff(pmids_downloaded, pmids)
  if (length(pmids_downloaded_unused) > 0) {
    rlang::warn(glue::glue("Unused pmid downloaded: {pmids_downloaded_unused}"))
  }

  pmids <- setdiff(pmids, pmids_downloaded)
}

# Download remaining pmids, if any
if (length(pmids) > 0) {

  # Use pubmed api key locally stored as "ncbi-pubmed", if available
  # Else ask user and store
  pubmed_api_key <-
    ifelse(
      nrow(keyring::key_list("ncbi-pubmed")) == 1,
      keyring::key_get("ncbi-pubmed"),
      keyring::key_set("ncbi-pubmed")
    )

  pmids |>
    purrr::walk(download_pubmed,
                dir = dir,
                api_key = pubmed_api_key
    )

  # Log query date
  loggit::set_logfile(here::here("queries.log"))
  loggit::loggit("INFO", "PubMed")
}
