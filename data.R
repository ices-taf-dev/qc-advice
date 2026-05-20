# Prepare data, write CSV data tables

# Before:
# After:

library(TAF)
library(qcTAF)

mkdir("data")

# Read TAF analyses
advice.folder <- "~/git/ices/advice"
analyses <- sapply(dir(advice.folder, full=TRUE), dir, full=TRUE)
analyses <- unname(unlist(analyses))

# Apply QC tests
results <- sapply(analyses, qc)
colnames(results) <- basename(colnames(results))

# View results
print.simple.list(100 * round(rowMeans(results), 2))

# Examine boot.exists
colnames(results)[!results["qc.boot.exists",]]
these <- analyses[!results["qc.boot.exists",]]
dir(these[1])  # repo created but work has not started
dir(these[2])  # bootstrap.R solution
dir(these[3])  # full analysis, but boot is missing
