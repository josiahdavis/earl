# ====================
# CORRELATION COEFFICIENT
# MATRIX BASED ON WORDS
# =====================

# Clear working space
rm(list = ls()); gc()

# Read in document term matrix
loc <- '/Users/josiahdavis/Documents/GitHub/earl/data/'
d <-read.csv(paste(loc, 'dictionaryWide.csv', sep=""), check.names = FALSE)
stars <- d$stars
d <- d[,-1]

# Compute the correlation coefficient
c <- cor(d)
c <- melt(c)
names(c) <- c("From", "To", "Correlation")

# Write out to csv in the long format
write.csv(c, paste(loc, 'correlationCoefficient.csv', sep=""), row.names=FALSE)
