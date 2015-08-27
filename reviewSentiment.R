# ANALYSIS OF YELP DATA
# This script quantifies the sentiments associated with each review.
library(syuzhet)


# Read in, subset, and merge data
loc <- '/Users/josiahdavis/Documents/GitHub/earl/'
db <- read.csv(paste(loc, 'yelp_business.csv', sep=""))
db <- db[,c("business_id","name", "state", "city")]
dr <- read.csv(paste(loc, 'yelp_review.csv', sep=""))
dr <- dr[,c("text", "stars", "votes_cool", "votes_funny", "votes_useful", "business_id")]
d <- merge(dr,db,by="business_id")

# For each review, calculate various sentiment related metrics
d$sentances <- unlist(lapply(d$text, function(x) length(get_sentences(as.character(x)))))
d$totalSentBING <- unlist(lapply(d$text, function(x) sum(get_sentiment(get_sentences(as.character(x)), method = "bing"))))
d$totalSentNRC <- unlist(lapply(d$text, function(x) sum(get_sentiment(get_sentences(as.character(x)), method = "afinn"))))
d$totalSentAFINN <- unlist(lapply(d$text, function(x) sum(get_sentiment(get_sentences(as.character(x)), method = "nrc"))))
d$totalSent <- rowMeans(d[,c("totalSentBING", "totalSentNRC", "totalSentAFINN")])
d$meanSent <- unlist(lapply(d$text, function(x) mean(get_sentiment(get_sentences(as.character(x)), method = "bing"))))
d$varSent <- unlist(lapply(d$text, function(x) var(get_sentiment(get_sentences(as.character(x)),   method = "bing"))))
d$negCount <- unlist(lapply(d$text, function(x) sum(get_sentiment(get_sentences(as.character(x)),  method = "bing") < 0)))
d$posCount <- unlist(lapply(d$text, function(x) sum(get_sentiment(get_sentences(as.character(x)),  method = "bing") > 0)))
d$neutCount <- unlist(lapply(d$text, function(x) sum(get_sentiment(get_sentences(as.character(x)), method = "bing") == 0)))

# Write out dataframe
write.csv(d, paste(loc, 'sentiment.csv', sep=""), row.names=FALSE)