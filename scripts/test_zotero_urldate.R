#!/usr/bin/env Rscript

# Test with actual Zotero BibTeX data
library(RefManageR)
library(lubridate)

# Helper function
`%||%` <- function(x, y) if (!is.null(x) && !is.na(x)) x else y

# Improved parse_date function (corrected version)
parse_date <- function(entry) {
  # Handle Zotero's separate year and month fields
  year_val <- entry$year %||% NA_character_
  month_val <- entry$month %||% NA_character_
  date_val <- entry$date %||% NA_character_
  # Note: urldate is the access date, NOT publication date - we ignore it for publication metadata
  
  # Priority order: date field, then year+month, then year only
  # We explicitly exclude urldate as it's the access date, not publication date
  if (!is.na(date_val) && date_val != "") {
    # Use existing date field if available
    date_str <- as.character(date_val)
  } else if (!is.na(year_val) && !is.na(month_val)) {
    # Combine year and month from Zotero export
    year_str <- as.character(year_val)
    month_str <- as.character(month_val)
    
    # Convert month name/abbreviation to number
    month_num <- tryCatch({
      if (nchar(month_str) <= 3) {
        # Handle abbreviated month names (jan, feb, etc.)
        month_abbrevs <- c("jan"=1, "feb"=2, "mar"=3, "apr"=4, "may"=5, "jun"=6,
                          "jul"=7, "aug"=8, "sep"=9, "oct"=10, "nov"=11, "dec"=12)
        month_abbrevs[[tolower(month_str)]] %||% 1
      } else {
        # Handle full month names
        month_names <- c("january"=1, "february"=2, "march"=3, "april"=4, "may"=5, "june"=6,
                        "july"=7, "august"=8, "september"=9, "october"=10, "november"=11, "december"=12)
        month_names[[tolower(month_str)]] %||% 1
      }
    }, error = function(e) 1)
    
    if (is.null(month_num)) month_num <- 1
    
    # Create precise date string: year-month-01 (first day of month)
    date_str <- sprintf("%s-%02d-01", year_str, month_num)
  } else if (!is.na(year_val)) {
    # Year only
    date_str <- paste0(as.character(year_val), "-01-01")
  } else {
    # Fallback to current date
    return(format(Sys.Date(), "%Y-%m-%d"))
  }
  
  # Parse the constructed date string
  parsed_date <- tryCatch({
    if (nchar(date_str) == 4L) {
      # Just year: YYYY
      lubridate::ymd(paste0(date_str, "-01-01"), quiet = TRUE)
    } else if (nchar(date_str) == 7L) {
      # Year-month: YYYY-MM
      lubridate::ymd(paste0(date_str, "-01"), quiet = TRUE)
    } else {
      # Full date: YYYY-MM-DD
      lubridate::ymd(date_str, quiet = TRUE)
    }
  }, error = function(e) Sys.Date())
  
  if (is.na(parsed_date)) {
    return(format(Sys.Date(), "%Y-%m-%d"))
  } else {
    return(format(parsed_date, "%Y-%m-%d"))
  }
}

cat("=== TESTING WITH YOUR ACTUAL ZOTERO BIBTEX DATA ===\n\n")

# Test with simulated entries based on your BibTeX file
test_entries <- list(
  # Entry 1: yang_deepspecn_2025 (oct 2025)
  list(
    name = "Yang DeepSpecN 2025",
    year = "2025",
    month = "oct",
    urldate = "2025-10-12",  # This should be ignored
    expected = "2025-10-01"
  ),
  
  # Entry 2: yu_uav_2025 (dec 2025)  
  list(
    name = "Yu UAV 2025",
    year = "2025", 
    month = "dec",
    urldate = "2025-10-12",  # This should be ignored
    expected = "2025-12-01"
  )
)

# Run tests
for (i in seq_along(test_entries)) {
  test <- test_entries[[i]]
  cat("Test", i, ":", test$name, "\n")
  
  result <- parse_date(test)
  cat("  Input: year=", test$year, ", month=", test$month, ", urldate=", test$urldate, "\n")
  cat("  Result:  ", result, "\n")
  cat("  Expected:", test$expected, "\n")
  
  if (result == test$expected) {
    cat("  ✅ SUCCESS - Correctly ignored urldate, used year+month\n")
  } else {
    cat("  ❌ MISMATCH\n")
  }
  cat("\n")
}

cat("=== KEY POINTS ABOUT URLDATE ===\n")
cat("📅 urldate = {2025-10-12} is the ACCESS DATE (when you downloaded from Zotero)\n")
cat("📅 year + month = publication date (when the article was actually published)\n")
cat("✅ Our improved parser correctly:\n")
cat("   - Uses year + month for publication date\n")
cat("   - Ignores urldate (access date)\n")
cat("   - Creates precise dates: YYYY-MM-01 format\n")
cat("   - Handles month abbreviations (oct → 10, dec → 12)\n\n")

cat("🔧 To use this with your Zotero exports:\n")
cat("1. Export from Zotero with year + month fields\n")
cat("2. The script will automatically create: 2025-10-01, 2025-12-01, etc.\n")
cat("3. urldate will be correctly ignored\n")