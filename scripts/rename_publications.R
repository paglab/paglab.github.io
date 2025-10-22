#!/usr/bin/env Rscript

# Publication Folder Renaming Implementation Script
# Convention: authorfamilyname-year-journalacronym-titlekeyword

library(stringr)
library(dplyr)
library(yaml)

# Journal acronym mapping (comprehensive list)
journal_acronyms <- list(
  "Remote Sensing of Environment" = "rse",
  "Remote Sensing Applications Society and Environment" = "rsase", 
  "International Journal of Applied Earth Observation and Geoinformation" = "ijaeog",
  "ISPRS Journal of Photogrammetry and Remote Sensing" = "ijprs",
  "International Journal of Remote Sensing" = "ijrs",
  "Smart Agricultural Technology" = "sat",
  "Computers and Electronics in Agriculture" = "cea",
  "Field Crops Research" = "fcr",
  "European Journal of Agronomy" = "eja",
  "European Journal of Soil Science" = "ejss",
  "Precision Agriculture" = "pa",
  "Plant Phenomics" = "pp",
  "Potato Research" = "pr",
  "Agriculture" = "agr",
  "Annals of Botany" = "aob",
  "Agroforestry Systems" = "afs",
  "GigaScience" = "gs",
  "Landscape and Urban Planning" = "lup",
  "IEEE Journal of Selected Topics in Applied Earth Observations and Remote Sensing" = "jstars",
  "IEEE Transactions on Geoscience and Remote Sensing" = "tgrs",
  "Remote Sensing" = "rs",
  "Frontiers in Plant Science" = "fps",
  "Food Chemistry" = "fc",
  "Journal of Plant Nutrition and Fertilization" = "jpnf"
)

# Function to get journal acronym
get_journal_acronym <- function(journal_full_name) {
  journal_clean <- str_trim(journal_full_name)
  
  # Remove special formatting like {GIL}-{Jahrestagung}
  journal_clean <- str_replace_all(journal_clean, "[{}\\-]+", " ")
  journal_clean <- str_replace_all(journal_clean, "\\s+", " ")
  journal_clean <- str_trim(journal_clean)
  
  if (journal_clean %in% names(journal_acronyms)) {
    return(journal_acronyms[[journal_clean]])
  }
  
  # Generate acronym from first letters
  words <- str_split(journal_clean, "\\s+")[[1]]
  words <- words[!words %in% c("of", "and", "in", "the", "for", "on", "&", "künstliche", "intelligenz", "agrar", "ernährungswirtschaft")]
  words <- words[!str_detect(words, "^\\d+")]  # Remove numbers like "42."
  
  # Keep only alphabetic characters
  words <- str_replace_all(words, "[^a-zA-Z]", "")
  words <- words[nchar(words) > 1]  # Remove very short words
  
  if (length(words) == 0) {
    return("unknown")
  }
  
  acronym <- paste(str_sub(words, 1, 1), collapse = "")
  return(str_to_lower(acronym))
}

# Function to extract first meaningful title word
get_title_keyword <- function(title) {
  title_words <- str_split(str_to_lower(title), "\\s+")[[1]]
  title_words <- title_words[!title_words %in% c("a", "an", "the", "of", "and", "in", "for", "on", "with", "by", "using", "based", "via")]
  title_words <- str_replace_all(title_words, "[^a-zA-Z]", "")
  title_words <- title_words[nchar(title_words) > 2]
  
  if (length(title_words) == 0) {
    return("paper")
  }
  return(title_words[1])
}

# Function to generate new folder name
generate_new_name <- function(authors, year, journal, title, existing_names = c()) {
  # Get first author's family name (last name only)
  first_author_full <- str_trim(str_split(authors[1], ",")[[1]][1])
  
  # Extract family name (last word if space-separated, or full if no spaces)
  name_parts <- str_split(first_author_full, "\\s+")[[1]]
  if (length(name_parts) > 1) {
    family_name <- name_parts[length(name_parts)]  # Last word is family name
  } else {
    family_name <- first_author_full  # Single name
  }
  
  family_name <- str_to_lower(str_replace_all(family_name, "[^a-zA-Z]", ""))
  
  # Get journal acronym
  journal_acronym <- get_journal_acronym(journal)
  
  # Get title keyword
  title_keyword <- get_title_keyword(title)
  
  # Generate name: familyname-year-journal-keyword
  new_name <- paste(family_name, year, journal_acronym, title_keyword, sep = "-")
  
  # Handle duplicates by trying alternative title words
  if (new_name %in% existing_names) {
    title_words <- str_split(str_to_lower(title), "\\s+")[[1]]
    title_words <- title_words[!title_words %in% c("a", "an", "the", "of", "and", "in", "for", "on", "with", "by", "using", "based", "via")]
    title_words <- str_replace_all(title_words, "[^a-zA-Z]", "")
    title_words <- title_words[nchar(title_words) > 2]
    
    for (i in 2:min(length(title_words), 5)) {
      candidate_name <- paste(family_name, year, journal_acronym, title_words[i], sep = "-")
      if (!candidate_name %in% existing_names) {
        return(candidate_name)
      }
    }
    
    # If still duplicate, add number
    counter <- 2
    while (TRUE) {
      candidate_name <- paste(family_name, year, journal_acronym, title_keyword, counter, sep = "-")
      if (!candidate_name %in% existing_names) {
        return(candidate_name)
      }
      counter <- counter + 1
    }
  }
  
  return(new_name)
}

# Read publication metadata
read_publication_metadata <- function(folder_path) {
  index_file <- file.path(folder_path, "index.md")
  
  if (!file.exists(index_file)) {
    return(NULL)
  }
  
  content <- readLines(index_file, warn = FALSE)
  
  # Find YAML frontmatter
  yaml_start <- which(content == "---")[1]
  yaml_end <- which(content == "---")[2]
  
  if (is.na(yaml_start) || is.na(yaml_end)) {
    return(NULL)
  }
  
  yaml_content <- paste(content[(yaml_start + 1):(yaml_end - 1)], collapse = "\n")
  
  tryCatch({
    metadata <- yaml::yaml.load(yaml_content)
    return(metadata)
  }, error = function(e) {
    cat("Error reading", folder_path, ":", e$message, "\n")
    return(NULL)
  })
}

# Main execution
cat("=== PUBLICATION FOLDER STANDARDIZATION ===\n\n")

pub_dir <- "content/publication"
current_dirs <- list.dirs(pub_dir, full.names = FALSE, recursive = FALSE)
current_dirs <- current_dirs[current_dirs != "" & current_dirs != ".DS_Store"]

cat("Found", length(current_dirs), "publication directories\n\n")

# Analyze each publication
rename_plan <- data.frame(
  old_name = character(),
  new_name = character(),
  author = character(),
  year = character(),
  journal = character(),
  title = character(),
  stringsAsFactors = FALSE
)

new_names_used <- c()

for (dir_name in current_dirs) {
  folder_path <- file.path(pub_dir, dir_name)
  metadata <- read_publication_metadata(folder_path)
  
  if (is.null(metadata)) {
    cat("⚠️  Could not read metadata for:", dir_name, "\n")
    next
  }
  
  # Extract metadata
  title <- metadata$title %||% "Unknown Title"
  authors <- metadata$authors %||% list("Unknown Author")
  
  # Handle authors properly
  if (is.list(authors) && length(authors) > 0) {
    first_author <- as.character(authors[[1]])
  } else if (is.character(authors) && length(authors) > 0) {
    first_author <- authors[1]
  } else {
    first_author <- "Unknown"
  }
  
  date_str <- as.character(metadata$date %||% "2000-01-01")
  year <- str_extract(date_str, "\\d{4}")
  
  journal <- as.character(metadata$publication %||% "Unknown Journal")
  
  # Generate new name
  new_name <- generate_new_name(first_author, year, journal, title, new_names_used)
  new_names_used <- c(new_names_used, new_name)
  
  # Add to rename plan
  rename_plan <- rbind(rename_plan, data.frame(
    old_name = dir_name,
    new_name = new_name,
    author = first_author,
    year = year,
    journal = journal,
    title = title,
    stringsAsFactors = FALSE
  ))
}

# Show rename plan
cat("RENAME PLAN:\n")
cat("===========\n\n")

changes_needed <- rename_plan$old_name != rename_plan$new_name
n_changes <- sum(changes_needed)

cat("Total folders:", nrow(rename_plan), "\n")
cat("Need renaming:", n_changes, "\n")
cat("Already correct:", nrow(rename_plan) - n_changes, "\n\n")

if (n_changes > 0) {
  cat("FOLDERS TO RENAME:\n")
  for (i in which(changes_needed)) {
    cat(sprintf("%-70s -> %s\n", 
                rename_plan$old_name[i], 
                rename_plan$new_name[i]))
  }
  
  cat("\nTo execute the renaming:\n")
  cat("1. Review the plan above\n")
  cat("2. Run: Rscript scripts/execute_rename.R\n")
  cat("3. Rebuild the site\n\n")
  
  # Save rename plan for execution script
  saveRDS(rename_plan, "scripts/rename_plan.rds")
  cat("Rename plan saved to scripts/rename_plan.rds\n")
  
} else {
  cat("✅ All folder names are already following the correct convention!\n")
}