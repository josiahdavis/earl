# ANALYSIS OF YELP DATA
# This script performs a number of NLP techniques including:
#   - Tagging Parts of Speech
#   - Filtering for only Nouns and Adjectives
#   - Removing Stopwords
#   - Stemming Words
#   - Identifying Common Unigrams Bigrams and Trigrams

# Clear working space
rm(list = ls()); gc()

# Load packages
library(magrittr)
library(tm)
library(openNLP)

# Read in dataframe of reviews
loc <- '/Users/josiahdavis/Documents/GitHub/earl/data/'
d <- read.csv(paste(loc, 'yelp_review_Macys.csv', sep=""))

# Conver to list of strings
texts <- lapply(d$text, as.String)

# =====================================
# Identify and reviews to 
# only include nouns and adjectives
# =====================================

# Define types of annotations to perform
tagging_pipeline <- list(
  Maxent_Sent_Token_Annotator(),
  Maxent_Word_Token_Annotator(),
  Maxent_POS_Tag_Annotator()
)

# Define function for performing the annotations
annotate_entities <- function(doc, annotation_pipeline) {
  annotations <- annotate(doc, annotation_pipeline)
  AnnotatedPlainTextDocument(doc, annotations)
}

# Annotate the texts
texts_annotated <- texts %>% lapply(annotate_entities, tagging_pipeline)
str(texts_annotated[[1]], max.level = 2)

# Define the POS getter function 
POSGetter <- function(doc, parts) {
  s <- doc$content
  a <- annotations(doc)[[1]]
  k <- sapply(a$features, `[[`, "POS")
  if(sum(k %in% parts) == 0){
    ""
  }else{
    s[a[k %in% parts]]
  }
}

# Identify the nouns
nouns <- texts_annotated %>% lapply(POSGetter, parts = c("JJ", "JJR", "JJS", "NN", "NNS", "NNP", "NNPS"))

# Turn each character vector into a single string
nouns <- nouns %>% lapply(as.String)

# =====================================
# Perform text mining 
# transformations
# =====================================

# Conver to dataframe
d <- data.frame(reviews = as.character(nouns))

# Replace new line characters with spaces
d$reviews <- gsub("\n", " ", d$reviews)

# Convert the relevant data into a corpus object with the tm package
d <- Corpus(VectorSource(d$reviews))

# Convert everything to lower case
d <- tm_map(d, content_transformer(tolower))

# Read in list of 5000+ stopwords compiled by Matthew Jockers
fileStopwords <- paste(loc, 'stopwords.txt', sep="")
stopwords <- readChar(fileStopwords, file.info(fileStopwords)$size)
stopwords <- unlist(strsplit(stopwords, split=", "))

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

# Stem words
d <- tm_map(d, stemDocument)

# Strip whitespace
d <- tm_map(d, stripWhitespace)

# Define bigram tokenizer
BigramTokenizer <- function(x) {
  unlist(lapply(ngrams(words(x), c(1, 2)), paste, collapse = " "), use.names = FALSE)  
}

# Convert to a document term matrix (rows are documents, columns are words)
dtm <- as.matrix(DocumentTermMatrix(d, control = list(tokenize = BigramTokenizer)))

# Remove elements with less than 3 words
dtm <- dtm[,colSums(dtm) >= 3]
dtm <- cbind(d$stars, dtm)
colnames(dtm)[1] <- "stars"

# Calculate words length
dtm <- cbind(apply(dtm, MARGIN = 1, FUN = sum), dtm)
colnames(dtm) <- "wordsLength"

# Write to csv file
write.csv(dtm, paste(loc, 'dtm.csv', sep=""), row.names=FALSE)
