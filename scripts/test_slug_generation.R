#!/usr/bin/env Rscript

# Test just the key functions from add_publications.R

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

# Copy the key functions we want to test
`%||%` <- function(x, y) if (!is.null(x) && !is.na(x)) x else y

clean_title <- function(title) {
  if (is.null(title) || is.na(title)) return("")
  title <- gsub("[{}]", "", title)
  title <- tools::toTitleCase(tolower(title))
  trimws(title)
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

journal_acronym <- function(journal_name) {
  if (is.null(journal_name) || is.na(journal_name) || journal_name == "") return("unknown")
  
  # Normalize journal name
  normalized <- tolower(gsub("[^a-zA-Z]", "", journal_name))
  
  # Journal mapping
  journal_map <- list(
    "internationaljournalofremotesensing" = "ijrs",
    "remotesensing" = "rs",
    "precisionagriculture" = "pa",
    "computerelectronicsinagriculture" = "cea"
  )
  
  # Return mapped acronym or create one
  mapped <- journal_map[[normalized]]
  if (!is.null(mapped)) {
    return(mapped)
  }
  
  return("unknown")
}

sanitize_slug <- function(entry, key_fallback) {
  # Extract family name (last name) from first author
  first_author <- tryCatch({
    author_str <- as.character(entry$author)[1]
    if (grepl(",", author_str)) {
      # Format: "Last, First" - take the last name
      family_name <- trimws(strsplit(author_str, ",")[[1]][1])
    } else {
      # Format: "First Last" - take the last word
      name_parts <- strsplit(author_str, "\\s+")[[1]]
      family_name <- name_parts[[length(name_parts)]]
    }
    tolower(iconv(family_name, from = "", to = "ASCII//TRANSLIT"))
  }, error = function(e) "unknown")
  
  # Extract year
  year <- substr(parse_date(entry), 1L, 4L)
  
  # Extract journal acronym
  journal <- entry$journal %||% entry$booktitle %||% ""
  acronym <- journal_acronym(journal)
  
  # Extract title keyword (first meaningful word)
  title_part <- clean_title(entry$title %||% "untitled")
  title_words <- strsplit(tolower(title_part), "\\s+")[[1]]
  # Remove common words
  title_words <- title_words[!title_words %in% c("a", "an", "the", "of", "and", "in", "for", "on", "with", "by", "using", "based", "via")]
  title_keyword <- gsub("[^[:alnum:]]", "", title_words[1])
  
  # Generate slug: familyname-year-journalacronym-titlekeyword
  slug <- paste(first_author, year, acronym, title_keyword, sep = "-")
  slug <- gsub("-+", "-", slug)
  slug
}

# Test the slug generation function
cat("=== TESTING UPDATED add_publications.R FUNCTIONS ===\n\n")

# Test cases
test_cases <- list(
  list(
    author = "Yang, Haibo",
    title = "Improving Potato Nitrogen Content Estimation",
    journal = "International Journal of Remote Sensing",
    year = "2025",
    expected = "yang-2025-ijrs-improving"
  ),
  list(
    author = "John Smith",
    title = "UAV Based Remote Sensing Applications",
    journal = "Remote Sensing",
    year = "2024",
    expected = "smith-2024-rs-uav"
  )
)

for (i in seq_along(test_cases)) {
  test <- test_cases[[i]]
  cat("Test", i, ":\n")
  
  slug <- sanitize_slug(test, "test-key")
  cat("  Generated:", slug, "\n")
  cat("  Expected: ", test$expected, "\n")
  
  if (slug == test$expected) {
    cat("  ✅ SUCCESS\n")
  } else {
    cat("  ❌ MISMATCH\n")
  }
  cat("\n")
}