library(TAF)

# Locate ices-advice folder
advice.folder <- Sys.getenv("ICES_ADVICE_FOLDER")
if(!dir.exists(advice.folder))
  stop("Environment variable ICES_ADVICE_FOLDER ",
       "must point to existing directory")

# Read names of TAF analyses
absolute <- sapply(dir(advice.folder, full=TRUE), dir, full=TRUE)
absolute <- unname(unlist(absolute))
repo <- basename(dirname(absolute))
analysis <- basename(absolute)
analyses <- data.frame(Repository=repo, Analysis=analysis)

# Write path and table
write(advice.folder, "advice_folder.dat")
write.taf(analyses)
