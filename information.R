# CALCULATE INFORMATION DENSITY

# Load the Data
loc <- '/Users/josiahdavis/Documents/GitHub/earl/'
dr <- read.csv(paste(loc, 'yelp_review_Banking.csv', sep=""))

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

for (i in 1:5){
  if(i == 1){
    start <- 1
  }else{
    start <- i * 1000
  }
  
  if(i < 5){
    end <- (i + 1) * 1000
  }else{
    end <- 5805
  }
  d <- tm_map(d, removeWords, stopwords[start:end])
}

# Remove punctuation
d <- tm_map(d, removePunctuation)

# Strip whitespace
d <- tm_map(d, stripWhitespace)

# Convert to a document term matrix (rows are documents, columns are words)
dtm <- as.matrix(DocumentTermMatrix(d))

# Define Review Internal Entropy Function
reviewEntropy <- function(x) { 
  probWordReview <- x / sum(x)
  N = sum(x)
  product <- probWordReview * log2(probWordReview)
  product <- product[!is.na(product)]
  ent <- ( -1 / N ) * sum(product)
  ent
}

# Apply to the entire Document Term Matrix
dr$entropy <- apply(dtm, MARGIN = 1, FUN = reviewEntropy)
dr$wordsLength <- apply(dtm, MARGIN = 1, FUN = sum)