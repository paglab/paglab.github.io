#!/usr/bin/env Rscript

# Test the updated add_publications.R script
source("scripts/add_publications.R")

# Test the slug generation function with sample data
test_entry <- list(
  author = "Yang, Haibo and Smith, John",
  title = "Improving Potato Nitrogen Content Estimation Using UAV",
  journal = "International Journal of Remote Sensing", 
  year = "2025",
  bibtype = "article"
)

# Convert to a structure similar to RefManageR
class(test_entry) <- "BibEntry"

cat("=== TESTING UPDATED add_publications.R ===\n\n")

# Test slug generation
slug <- sanitize_slug(test_entry, "test-key")
cat("Generated slug:", slug, "\n")

# Test journal acronym
acronym <- journal_acronym("International Journal of Remote Sensing")
cat("Journal acronym:", acronym, "\n")

# Expected format: familyname-year-journalacronym-titlekeyword
cat("\nExpected pattern: yang-2025-ijrs-improving\n")
cat("Generated slug:   ", slug, "\n")

if (slug == "yang-2025-ijrs-improving") {
  cat("✅ SUCCESS: Slug generation matches new standard!\n")
} else {
  cat("❌ MISMATCH: Slug does not match expected format\n")
}