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

# Load the Data
loc <- '/Users/josiahdavis/Documents/GitHub/earl/'
dr <- read.csv(paste(loc, 'yelp_review.csv', sep=""))
str(dr)

# Conver to list
texts <- dr[1:500,]$text
texts <- lapply(texts, as.String)

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

typeof(POSGetter(texts_annotated[[2]], c("NN", "NNS", "NNP", "NNPS")))

typeof(POSGetter(texts_annotated[[2]], c("fasdasd", "afasda")))

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

# Remove stopwords
stopwords <- c(stopwords("english"), "bank", "bofa", "boa", "wells", 
               "fargo", "america", "chase", "thing")
d <- tm_map(d, removeWords, stopwords)

# Strip whitespace
d <- tm_map(d, stripWhitespace)

# Convert to a document term matrix (rows are documents, columns are words)
dtm <- DocumentTermMatrix(d)
dim(dtm)

# Look up most frequent terms
dtmd <- as.matrix(dtm)
freq <- colSums(dtmd)
ord <- order(freq, decreasing = TRUE)
freq[head(ord, 100)]

# Subset to only include words appear at least a couple times
dtmd <- dtmd[,freq > 5]

# =====================================
# Perform Latent 
# Dirichlet Allocation 
# =====================================

# Start out using small number of topics purely for interpretability
lda <- LDA(dtmd, 5)

# Top 10 terms for each topic
terms <- terms(lda, 10)
terms

# Most likely topic for each document
topics <- topics(lda, 5)
topics

# =====================================
# Create JSON for the 
# LDAvis package
# =====================================
json <- createJSON(phi = posterior(lda)$terms, 
                   theta = lda@gamma,
                   doc.length = rowSums(dtmd),
                   vocab = colnames(dtmd),
                   term.frequency = colSums(dtmd))

# Launch the interactive visualization
serVis(json)
