# Produce plots and tables for report

# Before: annual.csv, metrics.csv, good.csv (output)
# After:  barchart.png, good.csv, heatmap.png, metrics.csv (report)

library(TAF)
library(lattice)
library(ggplot2)

mkdir("report")

# Read data
annual <- read.taf("output/annual.csv")
metrics <- read.taf("output/metrics.csv")
good <- read.taf("output/good.csv")

# Lattice barplot
taf.png("barchart")
p <- barchart(factor(Score)~Count|factor(Year), annual, layout=c(3,1))
plot(p)
dev.off()

# ggplot heatmap
taf.png("heatmap")
p <- ggplot(annual, aes(x=factor(Year), y=factor(Score), fill=Count)) +
  geom_tile(color="white", show.legend=FALSE) +
  geom_text(aes(label=Count), color="white", size=4) +
  scale_fill_gradient(low="lightblue", high="navy") +
  labs(title="Count of Analyses by Score and Year", x=NULL, y="Score") +
  theme_minimal()
plot(p)
dev.off()

# Format tables
metrics$KB <- round(metrics$Bytes / 1024)
metrics$Bytes <- NULL
good$KB <- round(good$Bytes / 1024)
good$Bytes <- NULL

# Write tables
write.taf(good, dir="report")
write.taf(metrics, dir="report")
