# CALCULATE INFORMATION DENSITY

# Clear working space
rm(list = ls())
gc()

# Load the Data
loc <- '/Users/josiahdavis/Documents/GitHub/earl/'
dr <- read.csv(paste(loc, 'yelp_review_Macys.csv', sep=""))

# Convert the relevant data into a corpus object with the tm package
d <- Corpus(VectorSource(dr$text))

# Convert everything to lower case
d <- tm_map(d, content_transformer(tolower))

# Read in list of 5000+ stopwords compiled by Matthew Jockers
fileStopwords <- paste(loc, 'stopwords.txt', sep="")
stopwords <- readChar(fileStopwords, file.info(fileStopwords)$size)
stopwords <- unlist(strsplit(stopwords, split=", "))

# Remove stopwords (loop through a set of stopwords at a time)
stopwords <- c(stopwords("english"), stopwords)
for (i in 0:4){
  start <- i*1000 + 1
  end <- (i + 1)*1000
  d <- tm_map(d, removeWords, stopwords[start:end])
  if(i == 4){
    start <- end
    end <- length(stopwords)
    d <- tm_map(d, removeWords, stopwords[start:end])
  }
}

# Remove punctuation
d <- tm_map(d, removePunctuation)

# Strip whitespace
d <- tm_map(d, stripWhitespace)

# Convert to a document term matrix (rows are documents, columns are words)
dtm <- as.matrix(DocumentTermMatrix(d))

# Calculate words length
dr$wordsLength <- apply(dtm, MARGIN = 1, FUN = sum)

# Write to csv
write.csv(dr, paste(loc, 'yelp_review_Macys.csv', sep=""), row.names=FALSE)
