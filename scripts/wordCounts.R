# =============================
# CREATE WORD-METRICS FROM 
# DOCUMENT TERM MATRIX
# =============================

# Clear working space
rm(list = ls()); gc()

# Read in document term matrix
loc <- '/Users/josiahdavis/Documents/GitHub/earl/data/'
d <-read.csv(paste(loc, 'dictionary.csv', sep=""), check.names = FALSE)
stars <- d$stars
d <- d[,-1]

# Collect the word counts
w <- data.frame(counts = colSums(d))

# Defin the term frequency measure as the total occurances divided by 
# the occurances of the most frequently occuring word
w$tfP <- 0.5 + 0.5 * colSums(d[stars > 3,]) / max(colSums(d[stars > 3,]))
w$tfN <- 0.5 + 0.5 * colSums(d[stars <= 3,]) / max(colSums(d[stars <= 3,]))

# Define negativity as the simple ratio between term frequencies
w$negativity <- w$tfN / w$tfP

# Write resulting file out to csv
w <- w[order(w$negativity, decreasing = TRUE),]
write.csv(w, paste(loc, 'words.csv', sep=""), row.names=TRUE)