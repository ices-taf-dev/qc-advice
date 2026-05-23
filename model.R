# Run analysis, write model results

# Before: checks.csv, files.csv (data)
# After:  annual.csv, broken.csv, checks.csv, empty.csv, good.csv, metrics.csv,
#         no.rds, overview.csv (model)

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

# Number of analyses passing checks
overview <- colSums(taf2xtab(checks))
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

# Metrics
score <- apply(taf2xtab(checks), 1, sum)
score <- data.frame(Analysis=names(score),
                    Year=as.integer(substring(names(score), 1, 4)),
                    Score=score, row.names=NULL)
volume <- aggregate(cbind(Bytes, Lines)~Analysis, files, sum)
metrics <- merge(score, volume)

# Analyses that seem empty
empty <- metrics[metrics$Bytes < 2000 | metrics$Lines < 40,]

# Passed required checks
required <- checks
required$qc.software.bib.exists <- required$qc.software.bib.valid <- NULL
good <- apply(taf2xtab(required), 1, all)
good <- names(good)[good]
good <- metrics[metrics$Analysis %in% good,]

# Broken bib files
b.data <- checks[checks$qc.data.bib.exists & !checks$qc.data.bib.valid,]
b.soft <- checks[checks$qc.software.bib.exists & !checks$qc.software.bib.valid,]
broken <- rep(c("DATA.bib","SOFTWARE.bib"), c(nrow(b.data),nrow(b.soft)))
broken <- data.frame(Broken=broken, Analysis=c(b.data$Analysis,b.soft$Analysis))

# Annual summaries
annual <- aggregate(Analysis~Year+Score, metrics, length)
names(annual)[names(annual) == "Analysis"] <- "Count"

# Write tables and lists
write.taf(annual, dir="model")
write.taf(broken, dir="model")
write.taf(checks, dir="model")
write.taf(empty, dir="model")
write.taf(good, dir="model")
write.taf(metrics, dir="model")
write.taf(overview, dir="model")
saveRDS(no, "model/no.rds")
