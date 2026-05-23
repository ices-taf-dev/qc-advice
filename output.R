# Extract results of interest, write CSV output tables

# Before: *.csv, *.rds (model)
# After:  *.csv, *.rds (output)

library(TAF)

mkdir("output")

# Copy tables and list
cp("model/*", "output")
