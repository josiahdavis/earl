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
nounsS <- nouns %>% lapply(as.String)

# =====================================
# Perform text mining 
# transformations
# =====================================

# Conver to dataframe
d <- data.frame(reviews = as.character(nounsS))

# Replace new line characters with spaces
d$reviews <- gsub("\n", " ", d$reviews)
head(d)
# Convert the relevant data into a corpus object with the tm package
d <- Corpus(VectorSource(d$reviews))

# Convert everything to lower case
d <- tm_map(d, content_transformer(tolower))

# Remove stopwords (generic)
d <- tm_map(d, removeWords, c(stopwords("english"), "\n"))

# Strip whitespace
d <- tm_map(d, stripWhitespace)

# Convert to a document term matrix (rows are documents, columns are words)
dtm <- DocumentTermMatrix(d)
dim(dtm)

# Look up most frequent terms
freq <- colSums(as.matrix(dtm))
ord <- order(freq)
freq[tail(ord, 50)]

# Subset to only include words appearing at least 10 times
top <- findFreqTerms(dtm, lowfreq=10)
dtmd <- as.matrix(dtm)
dtmd <- dtmd[,top]
dim(dtm)
dtmd <- dtmd[rowSums(dtmd) > 0,]
dim(dtmd)

# =====================================
# Perform Latent 
# Dirichlet Allocation 
# =====================================

# Start out using three topics (easier to intpret smaller number of topics)
lda <- LDA(dtmd, 3)

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

serVis(json)
