# ANALYSIS OF YELP DATA

# Clear working space
rm(list = ls())
gc()

# This script quantifies the sentiments associated with each review.
library(syuzhet)
library(plyr)

# Read in, subset, and merge data
loc <- '/Users/josiahdavis/Documents/GitHub/earl/'
d <- read.csv(paste(loc, 'yelp_review_Banking.csv', sep=""))

# For each review, calculate the count of negative and positive sentiments
ds <- data.frame(t(apply(as.matrix(d$text), 1, function(x) colSums(
  get_nrc_sentiment(get_sentences(as.character(x)))[c("negative", "positive")])
  )))

# Add back into the dataframe
ds <- cbind(d, ds)

# Create two helper variables
ds$positivity <- ds$positive / ds$wordsLength
ds$negativity <- ds$negative / ds$wordsLength

# Write out dataframe
write.csv(ds, paste(loc, 'yelp_review_Banking.csv', sep=""), row.names=FALSE)
