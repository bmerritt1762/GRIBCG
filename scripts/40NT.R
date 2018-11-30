
usePackage <- function(p) {
    if (!is.element(p, installed.packages()[,1]))
        install.packages(paste("./tools/", p, sep=""), dep = TRUE)
    require(p, character.only = TRUE)
}
usePackage("predictSGRNA")
library(predictSGRNA)

data <- read.table("./tmp/full_seqs_filtered.txt", sep="\t", header = FALSE, row.names=NULL)

fortySequences <- data
#fortySequences

fortySequences$V3 <- as.character(fortySequences$V3)

df <- strsplit(fortySequences$V3, split = ",")

gf <- data.frame(V1 = rep(fortySequences$V1, sapply(df, length)), 
                 V2 = rep(fortySequences$V2, sapply(df, length)),
                 V3 = unlist(df))
gf$V3
                


predictSGRNA(gf$V3, "./tmp/thermodynamic_sequences")

data <- read.csv("./tmp/thermodynamic_sequences.csv", sep = ",", header = TRUE, row.names = NULL)
merged_data_id <- apply (gf [, 1:2], 1, paste, collapse = "\t")
#merged_data_id
#merged_data_attrib <- apply (gf [, 3:11], 1, paste, collapse = "\t")




merged_data <- paste(merged_data_id, data$Sequence, data$P.Efficient.,  sep="\t")
#merged_data
write.table(merged_data, file = "./tmp/pasted_thermodynamic_sequences.txt", col.names = FALSE, quote = FALSE, sep="\t")








