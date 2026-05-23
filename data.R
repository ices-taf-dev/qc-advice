# Prepare data, write CSV data tables

# Before: advice_folder.dat, analyses.csv (boot/data/ices-advice)
# After:  analyses.csv, checks.csv, files.csv (data)

library(TAF)
library(qcTAF)

mkdir("data")

# Read data
advice.folder <- readLines("boot/data/ices-advice/advice_folder.dat")
analyses <- read.taf("boot/data/ices-advice/analyses.csv")

# Establish absolute path to analyses
absolute <- file.path(advice.folder, analyses$Repository, analyses$Analysis)

# Apply QC tests
checks <- t(sapply(absolute, qc))
rownames(checks) <- analyses$Analysis
checks <- xtab2taf(checks, "Analysis")

# Files
filenames <- sapply(absolute, function(x)
  file.path(basename(x), dir(x, recursive=TRUE)))
filenames <- unname(unlist(filenames))
f.analysis <- sub("^(.*?)/(.*.)$", "\\1", filenames)
f.file <- sub("^(.*?)/(.*.)$", "\\2", filenames)
f.repo <- analyses$Repository[match(f.analysis, analyses$Analysis)]
f.absolute <- file.path(advice.folder, f.repo, f.analysis, f.file)
f.bytes <- file.size(f.absolute)
f.lines <- unname(sapply(f.absolute, function(x)
  length(readLines(x, warn=FALSE))))
files <- data.frame(Repository=f.repo, Analysis=f.analysis, File=f.file,
                    Bytes=f.bytes, Lines=f.lines)

# Write tables
write.taf(analyses, dir="data")
write.taf(checks, dir="data")
write.taf(files, dir="data")
