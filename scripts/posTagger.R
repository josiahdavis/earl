# =====================================
# ANALYSIS OF YELP REVIEWS
# TOPIC MODELING
# =====================================

# Clear working space
rm(list = ls())
gc()

# Load packages

library(tm)
library(openNLP)

# Load the Data and subset
loc <- '/Users/josiahdavis/Documents/GitHub/earl/data/'
dr <- read.csv(paste(loc, 'yelp_review.csv', sep=""))

# Conver to list of strings
texts <- lapply(dr$text, as.String)

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
texts_annotated <- lapply(texts, function(x) annotate_entities(x, tagging_pipeline))

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
nouns <- lapply(texts_annotated, function(x) POSGetter(x, c("JJ", "JJR", "JJS", "NN", "NNS", "NNP", "NNPS")))

# Turn each character vector into a single string
nouns <- lapply(nouns, as.String)

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

# Remove initial list of stopwords
stopwords <- c(stopwords("english"), "bank", "bofa", "boa", "wells", 
               "fargo", "america", "chase", "thing", "branch", "location", 
               "locations", "banking", "account")

d <- tm_map(d, removeWords, stopwords)

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

mostFrequentWords <- colSums(dtm)[order(colSums(dtm), decreasing = TRUE)]
mostFrequentWords[1:100]

# =====================================
# Perform Latent 
# Dirichlet Allocation 
# =====================================

subs <- dtm
subs <- subs[which(dr$stars <= 3),]
subs <- subs[rowSums(subs) > 5,colSums(subs) > 5]

# Start out using small number of topics for interpretability
lda <- LDA(subs, 3)

# Create interactive visualization for exploration
json <- createJSON(phi = posterior(lda)$terms, 
                   theta = lda@gamma,            # Documents x Topics
                   doc.length = rowSums(subs),   # Number of terms in each document
                   vocab = colnames(subs),       # Names of each term
                   term.frequency = colSums(subs),
                   R = 20)

# Launch the interactive visualization
serVis(json)

# ==========
# Add topical information into core dataframe
# ==========

write.csv(wordsTopics, paste(loc, 'wordsTopics.csv', sep=""), row.names=FALSE)
