#!/usr/bin/env Rscript

# Execute the publication folder renaming
# This script actually performs the folder renames

library(stringr)

cat("=== EXECUTING PUBLICATION FOLDER RENAMING ===\n\n")

# Load the rename plan
if (!file.exists("scripts/rename_plan.rds")) {
  cat("❌ Error: rename_plan.rds not found. Run scripts/rename_publications.R first.\n")
  quit(status = 1)
}

rename_plan <- readRDS("scripts/rename_plan.rds")

# Filter to only folders that need renaming
changes_needed <- rename_plan$old_name != rename_plan$new_name
folders_to_rename <- rename_plan[changes_needed, ]

if (nrow(folders_to_rename) == 0) {
  cat("✅ No folders need renaming. All names are already standardized.\n")
  quit(status = 0)
}

cat("About to rename", nrow(folders_to_rename), "folders:\n\n")

for (i in 1:nrow(folders_to_rename)) {
  old_path <- file.path("content/publication", folders_to_rename$old_name[i])
  new_path <- file.path("content/publication", folders_to_rename$new_name[i])
  
  cat(sprintf("%d/%d: %s -> %s\n", 
              i, nrow(folders_to_rename),
              folders_to_rename$old_name[i], 
              folders_to_rename$new_name[i]))
}

# Ask for confirmation
cat("\nProceed with renaming? (y/N): ")
response <- readLines("stdin", n = 1)

if (tolower(response) != "y") {
  cat("❌ Renaming cancelled.\n")
  quit(status = 0)
}

# Perform the renaming
cat("\n🔄 Starting renaming process...\n\n")

errors <- 0
for (i in 1:nrow(folders_to_rename)) {
  old_path <- file.path("content/publication", folders_to_rename$old_name[i])
  new_path <- file.path("content/publication", folders_to_rename$new_name[i])
  
  # Check if source exists
  if (!dir.exists(old_path)) {
    cat("❌ Error: Source folder does not exist:", old_path, "\n")
    errors <- errors + 1
    next
  }
  
  # Check if destination already exists
  if (dir.exists(new_path)) {
    cat("❌ Error: Destination folder already exists:", new_path, "\n")
    errors <- errors + 1
    next
  }
  
  # Perform the rename
  success <- file.rename(old_path, new_path)
  
  if (success) {
    cat("✅", folders_to_rename$old_name[i], "->", folders_to_rename$new_name[i], "\n")
  } else {
    cat("❌ Error renaming:", folders_to_rename$old_name[i], "\n")
    errors <- errors + 1
  }
}

cat("\n=== RENAMING COMPLETE ===\n")
cat("Successfully renamed:", nrow(folders_to_rename) - errors, "folders\n")
cat("Errors:", errors, "\n")

if (errors == 0) {
  cat("\n✅ All folders successfully renamed!\n")
  cat("Next steps:\n")
  cat("1. Run: blogdown::build_site()\n")
  cat("2. Test the site locally\n")
  cat("3. Commit the changes\n")
  
  # Clean up
  file.remove("scripts/rename_plan.rds")
  cat("\nCleanup: Removed rename_plan.rds\n")
} else {
  cat("\n⚠️  Some errors occurred. Please review and fix manually.\n")
}