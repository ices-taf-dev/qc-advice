# Prepare data, write CSV data tables

# Before: [ICES_ADVICE_FOLDER environment variable points to ices-advice folder]
# After:  analyses.csv, checks.csv, files.csv (data)

library(TAF)
library(qcTAF)

mkdir("data")

# Locate ices-advice folder
advice.folder <- Sys.getenv("ICES_ADVICE_FOLDER")
if(!dir.exists(advice.folder))
  stop("Environment variable ICES_ADVICE_FOLDER ",
       "must point to existing directory")

# Read names of TAF analyses
absolute <- sapply(dir(advice.folder, full=TRUE), dir, full=TRUE)
absolute <- unname(unlist(absolute))
repo <- basename(dirname(absolute))
subdir <- basename(absolute)
analyses <- data.frame(Repository=repo, Analysis=subdir)

# Apply QC tests
checks <- sapply(absolute, qc)
colnames(checks) <- subdir
checks <- xtab2taf(checks, "Check")

# Files
filenames <- sapply(absolute, function(x)
  file.path(basename(x), dir(x, recursive=TRUE)))
filenames <- unname(unlist(filenames))
f.subdir <- sub("^(.*?)/(.*.)$", "\\1", filenames)
f.file <- sub("^(.*?)/(.*.)$", "\\2", filenames)
f.repo <- repo[match(f.subdir, subdir)]
f.absolute <- file.path(advice.folder, f.repo, f.subdir, f.file)
f.bytes <- file.size(f.absolute)
f.lines <- unname(sapply(f.absolute, function(x)
  length(readLines(x, warn=FALSE))))
files <- data.frame(Repository=f.repo, Analysis=f.subdir, File=f.file,
                    Bytes=f.bytes, Lines=f.lines)

# Write tables
write.taf(analyses, dir="data")
write.taf(checks, dir="data")
write.taf(files, dir="data")
