# ANALYSIS OF YELP DATA

# Read in data
loc <- '/Users/josiahdavis/Documents/GitHub/earl/'
db <- read.csv(paste(loc, 'yelp_business.csv', sep=""))
dr <- read.csv(paste(loc, 'yelp_review.csv', sep=""))

# -----------------------------------
# Look up the most frequent terms

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
        "get", "time", "back", "didnt", "walk", "great")
d <- tm_map(d, removeWords, sw)

# Stem the stopwords using a snowball stemmer
#tm_map(Corpus(VectorSource("clothe clothes clothed clothing")), stemDocument)[[1]]$content #example
#d <- tm_map(d, stemDocument)


# Strip whitespace
d <- tm_map(d, stripWhitespace)

# Convert to a document term matrix (rows are documents, columns are words)
require(tm)
dtm <- DocumentTermMatrix(d, control = list(weighting = weightTfIdf))
dtm2 <- DocumentTermMatrix(d)

# Collect the frequency, the tf idf, the positivity, and the negativity into a single dataframe
words <- data.frame(counts = colSums(as.matrix(dtm2)))
words$tfidf <- colSums(as.matrix(dtm))
words$positivity <- colSums(as.matrix(dtm2)[dr$stars > 3,]) / dim(dtm)[1]
words$negativity <- colSums(as.matrix(dtm2)[dr$stars < 4,]) / dim(dtm)[1]
words$sentiment <- words$positivity / words$negativity
words$words <- row.names(words)
row.names(words) <- 1:dim(dtm)[2]

head(words[order(words$sentiment, decreasing = FALSE) & words$counts > 10,], 10)

# Sanity checking
words[words$words == 'iphone',]
colSums(as.matrix(dtm))['iphone']

# Write resulting file out to csv
write.csv(words, paste(loc, 'words.csv', sep=""), row.names=FALSE)

# TO DO
# Identify the context of common words in the review text. 
#     (e.g., for a given word, find all sentances containing that word)
# Identify most common bi-grams and tri-grams in addition to words
# Incorporate coolness, humor and usefulness measures into words dataframe
