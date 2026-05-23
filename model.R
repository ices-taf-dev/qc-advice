# Run analysis, write model results

# Before: checks.csv, files.csv (data)
# After:  annual.csv, broken_bib.csv, checks.csv, checks_relevant.csv,
#         checks_required.csv, empty.csv, good.csv, metrics.csv, no.rds,
#         overview.csv (model)

library(TAF)

mkdir("model")

# Read QC checks
checks <- read.taf("data/checks.csv")
files <- read.taf("data/files.csv")

# Checks that are relevant for ices-advice
checks.relevant <- checks
checks.relevant$dir.exists <- NULL                 # all dirs exist
checks.relevant$qc.data.bib.processed <- NULL      # DATA.bib not processed
checks.relevant$qc.data.declared <- NULL           # no boot/data folder
checks.relevant$qc.software.bib.processed <- NULL  # SOFTWARE.bib not processed
checks.relevant$qc.software.declared <- NULL       # no boot/software folder
checks.relevant$qc.initial.data <- NULL            # no boot/data folder

# Checks that can be considered required
checks.required <- checks.relevant
checks.required$qc.software.bib.exists <- NULL
checks.required$qc.software.bib.valid <- NULL
checks.required$qc.all.scripts.exist <- NULL
checks.required$qc.only.relative.paths <- NULL

# Number of analyses passing checks
overview <- colSums(taf2xtab(checks.relevant))
overview <- data.frame(Check=names(overview), Yes=overview,
                       No=nrow(checks)-overview, row.names=NULL)

# Failed checks
not <- function(check) checks$Analysis[!checks[check]]
no <- list(boot.exists=not("qc.boot.exists"),
           data.bib.exists=not("qc.data.bib.exists"),
           data.bib.valid=not("qc.data.bib.valid"),
           software.bib.exists=not("qc.software.bib.exists"),
           software.bib.valid=not("qc.software.bib.valid"),
           any.scripts.exist=not("qc.any.scripts.exist"),
           all.scripts.exist=not("qc.all.scripts.exist"),
           only.relative.paths=not("qc.only.relative.paths"))

# Broken bib files
b.data <- checks[checks$qc.data.bib.exists & !checks$qc.data.bib.valid,]
b.soft <- checks[checks$qc.software.bib.exists & !checks$qc.software.bib.valid,]
broken.bib <- rep(c("DATA.bib", "SOFTWARE.bib"), c(nrow(b.data), nrow(b.soft)))
broken.bib <- data.frame(Broken=broken.bib,
                         Analysis=c(b.data$Analysis, b.soft$Analysis))

# Compile metrics
score <- apply(taf2xtab(checks.required), 1, sum)
score <- data.frame(Analysis=names(score),
                    Year=as.integer(substring(names(score), 1, 4)),
                    Score=score, row.names=NULL)
volume <- aggregate(cbind(Bytes, Lines)~Analysis, files, sum)
metrics <- merge(score, volume)

# Analyses that seem empty
empty <- metrics[metrics$Bytes < 2000 | metrics$Lines < 40,]

# Passed required checks
good <- apply(taf2xtab(checks.required), 1, all)
good <- names(good)[good]
good <- metrics[metrics$Analysis %in% good,]

# Annual summaries
annual <- aggregate(Analysis~Year+Score, metrics, length)
names(annual)[names(annual) == "Analysis"] <- "Count"

# Write tables and list
write.taf(annual, dir="model")
write.taf(broken.bib, dir="model")
write.taf(checks, dir="model")
write.taf(checks.relevant, dir="model")
write.taf(checks.required, dir="model")
write.taf(empty, dir="model")
write.taf(good, dir="model")
write.taf(metrics, dir="model")
saveRDS(no, "model/no.rds")
write.taf(overview, dir="model")
