#!/usr/bin/env Rscript

# Publication Folder Name Standardization Script
# Convention: authorfamilyname-year-journal-acronym
# If duplicates: add first word of title, then second word, etc.

library(stringr)
library(dplyr)

# Journal acronym mapping (add more as needed)
journal_acronyms <- list(
  "Remote Sensing of Environment" = "RSE",
  "Remote Sensing Applications Society and Environment" = "RSASE", 
  "International Journal of Applied Earth Observation and Geoinformation" = "IJAEOG",
  "ISPRS Journal of Photogrammetry and Remote Sensing" = "IJPRS",
  "International Journal of Remote Sensing" = "IJRS",
  "Smart Agricultural Technology" = "SAT",
  "Computers and Electronics in Agriculture" = "CEA",
  "Field Crops Research" = "FCR",
  "European Journal of Agronomy" = "EJA",
  "European Journal of Soil Science" = "EJSS",
  "Precision Agriculture" = "PA",
  "Plant Phenomics" = "PP",
  "Potato Research" = "PR",
  "Agriculture" = "AGR",
  "Annals of Botany" = "AOB",
  "Agroforestry Systems" = "AFS",
  "GigaScience" = "GS",
  "Landscape and Urban Planning" = "LUP",
  "IEEE Journal of Selected Topics in Applied Earth Observations and Remote Sensing" = "JSTARS",
  "IEEE Transactions on Geoscience and Remote Sensing" = "TGRS",
  "Remote Sensing" = "RS"
)

# Function to get journal acronym
get_journal_acronym <- function(journal_full_name) {
  # Clean the journal name
  journal_clean <- str_trim(journal_full_name)
  
  # Check if we have a mapping
  if (journal_clean %in% names(journal_acronyms)) {
    return(journal_acronyms[[journal_clean]])
  }
  
  # If no mapping, create one from first letters of major words
  words <- str_split(journal_clean, "\\s+")[[1]]
  words <- words[!words %in% c("of", "and", "in", "the", "for", "on", "&")]
  acronym <- paste(str_sub(words, 1, 1), collapse = "")
  return(toupper(acronym))
}

# Function to generate standardized folder name
generate_folder_name <- function(authors, year, journal, title, existing_names = c()) {
  # Get first author's last name
  first_author <- str_trim(str_split(authors[1], ",")[[1]][1])
  first_author <- str_to_lower(str_replace_all(first_author, "[^a-zA-Z]", ""))
  
  # Get journal acronym
  journal_acronym <- str_to_lower(get_journal_acronym(journal))
  
  # Get first meaningful word from title
  title_words <- str_split(str_to_lower(title), "\\s+")[[1]]
  title_words <- title_words[!title_words %in% c("a", "an", "the", "of", "and", "in", "for", "on", "with", "by", "using", "based")]
  title_words <- str_replace_all(title_words, "[^a-zA-Z]", "")
  title_words <- title_words[nchar(title_words) > 2]  # Remove very short words
  
  if (length(title_words) == 0) {
    title_keyword <- "paper"
  } else {
    title_keyword <- title_words[1]
  }
  
  # Standard pattern: author-year-journal-keyword
  base_name <- paste(first_author, year, journal_acronym, title_keyword, sep = "-")
  
  # Check if this name already exists
  if (!base_name %in% existing_names) {
    return(base_name)
  }
  
  # If duplicate, try with additional title words
  for (i in 2:min(length(title_words), 5)) {
    candidate_name <- paste(first_author, year, journal_acronym, title_words[i], sep = "-")
    if (!candidate_name %in% existing_names) {
      return(candidate_name)
    }
  }
  
  # If still not unique, combine first two words
  if (length(title_words) >= 2) {
    combined_keyword <- paste(title_words[1:2], collapse = "")
    candidate_name <- paste(first_author, year, journal_acronym, combined_keyword, sep = "-")
    if (!candidate_name %in% existing_names) {
      return(candidate_name)
    }
  }
  
  # If still not unique, add a number
  counter <- 2
  while (TRUE) {
    candidate_name <- paste(first_author, year, journal_acronym, title_keyword, counter, sep = "-")
    if (!candidate_name %in% existing_names) {
      return(candidate_name)
    }
    counter <- counter + 1
  }
}

# Get current publication directories
pub_dir <- "content/publication"
current_dirs <- list.dirs(pub_dir, full.names = FALSE, recursive = FALSE)
current_dirs <- current_dirs[current_dirs != ""]

cat("Found", length(current_dirs), "publication directories\n")
cat("Analyzing folder names for standardization...\n\n")

# Create a dataframe to track the analysis
publications <- data.frame(
  current_name = current_dirs,
  stringsAsFactors = FALSE
)

# For demonstration, let's show what the new naming convention would look like
# This is a dry-run - we'll show the proposed changes before implementing

cat("=== PROPOSED FOLDER NAME STANDARDIZATION ===\n\n")
cat("Convention: authorfamilyname-year-journalacronym-titlekeyword\n")
cat("Pattern: yang-2025-ijrs-improving, yang-2025-ijrs-estimating\n\n")

# Examples of problematic names that need fixing
problem_names <- c(
  "afrasiabian-biodiversity-2025-remotesensingapplicationssocietyandenvironment",
  "chen-a-2025-ieeejournalofselectedtopicsinappliedearthobservationsandremotesensing", 
  "gackstetter-selfattention-2025-isprsjournalofphotogrammetryandremotesensing",
  "li-a-2025-remotesensingofenvironment",
  "tang-exploring-2025-ieeetransactionsongeoscienceandremotesensing",
  "yang-improving-2025-ijrs",
  "yang-estimating-2021"
)

cat("EXAMPLES OF NAMES THAT NEED STANDARDIZATION:\n")
for (name in problem_names) {
  if (name %in% current_dirs) {
    cat("❌ OLD:", name, "\n")
    # Extract info from the name (this is approximate)
    if (str_detect(name, "remotesensingapplicationssocietyandenvironment")) {
      cat("✅ NEW: afrasiabian-2025-rsase-biodiversity\n")
    } else if (str_detect(name, "ieeejournalofselectedtopics")) {
      cat("✅ NEW: chen-2025-jstars-potential\n") 
    } else if (str_detect(name, "isprsjournalofphotogrammetry")) {
      cat("✅ NEW: gackstetter-2025-ijprs-selfattention\n")
    } else if (str_detect(name, "remotesensingofenvironment")) {
      cat("✅ NEW: li-2025-rse-global\n")
    } else if (str_detect(name, "ieeetransactionsongeoscience")) {
      cat("✅ NEW: tang-2025-tgrs-exploring\n")
    } else if (str_detect(name, "yang-improving-2025-ijrs")) {
      cat("✅ NEW: yang-2025-ijrs-improving\n")
    } else if (str_detect(name, "yang-estimating-2021")) {
      cat("✅ NEW: yang-2021-unknown-estimating\n")
    }
    cat("\n")
  }
}

cat("JOURNAL ACRONYM MAPPING:\n")
for (journal in names(journal_acronyms)) {
  cat(sprintf("%-50s -> %s\n", journal, journal_acronyms[[journal]]))
}

cat("\nTo implement the standardization:\n")
cat("1. Review the proposed changes above\n")
cat("2. Run the standardization script to rename folders\n") 
cat("3. Update any internal references if needed\n")
cat("4. Rebuild the site\n")