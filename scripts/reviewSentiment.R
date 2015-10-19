# ANALYSIS OF YELP DATA

# Clear working space
rm(list = ls())
gc()

# This script quantifies the sentiments associated with each review.

# Read in, subset, and merge data
loc <- '/Users/josiahdavis/Documents/GitHub/earl/data/'
d <- read.csv(paste(loc, 'yelp_review.csv', sep=""))

library(syuzhet)
library(plyr)

# For each review, calculate the count of negative and positive sentiments
getSentiment <- function(x){
  colSums(get_nrc_sentiment(get_sentences(as.character(x$text)))[c("negative", "positive")])
}

# Apply function to each row of the dataframe
d <- adply(d, 1, function(x) getSentiment(x))

# Create two helper variables
d$positivity <- d$positive / d$wordsLength
d$negativity <- d$negative / d$wordsLength

# Write out dataframe
write.csv(d, paste(loc, 'yelp_review_Macys.csv', sep=""), row.names=FALSE)