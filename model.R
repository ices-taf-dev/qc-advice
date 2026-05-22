# Run analysis, write model results

# Before: checks.csv (data)
# After:  no.rds (model)

library(TAF)

mkdir("model")

# Read QC checks
checks <- read.taf("data/checks.csv")

# Count number of analyses passing checks
overview <- colSums(taf2xtab(checks))
overview <- data.frame(Check=names(overview), Yes=overview,
                       No=nrow(checks)-overview, row.names=NULL)

# Remove rows that are not relevant for ices-advice
not.relevant <- c("dir.exists",                 # all dirs exist
                  "qc.data.bib.processed",      # DATA.bib not processed
                  "qc.data.declared",           # no boot/data folder
                  "qc.software.bib.processed",  # SOFTWARE.bib not processed
                  "qc.software.declared",       # no boot/software folder
                  "qc.initial.data")            # no boot/data folder
overview <- overview[!overview$Check %in% not.relevant,]
row.names(overview) <- NULL

# List failed checks
not <- function(check) checks$Analysis[!checks[check]]
no <- list(boot.exists=not("qc.boot.exists"),
           data.bib.exists=not("qc.data.bib.exists"),
           data.bib.valid=not("qc.data.bib.valid"),
           software.bib.exists=not("qc.software.bib.exists"),
           software.bib.valid=not("qc.software.bib.valid"),
           scripts.exist=not("qc.scripts.exist"),
           only.relative.paths=not("qc.only.relative.paths"))

# Save failed checks
saveRDS(no, "model/no.rds")
