# Run analysis, write model results

# Before: checks.csv, files.csv (data)
# After:  checks.csv, empty.csv, metrics.csv, no.rds, overview.csv (model)

library(TAF)

mkdir("model")

# Read QC checks
checks <- read.taf("data/checks.csv")
files <- read.taf("data/files.csv")

# Remove checks that are not relevant for ices-advice
not.relevant <- c("dir.exists",                 # all dirs exist
                  "qc.data.bib.processed",      # DATA.bib not processed
                  "qc.data.declared",           # no boot/data folder
                  "qc.software.bib.processed",  # SOFTWARE.bib not processed
                  "qc.software.declared",       # no boot/software folder
                  "qc.initial.data")            # no boot/data folder
checks <- checks[!names(checks) %in% not.relevant]

# Count number of analyses passing checks
overview <- colSums(taf2xtab(checks))
overview <- data.frame(Check=names(overview), Yes=overview,
                       No=nrow(checks)-overview, row.names=NULL)

# List failed checks
not <- function(check) checks$Analysis[!checks[check]]
no <- list(boot.exists=not("qc.boot.exists"),
           data.bib.exists=not("qc.data.bib.exists"),
           data.bib.valid=not("qc.data.bib.valid"),
           software.bib.exists=not("qc.software.bib.exists"),
           software.bib.valid=not("qc.software.bib.valid"),
           any.scripts.exist=not("qc.any.scripts.exist"),
           all.scripts.exist=not("qc.all.scripts.exist"),
           only.relative.paths=not("qc.only.relative.paths"))

# Metrics
score <- apply(taf2xtab(checks), 1, sum)
score <- data.frame(Analysis=names(score),
                    Year=as.integer(substring(names(score), 1, 4)),
                    Checks=score, row.names=NULL)
volume <- aggregate(cbind(Bytes, Lines)~Analysis, files, sum)
metrics <- merge(score, volume)

# Which analyses seem empty
empty <- metrics[metrics$Bytes < 2000 | metrics$Lines < 40,]

# Write tables and lists
write.taf(checks, dir="model")
write.taf(empty, dir="model")
write.taf(metrics, dir="model")
write.taf(overview, dir="model")
saveRDS(no, "model/no.rds")
