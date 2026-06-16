#!/usr/bin/env Rscript
# scripts/backfill_abstracts.R
#
# Fill in MISSING abstracts on existing publication pages by matching DOI to a
# BibTeX export (e.g. a Zotero / Better BibTeX file that has abstracts).
#
# Only pages whose front matter currently has an empty abstract are touched, and
# only the abstract line is rewritten — every other field is left byte-identical.
#
# Usage:
#   Rscript scripts/backfill_abstracts.R "paglab.data/Exported Items 2026.bib"
#
# Env overrides:
#   PUB_OUTDIR=content/publication   # where the publication pages live

suppressPackageStartupMessages({
  for (pkg in c("RefManageR", "yaml")) {
    if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
      install.packages(pkg, repos = "https://cloud.r-project.org")
      library(pkg, character.only = TRUE)
    }
  }
})

output_dir <- Sys.getenv("PUB_OUTDIR", "content/publication")

normalize_doi <- function(d) {
  if (is.null(d) || all(is.na(d)) || identical(d, "")) return("")
  d <- tolower(trimws(as.character(d)[1]))
  d <- gsub("^https?://(dx\\.)?doi\\.org/", "", d)
  gsub("[\"' ]", "", d)
}

# yaml::as.yaml escapes non-ASCII to "<U+XXXX>"; restore real UTF-8.
unescape_unicode <- function(x) {
  m <- gregexpr("<U\\+([0-9A-Fa-f]{4,6})>", x)
  regmatches(x, m) <- lapply(regmatches(x, m), function(tokens) {
    if (!length(tokens)) return(tokens)
    hex <- sub("<U\\+([0-9A-Fa-f]+)>", "\\1", tokens)
    vapply(hex, function(h) intToUtf8(strtoi(h, 16L)), character(1))
  })
  x
}

clean_abstract <- function(a) {
  if (is.null(a) || is.na(a) || a == "") return("")
  a <- gsub("[{}]", "", a)               # BibTeX braces
  a <- gsub("[ \t\r\n]+", " ", a)
  trimws(a)
}

main <- function() {
  args <- commandArgs(trailingOnly = TRUE)
  if (!length(args) || !nzchar(args[1])) stop("Provide a .bib path as the first argument.")
  bib_path <- args[1]
  message("Reading abstracts from: ", bib_path)

  bib <- RefManageR::ReadBib(bib_path, check = FALSE)
  abs_by_doi <- list()
  for (key in names(bib)) {
    e <- bib[[key]]
    doi <- normalize_doi(tryCatch(e$doi, error = function(x) ""))
    a <- clean_abstract(tryCatch(e$abstract, error = function(x) ""))
    if (nzchar(doi) && nzchar(a)) abs_by_doi[[doi]] <- a
  }
  message("Abstracts available in bib (by DOI): ", length(abs_by_doi))

  files <- list.files(output_dir, pattern = "index\\.md$",
                      recursive = TRUE, full.names = TRUE)
  updated <- 0L; nomatch <- 0L
  for (f in files) {
    lines <- readLines(f, warn = FALSE)
    # locate the empty-abstract line inside the front matter
    fm_end <- which(lines == "---")[2]
    if (is.na(fm_end)) next
    fm <- lines[seq_len(fm_end)]
    empty_idx <- which(fm == "abstract: ''" | fm == 'abstract: ""')
    if (!length(empty_idx)) next  # already has an abstract (or none expected)

    doi_line <- grep("^doi:\\s*", fm, value = TRUE)
    doi <- if (length(doi_line)) normalize_doi(sub("^doi:\\s*", "", doi_line[1])) else ""
    a <- if (nzchar(doi)) abs_by_doi[[doi]] else NULL
    if (is.null(a)) { nomatch <- nomatch + 1L; next }

    # serialise just the abstract field the same way the generator does
    block <- unescape_unicode(yaml::as.yaml(list(abstract = a)))
    block <- strsplit(sub("\n$", "", block), "\n", fixed = TRUE)[[1]]

    new_lines <- c(lines[seq_len(empty_idx[1] - 1L)], block,
                   lines[(empty_idx[1] + 1L):length(lines)])
    writeLines(new_lines, f, useBytes = TRUE)
    updated <- updated + 1L
    message("Filled abstract: ", basename(dirname(f)))
  }
  message("\nDone. Filled: ", updated,
          " | empty-but-no-DOI-match: ", nomatch)
  invisible(updated)
}

if (!interactive()) main()
