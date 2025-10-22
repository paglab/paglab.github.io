#!/usr/bin/env Rscript

# Execute publication link replacements

library(stringr)

# Corrected link mappings
link_mappings <- list(
  "wang-drone-2025" = "wang-2024-unknown-drone",
  "wang-characterization-2025" = "wang-2022-unknown-characterization", 
  "song-highthroughput-2025-smartagriculturaltechnology" = "song-2025-sat-highthroughput",
  "yin-drone-2025" = "yin-2025-pr-drone",  # CORRECTED
  "yang-improving-2025-ijrs" = "yang-2025-ijrs-improving",  # CORRECTED
  "tang-ntri-2025" = "tang-2025-fcr-ntri",
  "gackstetter-self-attention-2025" = "gackstetter-2025-ijprs-selfattention",
  "lu-weed-2025" = "lu-2025-sat-weed",
  "zhang-meta-analysis-2024" = "zhang-2024-rs-metaanalysis"
)

cat("=== EXECUTING PUBLICATION LINK FIXES ===\n\n")

# Find all content files that might contain publication links
content_files <- list.files("content", pattern = "\\.md$", recursive = TRUE, full.names = TRUE)

# Track replacements
total_replacements <- 0
files_modified <- 0

for (file_path in content_files) {
  file_content <- readLines(file_path, warn = FALSE)
  original_content <- file_content
  file_modified <- FALSE
  
  for (old_link in names(link_mappings)) {
    new_link <- link_mappings[[old_link]]
    
    # Pattern 1: /publication/old-link)
    old_pattern1 <- paste0("/publication/", old_link, ")")
    new_replacement1 <- paste0("/publication/", new_link, "/)")
    file_content <- str_replace_all(file_content, fixed(old_pattern1), new_replacement1)
    
    # Pattern 2: /publication/old-link/
    old_pattern2 <- paste0("/publication/", old_link, "/")
    new_replacement2 <- paste0("/publication/", new_link, "/")
    file_content <- str_replace_all(file_content, fixed(old_pattern2), new_replacement2)
    
    # Pattern 3: publication/old-link (without leading slash)
    old_pattern3 <- paste0("publication/", old_link)
    new_replacement3 <- paste0("publication/", new_link, "/")
    file_content <- str_replace_all(file_content, fixed(old_pattern3), new_replacement3)
  }
  
  # Check if file was modified
  if (!identical(original_content, file_content)) {
    writeLines(file_content, file_path)
    cat("✅ Updated:", file_path, "\n")
    files_modified <- files_modified + 1
    
    # Count actual replacements made
    for (old_link in names(link_mappings)) {
      old_count <- str_count(paste(original_content, collapse = " "), fixed(old_link))
      new_count <- str_count(paste(file_content, collapse = " "), fixed(old_link))
      replacements_in_file <- old_count - new_count
      if (replacements_in_file > 0) {
        total_replacements <- total_replacements + replacements_in_file
        cat("  → Replaced", replacements_in_file, "instances of", old_link, "\n")
      }
    }
  }
}

cat("\n=== SUMMARY ===\n")
cat("Files checked:", length(content_files), "\n")
cat("Files modified:", files_modified, "\n")
cat("Total replacements:", total_replacements, "\n")

if (files_modified > 0) {
  cat("\n✅ Publication links successfully updated!\n")
  cat("Next steps:\n")
  cat("1. Run: blogdown::build_site()\n")
  cat("2. Test the updated links\n")
} else {
  cat("\n❌ No files were modified. Links may already be correct.\n")
}