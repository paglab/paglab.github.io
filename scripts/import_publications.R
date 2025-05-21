#!/usr/bin/env Rscript
# scripts/import_publications.R

# Load required packages
suppressPackageStartupMessages({
  required_packages <- c("RefManageR", "yaml", "stringi", "lubridate", "purrr", "glue", "dplyr", "tools")
  for (pkg in required_packages) {
    if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
      install.packages(pkg)
      library(pkg, character.only = TRUE)
    }
  }
})

# ---- Configuration ----
config <- list(
  bib_file = "paglab.data/Exported Items.bib",
  output_dir = "content/publication",
  citation_style = "apa",
  max_slug_length = 50L,
  validate_urls = TRUE,
  preserve_caps = FALSE
)

# ---- Helper Functions ----
`%||%` <- function(x, y) if (!is.null(x) && !is.na(x)) x else y

clean_title <- function(title) {
  if (is.null(title) || is.na(title)) return("")
  title <- gsub("[{}]", "", title)
  if (!config$preserve_caps && grepl("^[A-Z\\s\\d\\p{P}]+$", title, perl = TRUE)) {
    title <- tools::toTitleCase(tolower(title))
  }
  trimws(title)
}

clean_url <- function(url) {
  if (is.null(url) || is.na(url) || url == "") return("")
  if (config$validate_urls) {
    url <- gsub("^https?://|/$", "", url, ignore.case = TRUE)
    url <- gsub("[?#].*$", "", url)
  }
  url
}

parse_date <- function(entry) {
  date_str <- entry$date %||% entry$year %||% NA_character_
  if (is.na(date_str)) return(format(Sys.Date(), "%Y-%m-%d"))
  parsed_date <- tryCatch({
    if (nchar(date_str) == 4L) {
      lubridate::ymd(paste0(date_str, "-01-01"), quiet = TRUE)
    } else if (nchar(date_str) == 7L) {
      lubridate::ymd(paste0(date_str, "-01"), quiet = TRUE)
    } else {
      lubridate::ymd(date_str, quiet = TRUE)
    }
  }, error = function(e) Sys.Date())
  if (is.na(parsed_date)) Sys.Date() else format(parsed_date, "%Y-%m-%d")
}

generate_citation <- function(entry) {
  auths <- tryCatch(as.character(entry$author), error = function(e) "Unknown author")
  if (length(auths) > 2L) {
    authors <- paste0(paste(auths[-length(auths)], collapse = ", "), ", & ", auths[length(auths)])
  } else if (length(auths) == 2L) {
    authors <- paste(auths, collapse = " & ")
  } else {
    authors <- auths
  }
  title <- clean_title(entry$title %||% "Untitled")
  journal <- entry$journal %||% entry$booktitle %||% ""
  year <- substr(parse_date(entry), 1L, 4L)
  if (config$citation_style == "apa") {
    citation <- glue::glue("{authors} ({year}). {title}. *{journal}*",
                           if (!is.null(entry$volume)) glue::glue(", {entry$volume}") else "",
                           if (!is.null(entry$number)) glue::glue("({entry$number})") else "",
                           if (!is.null(entry$pages)) glue::glue(": {entry$pages}") else "",
                           ".")
  } else {
    citation <- glue::glue("{title} ({year})")
  }
  as.character(citation)
}

journal_acronym <- function(journal_name) {
  if (is.null(journal_name) || is.na(journal_name) || journal_name == "") return("unknown")
  acronym <- gsub("[^A-Za-z]", "", journal_name)
  acronym <- tolower(acronym)
  known <- list(
    "internationaljournalofremotesensing" = "ijrs",
    "remotesensing" = "rs",
    "precisionagriculture" = "pa",
    "computerelectronicsinagriculture" = "cea"
  )
  return(known[[acronym]] %||% acronym)
}

sanitize_slug <- function(entry, key_fallback) {
  first_author <- tryCatch({
    author_str <- as.character(entry$author)[1]
    if (grepl(",", author_str)) {
      last <- trimws(strsplit(author_str, ",")[[1]][1])
    } else {
      name_parts <- strsplit(author_str, "\\s+")[[1]]
      last <- name_parts[[length(name_parts)]]
    }
    tolower(iconv(last, from = "", to = "ASCII//TRANSLIT"))
  }, error = function(e) "unknown")
  
  year <- substr(parse_date(entry), 1L, 4L)
  journal <- entry$journal %||% entry$booktitle %||% ""
  acronym <- journal_acronym(journal)
  
  title_part <- clean_title(entry$title %||% "untitled")
  title_first_word <- tolower(gsub("[^[:alnum:]]", "", strsplit(title_part, " ")[[1]][1]))
  
  slug <- paste(first_author, title_first_word, year, acronym, sep = "-")
  slug <- gsub("-+", "-", slug)
  slug
}

map_publication_type <- function(bibtype) {
  type_mapping <- list(
    "0" = list(code = "0", label = "Other"),
    "1" = list(code = "1", label = "Conference Papers"),
    "2" = list(code = "2", label = "Journal Articles"),
    "3" = list(code = "3", label = "Preprints"),
    "4" = list(code = "4", label = "Theses"),
    "5" = list(code = "5", label = "Books"),
    "6" = list(code = "6", label = "Book Sections")
  )
  if (is.null(bibtype) || bibtype == "~") return(type_mapping[["2"]])
  type <- tolower(as.character(bibtype))
  result <- case_when(
    type %in% c("article", "journal") ~ "2",
    type %in% c("inproceedings", "conference") ~ "1",
    type %in% c("book", "booklet") ~ "5",
    type %in% c("incollection", "inbook") ~ "6",
    type %in% c("preprint", "unpublished") ~ "3",
    type %in% c("phdthesis", "mastersthesis") ~ "4",
    TRUE ~ "0"
  )
  type_mapping[[result]]
}

validate_entry <- function(entry) {
  if (!is.null(entry$doi)) entry$url <- ""
  if (!is.null(entry$url)) entry$url <- clean_url(entry$url)
  if (!is.null(entry$title)) entry$title <- clean_title(entry$title)
  entry
}

# ---- Main Execution ----
main <- function() {
  bib <- tryCatch(
    RefManageR::ReadBib(config$bib_file, check = FALSE),
    error = function(e) stop("Failed to read BibTeX file: ", e$message)
  )
  if (length(bib) == 0L) {
    message("No publications found in the BibTeX file")
    return(invisible(FALSE))
  }
  results <- purrr::map(names(bib), function(key) {
    entry <- tryCatch(validate_entry(bib[[key]]), error = function(e) {
      warning("Skipping invalid entry '", key, "': ", e$message)
      return(list(success = FALSE, key = key))
    })
    if (is.null(entry)) return(list(success = FALSE, key = key))
    slug <- sanitize_slug(entry, key)
    dir <- file.path(config$output_dir, slug)
    tryCatch({
      if (!dir.exists(dir)) {
        dir.create(dir, recursive = TRUE, showWarnings = FALSE)
      }
      metadata <- list(
        title = entry$title %||% "",
        date = parse_date(entry),
        publication_types = list(map_publication_type(entry$bibtype)$code),
        authors = tryCatch(as.character(entry$author), error = function(e) "Unknown"),
        publication = entry$journal %||% entry$booktitle %||% "",
        doi = entry$doi %||% "",
        url = entry$url %||% "",
        abstract = entry$abstract %||% ""
      )
      index_file <- file.path(dir, "index.md")
      if (file.exists(index_file)) {
        message("Skipping existing publication: ", slug)
        return(list(success = TRUE, key = key))
      }
      writeLines(
        c("---", yaml::as.yaml(metadata), "---", "", generate_citation(entry)),
        file.path(dir, "index.md")
      )
      list(success = TRUE, key = key)
    }, error = function(e) {
      warning("Failed to process '", key, "': ", e$message)
      list(success = FALSE, key = key)
    })
  })
  success_count <- sum(purrr::map_lgl(results, "success"))
  failure_count <- length(results) - success_count
  message("\nProcessing complete:",
          "\n- Success: ", success_count,
          "\n- Failed:  ", failure_count)
  if (failure_count > 0L) {
    failed_keys <- purrr::map_chr(keep(results, ~ !.x$success), "key")
    message("\nFailed entries:\n", paste("- ", failed_keys, collapse = "\n"))
  }
  invisible(success_count)
}

if (!interactive()) {
  main()
}
