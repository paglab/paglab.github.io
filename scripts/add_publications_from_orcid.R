#!/usr/bin/env Rscript
# scripts/add_publications_from_orcid.R
#
# Build Hugo publication pages directly from an ORCID profile (no Zotero export).
#
#   ORCID works  ->  DOIs  ->  Crossref metadata (+ abstract)  ->  content/publication/<slug>/index.md
#
# Usage:
#   Rscript scripts/add_publications_from_orcid.R                 # defaults to Kang Yu's ORCID
#   Rscript scripts/add_publications_from_orcid.R 0000-0002-0686-6783 0000-0002-XXXX  # one or more ORCIDs
#
# Env overrides (handy for testing):
#   PUB_OUTDIR=/tmp/pubtest   # write somewhere other than content/publication
#   PUB_LIMIT=5               # only process the first N DOIs
#   PUB_MAILTO=you@email      # optional: Crossref "polite pool" contact.
#                             # If unset, requests use the anonymous pool (fine).
#
# Slug / front-matter conventions are kept identical to scripts/add_publications.R
# so existing publications are detected and skipped (idempotent).

suppressPackageStartupMessages({
  required_packages <- c("httr", "jsonlite", "yaml", "lubridate", "tools")
  for (pkg in required_packages) {
    if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
      install.packages(pkg, repos = "https://cloud.r-project.org")
      library(pkg, character.only = TRUE)
    }
  }
})

# ---- Configuration ----
config <- list(
  output_dir = Sys.getenv("PUB_OUTDIR", "content/publication"),
  mailto     = Sys.getenv("PUB_MAILTO", ""),  # optional Crossref contact; empty = anonymous pool
  limit      = suppressWarnings(as.integer(Sys.getenv("PUB_LIMIT", "0"))),
  year       = Sys.getenv("PUB_YEAR", ""),    # optional: only import this publication year
  preserve_caps = FALSE,
  citation_style = "apa"
)
UA <- httr::user_agent(if (nzchar(config$mailto))
  sprintf("paglab.github.io publication importer (mailto:%s)", config$mailto)
  else "paglab.github.io publication importer")

`%||%` <- function(x, y) if (!is.null(x) && length(x) && !is.na(x[1]) && nzchar(x[1])) x else y

# ---- Formatting helpers (kept in sync with add_publications.R) ----
clean_title <- function(title) {
  if (is.null(title) || is.na(title)) return("")
  title <- gsub("[{}]", "", title)
  if (!config$preserve_caps && grepl("^[A-Z\\s\\d\\p{P}]+$", title, perl = TRUE)) {
    title <- tools::toTitleCase(tolower(title))
  }
  trimws(title)
}

parse_date <- function(entry) {
  date_val <- entry$date %||% NA_character_
  if (!is.na(date_val) && date_val != "") {
    date_str <- as.character(date_val)
    parsed <- tryCatch(lubridate::ymd(date_str, quiet = TRUE), error = function(e) NA)
    if (!is.na(parsed)) return(format(parsed, "%Y-%m-%d"))
  }
  format(Sys.Date(), "%Y-%m-%d")
}

generate_citation <- function(entry) {
  auths <- entry$author
  if (length(auths) > 2L) {
    authors <- paste0(paste(auths[-length(auths)], collapse = ", "), ", & ", auths[length(auths)])
  } else if (length(auths) == 2L) {
    authors <- paste(auths, collapse = " & ")
  } else {
    authors <- auths %||% "Unknown author"
  }
  title <- clean_title(entry$title %||% "Untitled")
  journal <- entry$journal %||% ""
  year <- substr(parse_date(entry), 1L, 4L)
  vol <- if (!is.null(entry$volume) && nzchar(entry$volume)) paste0(", ", entry$volume) else ""
  num <- if (!is.null(entry$number) && nzchar(entry$number)) paste0("(", entry$number, ")") else ""
  pg  <- if (!is.null(entry$pages)  && nzchar(entry$pages))  paste0(": ", entry$pages) else ""
  sprintf("%s (%s). %s. *%s*%s%s%s.", authors, year, title, journal, vol, num, pg)
}

journal_acronym <- function(journal_name) {
  if (is.null(journal_name) || is.na(journal_name) || journal_name == "") return("unknown")
  journal_name <- trimws(gsub("[{}]", "", journal_name))
  if (journal_name == "") return("unknown")
  normalized <- tolower(gsub("[^a-zA-Z]", "", journal_name))
  journal_map <- list(
    "remotesensing" = "rs",
    "internationaljournalofappliedearthobservationandgeoinformation" = "ijaeog",
    "internationaljournalofremotesensing" = "ijrs",
    "isprsjouranalofphotogrammetryandremotesensing" = "ijprs",
    "ieeetransactionsongeoscienceandremotesensing" = "tgrs",
    "precisionagriculture" = "pa",
    "computerelectronicsinagriculture" = "cea",
    "fieldcropsresearch" = "fcr",
    "smartagriculturaltechnology" = "sat",
    "europeanjournaofagronomy" = "eja",
    "agroforestrysystems" = "afs",
    "frontiersinplantsscience" = "fps",
    "plantphenomics" = "pp",
    "remotesensingingecologyandconservation" = "rsec",
    "remotesensingofofscandinavia" = "rss",
    "photogrammetricrecord" = "pr",
    "landscapeandurbanplanning" = "lup",
    "annalsofbotany" = "aob",
    "agriculturalresearch" = "agr",
    # Preprint servers
    "ssrn" = "ssrn",
    "biorxiv" = "biorxiv",
    "medrxiv" = "medrxiv",
    "arxiv" = "arxiv",
    "researchsquare" = "rsq",
    "preprintsorg" = "preprints",
    "agrirxiv" = "agrirxiv",
    "eartharxiv" = "eartharxiv",
    "chemrxiv" = "chemrxiv"
  )
  mapped <- journal_map[[normalized]]
  if (!is.null(mapped)) return(mapped)
  words <- strsplit(journal_name, "\\s+")[[1]]
  words <- gsub("[^a-zA-Z]", "", words)  # drop digits/punctuation within tokens
  words <- words[nchar(words) > 2]
  if (length(words) == 0) return("unknown")
  substr(paste0(substr(tolower(words), 1, 1), collapse = ""), 1, 6)
}

# When Crossref has no journal/container title (preprints), name the venue from
# the DOI registrant prefix; fall back to Crossref group/publisher.
preprint_venue <- function(doi, group = "", publisher = "") {
  prefix <- sub("/.*$", "", tolower(doi))
  known <- c(
    "10.1101"   = "bioRxiv",          # also medRxiv (same registrant)
    "10.2139"   = "SSRN",
    "10.21203"  = "Research Square",
    "10.20944"  = "Preprints.org",
    "10.48550"  = "arXiv",
    "10.31220"  = "agriRxiv",
    "10.31223"  = "EarthArXiv",
    "10.26434"  = "ChemRxiv",
    "10.31219"  = "OSF Preprints"
  )
  if (prefix %in% names(known)) return(unname(known[[prefix]]))
  if (nzchar(group)) return(group)
  if (nzchar(publisher)) return(publisher)
  ""
}

# Normalise a DOI for reliable comparison (lowercase, strip resolver prefix)
normalize_doi <- function(d) {
  if (is.null(d) || all(is.na(d)) || identical(d, "")) return("")
  d <- tolower(trimws(as.character(d)[1]))
  d <- gsub("^https?://(dx\\.)?doi\\.org/", "", d)
  gsub("[\"' ]", "", d)
}

# DOIs already present on the site -> dedup by DOI (robust to slug differences)
load_existing_dois <- function(output_dir) {
  files <- list.files(output_dir, pattern = "index\\.md$",
                      recursive = TRUE, full.names = TRUE)
  dois <- vapply(files, function(f) {
    lines <- tryCatch(readLines(f, warn = FALSE), error = function(e) character(0))
    dl <- grep("^doi:\\s*", lines, value = TRUE)
    if (length(dl)) normalize_doi(sub("^doi:\\s*", "", dl[1])) else ""
  }, character(1))
  unique(dois[nzchar(dois)])
}

sanitize_slug <- function(entry) {
  first_author <- tryCatch({
    author_str <- entry$author[1]
    if (grepl(",", author_str)) {
      family_name <- trimws(strsplit(author_str, ",")[[1]][1])
    } else {
      parts <- strsplit(author_str, "\\s+")[[1]]
      family_name <- parts[[length(parts)]]
    }
    tolower(iconv(family_name, from = "", to = "ASCII//TRANSLIT"))
  }, error = function(e) "unknown")
  year <- substr(parse_date(entry), 1L, 4L)
  acronym <- journal_acronym(entry$journal %||% "")
  title_part <- clean_title(entry$title %||% "untitled")
  title_words <- strsplit(tolower(title_part), "\\s+")[[1]]
  title_words <- title_words[!title_words %in% c("a","an","the","of","and","in","for","on","with","by","using","based","via")]
  title_keyword <- gsub("[^[:alnum:]]", "", title_words[1])
  slug <- paste(first_author, year, acronym, title_keyword, sep = "-")
  gsub("-+", "-", slug)
}

map_publication_type <- function(cr_type) {
  type <- tolower(as.character(cr_type %||% "journal-article"))
  switch(type,
    "journal-article"   = "2",
    "proceedings-article" = "1",
    "book"              = "5",
    "monograph"         = "5",
    "book-chapter"      = "6",
    "posted-content"    = "3",   # preprints
    "report"            = "4",
    "dissertation"      = "7",
    "2")                          # default: journal article
}

# ---- Abstract cleaning (Crossref returns JATS XML) ----
clean_abstract <- function(abs) {
  if (is.null(abs) || is.na(abs) || abs == "") return("")
  abs <- gsub("<[^>]+>", "", abs)                       # strip JATS/XML tags
  abs <- gsub("(?i)^\\s*abstract\\s*", "", abs, perl = TRUE)
  abs <- gsub("&amp;", "&", abs); abs <- gsub("&lt;", "<", abs); abs <- gsub("&gt;", ">", abs)
  abs <- gsub("&#x[0-9a-fA-F]+;|&#[0-9]+;", "", abs)
  abs <- gsub("[ \t\r\n]+", " ", abs)
  trimws(abs)
}

# yaml::as.yaml escapes non-ASCII to "<U+XXXX>"; turn those back into real UTF-8
# so accented author names (e.g. Schön) render correctly in Hugo.
unescape_unicode <- function(x) {
  m <- gregexpr("<U\\+([0-9A-Fa-f]{4,6})>", x)
  regmatches(x, m) <- lapply(regmatches(x, m), function(tokens) {
    if (!length(tokens)) return(tokens)
    hex <- sub("<U\\+([0-9A-Fa-f]+)>", "\\1", tokens)
    vapply(hex, function(h) intToUtf8(strtoi(h, 16L)), character(1))
  })
  x
}

# ---- Network ----
get_json <- function(url, accept = "application/json") {
  resp <- tryCatch(httr::GET(url, UA, httr::add_headers(Accept = accept), httr::timeout(40)),
                   error = function(e) NULL)
  if (is.null(resp) || httr::status_code(resp) != 200) return(NULL)
  tryCatch(jsonlite::fromJSON(httr::content(resp, as = "text", encoding = "UTF-8"),
                              simplifyVector = FALSE),
           error = function(e) NULL)
}

orcid_dois <- function(orcid) {
  url <- sprintf("https://pub.orcid.org/v3.0/%s/works", orcid)
  data <- get_json(url)
  if (is.null(data) || is.null(data$group)) return(character(0))
  dois <- unlist(lapply(data$group, function(g) {
    ws <- g$`work-summary`[[1]]
    ids <- ws$`external-ids`$`external-id`
    if (is.null(ids)) return(NULL)
    vals <- vapply(ids, function(id) {
      if (!is.null(id$`external-id-type`) && tolower(id$`external-id-type`) == "doi")
        return(id$`external-id-value`) else return(NA_character_)
    }, character(1))
    vals[!is.na(vals)]
  }))
  unique(tolower(dois))
}

crossref_entry <- function(doi) {
  url <- sprintf("https://api.crossref.org/works/%s", utils::URLencode(doi, reserved = TRUE))
  if (nzchar(config$mailto)) url <- paste0(url, "?mailto=", config$mailto)
  data <- get_json(url)
  # NOTE: use [[ ]] (exact match) throughout — `m$issue` would partial-match
  # `m$issued` and pull in the date-parts list.
  if (is.null(data) || is.null(data[["message"]])) return(NULL)
  m <- data[["message"]]
  # authors as "Given Family" (matches existing publication pages)
  authors <- character(0)
  if (!is.null(m[["author"]])) {
    authors <- vapply(m[["author"]], function(a) {
      fam <- a[["family"]] %||% ""; giv <- a[["given"]] %||% ""
      if (nzchar(giv) && nzchar(fam)) paste(giv, fam) else (a[["name"]] %||% fam)
    }, character(1))
    authors <- enc2utf8(authors[nzchar(authors)])
  }
  # date: prefer issued, fall back to published
  dparts <- m[["issued"]][["date-parts"]][[1]]
  if (is.null(dparts)) dparts <- m[["published"]][["date-parts"]][[1]]
  y  <- if (length(dparts) >= 1) dparts[[1]] else NA
  mo <- if (length(dparts) >= 2) dparts[[2]] else 1
  da <- if (length(dparts) >= 3) dparts[[3]] else 1
  date_str <- if (!is.na(y))
    sprintf("%04d-%02d-%02d", as.integer(y), as.integer(mo), as.integer(da)) else NA
  ct <- m[["container-title"]]
  venue <- if (length(ct)) ct[[1]] else
    preprint_venue(doi, m[["group-title"]] %||% "", m[["publisher"]] %||% "")
  list(
    title    = enc2utf8(clean_title(if (length(m[["title"]])) m[["title"]][[1]] else "Untitled")),
    author   = if (length(authors)) authors else "Unknown author",
    journal  = enc2utf8(venue),
    volume   = as.character(m[["volume"]] %||% ""),
    number   = as.character(m[["issue"]] %||% ""),
    pages    = as.character(m[["page"]] %||% ""),
    doi      = tolower(m[["DOI"]] %||% doi),
    abstract = enc2utf8(clean_abstract(m[["abstract"]] %||% "")),
    date     = date_str,
    cr_type  = m[["type"]] %||% "journal-article"
  )
}

# ---- Main ----
main <- function() {
  args <- commandArgs(trailingOnly = TRUE)
  orcids <- if (length(args)) args else "0000-0002-0686-6783"  # default: Kang Yu

  message("Fetching DOIs from ORCID: ", paste(orcids, collapse = ", "))
  dois <- unique(unlist(lapply(orcids, orcid_dois)))
  if (config$limit > 0 && length(dois) > config$limit) dois <- dois[seq_len(config$limit)]
  message("Found ", length(dois), " unique DOI(s).")
  if (!length(dois)) return(invisible(FALSE))

  existing_dois <- load_existing_dois(config$output_dir)
  message("Existing publications with a DOI: ", length(existing_dois))

  added <- 0L; skipped <- 0L; failed <- 0L
  for (i in seq_along(dois)) {
    doi <- dois[i]
    if (normalize_doi(doi) %in% existing_dois) {
      skipped <- skipped + 1L
      message(sprintf("[%d/%d] skip  (DOI already on site) %s", i, length(dois), doi))
      next
    }
    entry <- tryCatch(crossref_entry(doi), error = function(e) NULL)
    if (is.null(entry)) { failed <- failed + 1L; message(sprintf("[%d/%d] FAIL  %s", i, length(dois), doi)); next }
    if (nzchar(config$year) && substr(parse_date(entry), 1L, 4L) != config$year) {
      message(sprintf("[%d/%d] skip  (year != %s) %s", i, length(dois), config$year, doi))
      next
    }
    entry$publication_type <- map_publication_type(entry$cr_type)
    slug <- sanitize_slug(entry)
    dir  <- file.path(config$output_dir, slug)
    index_file <- file.path(dir, "index.md")
    if (file.exists(index_file)) {
      skipped <- skipped + 1L
      existing_dois <- c(existing_dois, normalize_doi(entry$doi))
      message(sprintf("[%d/%d] skip  %s", i, length(dois), slug))
      Sys.sleep(0.1); next
    }
    dir.create(dir, recursive = TRUE, showWarnings = FALSE)
    metadata <- list(
      title = entry$title,
      date = parse_date(entry),
      publication_types = list(entry$publication_type),
      authors = as.list(entry$author),
      publication = entry$journal,
      doi = entry$doi,
      url = "",
      abstract = entry$abstract
    )
    lines <- unescape_unicode(c("---", yaml::as.yaml(metadata), "---", "",
                                generate_citation(entry)))
    writeLines(lines, index_file, useBytes = TRUE)
    existing_dois <- c(existing_dois, normalize_doi(entry$doi))
    added <- added + 1L
    message(sprintf("[%d/%d] ADD   %s", i, length(dois), slug))
    Sys.sleep(0.2)  # be polite to Crossref
  }
  message("\nDone. Added: ", added, " | Skipped (existing): ", skipped, " | Failed: ", failed)
  invisible(added)
}

if (!interactive()) main()
