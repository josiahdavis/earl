# ANALYSIS OF YELP DATA

# Clear working space
rm(list = ls())
gc()

# This script quantifies the sentiments associated with each review.
library(syuzhet)
library(plyr)

# Read in, subset, and merge data
loc <- '/Users/josiahdavis/Documents/GitHub/earl/'
d <- read.csv(paste(loc, 'yelp_review.csv', sep=""))
d <- d[,c("stars", "text", "name")]

# Create a random sample
idx <- sample(1:nrow(d), 5000, replace=FALSE)
emotions <- data.frame(t(apply(as.matrix(d[idx,]$text), 1, function(x) colSums(get_nrc_sentiment(get_sentences(as.character(x)))))))
d <- cbind(d[idx,], emotions)

# Create new variable for popular coffee shops
shops <- c("Caribou Coffee", "Krispy Kreme Doughnuts", "Dunkin' Donuts", "Starbucks", 
           "Espressamente Illy", "Einstein Bros Bagels")
d$nameAdj <- "Other"
for (i in 1:length(shops)){
  d$nameAdj <- ifelse(d$name == shops[i], shops[i], d$nameAdj)
}
d$nameAdj <- as.factor(d$nameAdj)
summary(d$nameAdj)

# Create summary dataframe
dSummary <- ddply(d, .(nameAdj), summarise, 
             anger = mean(anger),
             disgust = mean(disgust),
             sadness = mean(sadness),
             fear = mean(fear),
             anticipation = mean(anticipation),
             surprise = mean(surprise),
             trust = mean(trust),
             joy = mean(joy))

# Add an additional row for all
dSummary$nameAdj <- as.character(dSummary$nameAdj)
dSummary <- rbind(dSummary, c("all", mean(d$anger), mean(d$disgust), mean(d$sadness), mean(d$fear),mean(d$anticipation), mean(d$surprise), mean(d$trust), mean(d$joy)))
dSummary

# Write to dataframe
write.csv(dSummary, paste(loc, 'emotions.csv', sep=""), row.names=FALSE)
