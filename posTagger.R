# =====================================
# ANALYSIS OF YELP REVIEWS
# TOPIC MODELING
# =====================================

# Clear working space
rm(list = ls())
gc()

# Load packages
library(NLP)
library(openNLP)
library(RWeka)
library(magrittr)
library(LDAvis)
library(RTextTools)
library(topicmodels)
library(SnowballC)
library(tm)
library(reshape)

# Load the Data and subset
loc <- '/Users/josiahdavis/Documents/GitHub/earl/'
dr <- read.csv(paste(loc, 'yelp_review.csv', sep=""))
dr <- dr[(dr$votes_useful > 0) & (dr$industry == "Banking"),]

# Conver to list of strings
texts <- lapply(dr$text, as.String)

# =====================================
# Identify and reviews to 
# only include nouns
# =====================================

# Define function for performing the annotations
annotate_entities <- function(doc, annotation_pipeline) {
  annotations <- annotate(doc, annotation_pipeline)
  AnnotatedPlainTextDocument(doc, annotations)
}

# Define types of annotations to perform
tagging_pipeline <- list(
  Maxent_Sent_Token_Annotator(),
  Maxent_Word_Token_Annotator(),
  Maxent_POS_Tag_Annotator()
)

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
nouns <- texts_annotated %>% lapply(POSGetter, parts = c("NN", "NNS", "NNP", "NNPS"))

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

# Remove initial list of stopwords
stopwords <- c(stopwords("english"), "bank", "bofa", "boa", "wells", 
               "fargo", "america", "chase", "thing", "branch", "location", 
               "locations", "banking", "account")

d <- tm_map(d, removeWords, stopwords)

# Read in list of 5000+ stopwords compiled by Matthew Jockers
fileStopwords <- paste(loc, 'stopwords.txt', sep="")
stopwords <- readChar(fileStopwords, file.info(fileStopwords)$size)
stopwords <- unlist(strsplit(stopwords, split=", "))

for (i in 1:5){
  if(i == 1){
    start <- 1
  }else{
    start <- i * 1000
  }
  
  if(i < 5){
    end <- (i + 1) * 1000
  }else{
    end <- 5631
  }
  d <- tm_map(d, removeWords, stopwords[start:end])
}

# Stem words
d <- tm_map(d, stemDocument)

# Strip whitespace
d <- tm_map(d, stripWhitespace)

# Define bigram tokenizer
BigramTokenizer <- function(x) {
  unlist(lapply(ngrams(words(x), 3), paste, collapse = " "), use.names = FALSE)  
}

# Convert to a document term matrix (rows are documents, columns are words)
dtm <- as.matrix(DocumentTermMatrix(d, control = list(tokenize = BigramTokenizer)))

# Create the document term matrix
tdm <- TermDocumentMatrix(crude, control = list(tokenize = BigramTokenizer))

# =====================================
# Perform Latent 
# Dirichlet Allocation 
# =====================================

for (i in 1:5){
  idxs <- 
}

# Start out using small number of topics purely for interpretability
lda <- LDA(dtms, 3)

# Create interactive visualization for exploration
json <- createJSON(phi = posterior(lda)$terms, 
                   theta = lda@gamma,
                   doc.length = rowSums(dtmd),
                   vocab = colnames(dtmd),
                   term.frequency = colSums(dtmd),
                   R = 10)

# Launch the interactive visualization
serVis(json)

# ==========
# Add topical information into core dataframe
# ==========

write.csv(wordsTopics, paste(loc, 'wordsTopics.csv', sep=""), row.names=FALSE)
