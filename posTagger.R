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

# Load the Data
loc <- '/Users/josiahdavis/Documents/GitHub/earl/'
dr <- read.csv(paste(loc, 'yelp_review.csv', sep=""))
str(dr)

# Conver to list
texts <- dr$text
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
               "fargo", "america", "chase", "thing", "branch", "location", 
               "locations", "banking", "account")
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
dtmd <- dtmd[rowSums(dtmd) > 0,]

# =====================================
# Perform Latent 
# Dirichlet Allocation 
# =====================================

# Start out using small number of topics purely for interpretability
lda <- LDA(dtmd, 3)

# Top 10 terms for each topic
terms <- terms(lda, 10)

# Most likely topic for each document
topics <- topics(lda, 5)

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

# =====================================
# Calculate the saliency and relevancy scores
# This code copied from the LDAVis package
# =====================================

# THETA -- Probability Distribution of Topics across documents
# For a given document, what % of the document is topic i?
theta = lda@gamma
head(theta)

# Number of terms/words in each document
doc.length = rowSums(dtmd)

# PHI -- Probability Distribution of Words across Topics
# For a given topic, what % of the topic is word j?
phi <- posterior(lda)$terms
head(phi)


# compute counts of tokens across K topics (length-K vector):
# (this determines the areas of the default topic circles when no term is 
# highlighted)
topic.frequency <- colSums(theta * doc.length)
topic.proportion <- topic.frequency/sum(topic.frequency)

# re-order the K topics in order of decreasing proportion:
o <- order(topic.proportion, decreasing = TRUE)
phi <- phi[o, ]
theta <- theta[, o]
topic.frequency <- topic.frequency[o]
topic.proportion <- topic.proportion[o]


# token counts for each term-topic combination (widths of red bars)
term.topic.frequency <- phi * topic.frequency  

# compute term frequencies as column sums of term.topic.frequency
# we actually won't use the user-supplied term.frequency vector.
# the term frequencies won't match the user-supplied frequencies exactly
# this is a work-around to solve the bug described in Issue #32 on github:
# https://github.com/cpsievert/LDAvis/issues/32
term.frequency <- colSums(term.topic.frequency)

# marginal distribution over terms (width of blue bars)
term.proportion <- term.frequency/sum(term.frequency)

# Most operations on phi after this point are across topics
# R has better facilities for column-wise operations
phi <- t(phi)

# compute the distinctiveness and saliency of the terms:
# this determines the R terms that are displayed when no topic is selected
topic.given.term <- phi/rowSums(phi)  # (W x K)
kernel <- topic.given.term * log(sweep(topic.given.term, MARGIN=2, 
                                       topic.proportion, `/`))
distinctiveness <- rowSums(kernel)
saliency <- term.proportion * distinctiveness
head(saliency)

# Dataframe #1: Word Saliencies
wordsSaliency <- data.frame(words = names(saliency), saliency = unname(saliency))

# Dataframe #2 and 3: Lift, Phi, and Relevance (NOT WORKING YET)
lift <- phi/term.proportion
liftLong <- melt(lift)
names(liftLong) <- c("words", "topics", "lift")
phiLong <- melt(phi)
names(phiLong) <- c("words", "topics", "phi")

i = 0.5
relevance <- i*log(phi) + (1 - i)*log(lift)
relevance <- melt(relevance)
names(relevance) <- c("words", "topics", "relevance")
# =====================================
# Create a csv of the words, and key 
# metrics associated with them
# =====================================

# Dataframe #4: distribution of words across topics
wordsTopics <- as.data.frame(posterior(lda)$terms)
wordsTopics$topics = 1:nrow(wordsTopics)
wordsTopics <- melt(wordsTopics, id="topics")
colnames(wordsTopics) <- c("topics", "words", "probability")

# Dataframe #5: Calculate the word frequencies
wordsFreq <- data.frame(words = names(colSums(dtmd)),
                          frequency = unname(colSums(dtmd)))

# Merge the dataframes together
wordsTopics <- merge(wordsTopics, wordsFreq, on = "words", all = TRUE)
wordsTopics <- merge(wordsTopics, wordsSaliency, on = "words", all = TRUE)
wordsTopics <- merge(wordsTopics, liftLong, on = c("words", "topics"), all = TRUE)
wordsTopics <- merge(wordsTopics, phiLong, on = c("words", "topics"), all = TRUE)
wordsTopics <- merge(wordsTopics, relevance, on = c("words", "topics"), all = TRUE)
write.csv(wordsTopics, paste(loc, 'wordsTopics.csv', sep=""), row.names=FALSE)
