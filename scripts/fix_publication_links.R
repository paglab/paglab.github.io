#!/usr/bin/env Rscript

# Fix broken publication links after folder renaming

library(stringr)

# List of broken links found in content
broken_links <- c(
  "wang-drone-2025",
  "wang-characterization-2025", 
  "song-highthroughput-2025-smartagriculturaltechnology",
  "yin-drone-2025",
  "yang-improving-2025-ijrs",
  "tang-ntri-2025",
  "gackstetter-self-attention-2025",
  "lu-weed-2025",
  "zhang-meta-analysis-2024"
)

# Get current publication folder names
current_folders <- list.dirs("content/publication", full.names = FALSE, recursive = FALSE)
current_folders <- current_folders[current_folders != ""]

cat("=== FIXING PUBLICATION LINKS ===\n\n")
cat("Found", length(current_folders), "publication folders\n")
cat("Need to fix", length(broken_links), "broken links\n\n")

# Function to find the best match for a broken link
find_matching_folder <- function(broken_link, folders) {
  # Extract key components from broken link
  parts <- str_split(broken_link, "-")[[1]]
  
  # Look for folders that contain similar components
  matches <- c()
  
  for (folder in folders) {
    folder_parts <- str_split(folder, "-")[[1]]
    
    # Count matching components
    match_count <- sum(parts %in% folder_parts)
    
    if (match_count >= 2) {  # At least 2 components match
      matches <- c(matches, folder)
    }
  }
  
  # If multiple matches, prefer the one with more matching components
  if (length(matches) > 0) {
    best_match <- matches[1]  # Take first match for now
    return(best_match)
  }
  
  return(NULL)
}

# Find mappings
link_mappings <- list()

for (broken_link in broken_links) {
  match <- find_matching_folder(broken_link, current_folders)
  if (!is.null(match)) {
    link_mappings[[broken_link]] <- match
    cat("✅", broken_link, "->", match, "\n")
  } else {
    cat("❌", broken_link, "-> NO MATCH FOUND\n")
  }
}

cat("\n=== LINK MAPPINGS ===\n")
for (old_link in names(link_mappings)) {
  new_link <- link_mappings[[old_link]]
  cat(sprintf("'%s' -> '%s'\n", old_link, new_link))
}

# Save mappings for use in replacement script
saveRDS(link_mappings, "scripts/link_mappings.rds")

cat("\n✅ Mappings saved to scripts/link_mappings.rds\n")
cat("Next: Run replacement script to update all files\n")