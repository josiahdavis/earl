# ANALYSIS OF YELP DATA
# This script quantifies the sentiments associated with each review.

library(syuzhet)


# Read in data
loc <- '/Users/josiahdavis/Documents/GitHub/earl/'
dr <- read.csv(paste(loc, 'yelp_review.csv', sep=""))


# For each review, calculate various sentiment related metrics
d <- dr[,c("text", "stars")]
d$length <- NULL
d$meanSent <- NULL
d$varSent <- NULL
d$negCount <- NULL
d$neutCount <- NULL
d$posCount <- NULL

for (i in 1:nrow(d)){
  d$length[i] = length(get_sentences(as.character(d$text)))
}

sentances <- function(x) get_sentences(as.character(x))

d$sentances <- unlist(lapply(d$text, function(x) length(get_sentences(as.character(x)))))
d$meanSent <- unlist(lapply(d$text, function(x) mean(get_sentiment(get_sentences(as.character(x)), method = "bing"))))
d$varSent <- unlist(lapply(d$text, function(x) var(get_sentiment(get_sentences(as.character(x)),   method = "bing"))))
d$negCount <- unlist(lapply(d$text, function(x) sum(get_sentiment(get_sentences(as.character(x)),  method = "bing") < 0)))
d$posCount <- unlist(lapply(d$text, function(x) sum(get_sentiment(get_sentences(as.character(x)),  method = "bing") > 0)))
d$neutCount <- unlist(lapply(d$text, function(x) sum(get_sentiment(get_sentences(as.character(x)), method = "bing") == 0)))

write.csv(d, paste(loc, 'sentiment.csv', sep=""), row.names=FALSE)

review<- get_sentences(as.character(d$text[1]))
length(review)
sent <- sum(get_sentiment(review, method="bing") > 0)
