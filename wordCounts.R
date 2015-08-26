# ANALYSIS OF YELP DATA
# This script tokenizes each review, removes stopwords, identifies the most common words, and 
# quantifies positivity and negativity associated with each word. The main packaged used thus far is tm.


# Read in data
loc <- '/Users/josiahdavis/Documents/GitHub/earl/'
db <- read.csv(paste(loc, 'yelp_business.csv', sep=""))
dr <- read.csv(paste(loc, 'yelp_review.csv', sep=""))

# Convert the relevant data into a corpus object with the tm package
require(tm)
d <- Corpus(VectorSource(dr$text))

# Convert everything to lower case
d <- tm_map(d, content_transformer(tolower))

# Remove numbers
d <- tm_map(d, removeNumbers)

# Remove punctuation
d <- tm_map(d, removePunctuation)

# Perform specific transfomrations (Good way to handle misspellings and acronyms)
transformString <- content_transformer(function(x, from, to) gsub(from, to, x))
d <- tm_map(d, transformString, "servcie", "service")

# Remove stopwords (generic)
d <- tm_map(d, removeWords, stopwords("english"))

# Remove stopwords (specific to context)
sw <- c("verizon", "wireless", "phone", "store", "service", "customer", "help", 
        "get", "time", "back", "didnt", "walk", "great", "vzw")
d <- tm_map(d, removeWords, sw)

# Strip whitespace
d <- tm_map(d, stripWhitespace)

# Convert to a document term matrix (rows are documents, columns are words)
require(tm)
dtm <- DocumentTermMatrix(d, control = list(weighting = weightTfIdf))
dtm2 <- DocumentTermMatrix(d)

# Collect the frequency, the tf idf, the positivity, and the negativity into a single dataframe
words <- data.frame(counts = colSums(as.matrix(dtm2)))
words$tfidf <- colMeans(as.matrix(dtm))
words$positivity <- colSums(as.matrix(dtm2)[dr$stars > 3,]) / dim(dtm)[1]
words$negativity <- colSums(as.matrix(dtm2)[dr$stars < 4,]) / dim(dtm)[1]
words$sentiment <- ifelse(words$positivity / words$negativity == Inf, 
                          0,
                          words$positivity / words$negativity)
words$words <- row.names(words)
row.names(words) <- 1:dim(dtm)[2]

# Interpret the output
words <- words[words$counts > 10,]
head(words[order(words$counts, decreasing = TRUE), c('words', 'counts')], 15)
head(words[order(words$tfidf, decreasing = TRUE), c('words', 'tfidf')], 15)
head(words[order(words$sentiment, decreasing = TRUE), c('words', 'sentiment', 'counts')], 15)

# Sanity checking
words[words$words == 'iphone',]
colSums(as.matrix(dtm))['iphone']

# Write resulting file out to csv
write.csv(words, paste(loc, 'words.csv', sep=""), row.names=FALSE)
