# Produce plots and tables for report

# Before: annual.csv, metrics.csv, perfect.csv (output)
# After:  barchart.png, heatmap.png, metrics.csv, perfect (report)

library(TAF)
library(lattice)
library(ggplot2)

mkdir("report")

# Read data
annual <- read.taf("output/annual.csv")
metrics <- read.taf("output/metrics.csv")
perfect <- read.taf("output/perfect.csv")

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
perfect$KB <- round(perfect$Bytes / 1024)
perfect$Bytes <- NULL

# Write tables
write.taf(metrics, dir="report")
write.taf(perfect, dir="report")
