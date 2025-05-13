#!/usr/bin/env Rscript
# scripts/import_publications.R
# Final debugged version with title formatting fixes

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
  bib_file = "my_publications.bib",
  output_dir = "content/publication",
  citation_style = "apa",
  max_slug_length = 50L,
  validate_urls = TRUE,
  preserve_caps = FALSE  # Set TRUE to keep ALL-CAPS titles as-is
)

# ---- Helper Functions ----
`%||%` <- function(x, y) if (!is.null(x) && !is.na(x)) x else y

clean_title <- function(title) {
  if (is.null(title) || is.na(title)) return("")
  
  # Remove ALL curly braces but preserve content
  title <- gsub("[{}]", "", title)
  
  # Conditionally convert ALL-CAPS to Title Case
  if (!config$preserve_caps && grepl("^[A-Z\\s\\d\\p{P}]+$", title, perl = TRUE)) {
    title <- tools::toTitleCase(tolower(title))
  }
  
  # Clean residual whitespace
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
  auths <- tryCatch(
    as.character(entry$author),
    error = function(e) "Unknown author"
  )
  
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
    citation <- glue::glue(
      "{authors} ({year}). {title}. *{journal}*",
      if (!is.null(entry$volume)) glue::glue(", {entry$volume}") else "",
      if (!is.null(entry$number)) glue::glue("({entry$number})") else "",
      if (!is.null(entry$pages)) glue::glue(": {entry$pages}") else "",
      "."
    )
  } else {
    citation <- glue::glue("{title} ({year})")
  }
  as.character(citation)
}

sanitize_slug <- function(key) {
  if (is.null(key) || is.na(key)) key <- "untitled"
  slug <- tolower(gsub("[^[:alnum:]]+", "-", key))
  if (nchar(slug) > config$max_slug_length) {
    slug <- substr(slug, 1L, config$max_slug_length)
    slug <- sub("-$", "", slug)
  }
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
  
  if (is.null(bibtype) || bibtype == "~") return(type_mapping[["2"]]) # Default to journal
  
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
    error = function(e) {
      stop("Failed to read BibTeX file: ", e$message)
    }
  )
  
  if (length(bib) == 0L) {
    message("No publications found in the BibTeX file")
    return(invisible(FALSE))
  }
  
  results <- purrr::map(names(bib), function(key) {
    entry <- tryCatch(
      validate_entry(bib[[key]]),
      error = function(e) {
        warning("Skipping invalid entry '", key, "': ", e$message)
        return(list(success = FALSE, key = key))
      }
    )
    
    if (is.null(entry)) return(list(success = FALSE, key = key))
    
    slug <- sanitize_slug(entry$key %||% key)
    dir <- file.path(config$output_dir, slug)
    
    tryCatch({
      if (!dir.exists(dir)) {
        dir.create(dir, recursive = TRUE, showWarnings = FALSE)
      }
      
      # Process keywords → tags
      tags <- entry$keywords %||% NULL
      if (!is.null(tags)) {
        tags <- unlist(strsplit(tags, "[;,]"))
        tags <- trimws(tags)
      }
      
      # Process authors
      authors <- tryCatch(as.character(entry$author), error = function(e) "Unknown")
      
      # Optional logic to auto-assign project
      project <- if (grepl("wheat|maize|phenotyping", tolower(entry$title %||% ""), fixed = TRUE)) {
        list("crop-monitoring")
      } else {
        list()
      }
      
      
      
      metadata <- list(
        title = entry$title %||% "",
        date = parse_date(entry),
        publication_types = list(map_publication_type(entry$bibtype)$code),
        authors = authors,
        publication = entry$journal %||% entry$booktitle %||% "",
        doi = entry$doi %||% "",
        url = entry$url %||% "",
        abstract = entry$abstract %||% "",
        featured = FALSE,                    # Or set to TRUE for specific criteria
        projects = project,
        tags = tags
      )
      
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

# Execute only when run as a script
if (!interactive()) {
  main()
}