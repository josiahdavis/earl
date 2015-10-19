# ====================
# CO-OCCURANCE MATRIX
# =====================

# Clear working space
rm(list = ls()); gc()

# Read in document term matrix
loc <- '/Users/josiahdavis/Documents/GitHub/earl/data/'
d <-read.csv(paste(loc, 'dictionaryWide.csv', sep=""), check.names = FALSE)
stars <- d$stars
d <- d[,-1]

# Convert from counts to T/F
d <- data.frame(sapply(d, function(x) as.integer(x > 1)))

# Create the coccurance matrix
c <- t(as.matrix(d)) %*% as.matrix(d)
diag(c) <- 0
c <- melt(c)
names(c) <- c("From", "To", "Co-occurance")

# Write out to csv in the long format
write.csv(c, paste(loc, 'co_occurance.csv', sep=""), row.names=FALSE)
