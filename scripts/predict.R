# ============================
# SCRIPT FOR PREDICTING THE 
# USEFULNESS OF A REVIEW
# ============================

# Identify bigrams and trigrams amongst nouns and adjectives
# Predict the usefulness of the review using this dtm

rm(list = ls()); gc()

library(tm)
library(openNLP)
library(magrittr)
library(randomForest)
library(glmnet)

loc <- '/Users/josiahdavis/Documents/GitHub/earl/'
dr <- read.csv(paste(loc, 'yelp_review.csv', sep=""))
dr <- dr[(dr$industry == "Banking"),]

# Conver to list of strings
texts <- lapply(dr$text, as.String)

# =====================================
# Identify and reviews to 
# only include nouns
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

# Remove initial list of stopwords
stopwords <- c(stopwords("english"), "bank", "bofa", "boa", "wells", 
               "fargo", "america", "chase", "thing", "branch", "location", 
               "locations", "banking", "account")

d <- tm_map(d, removeWords, stopwords)

# Read in list of 5000+ stopwords compiled by Matthew Jockers
fileStopwords <- paste(loc, 'stopwords.txt', sep="")
stopwords <- readChar(fileStopwords, file.info(fileStopwords)$size)
stopwords <- unlist(strsplit(stopwords, split=", "))

# NEED TO MAKE THIS MORE EFFECIENT
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
  unlist(lapply(ngrams(words(x), c(1, 2)), paste, collapse = " "), use.names = FALSE)  
}

# Convert to a document term matrix (rows are documents, columns are words)
dtm <- as.matrix(DocumentTermMatrix(d, control = list(tokenize = BigramTokenizer, 
                                                      weighting = weightTfIdf)))
idxs <- order(colSums(dtm), decreasing = TRUE)[1:1500]
dtm <- dtm[,idxs]

# ==========================
# CREATE PREDICTIVE MODEL
# ==========================

# Define the model specification
y <- as.factor(dr$votes_useful > 0)
x <- dtm

# Split into test and training examples
idxs <- sample(dim(dtm)[1], 500, replace=FALSE)
xTrain <- x[idxs,]
yTrain <- y[idxs]
xTest <- x[-idxs,]
yTest <- y[-idxs]

# Train a random forest model on the text
m <- randomForest(y = yTrain, x = xTrain, mtry = 70, ntree = 150)
lm <- glmnet(y = yTrain, x = xTrain, family = "binomial")

# Evaluate the prediction accuracy
p <- predict(lm, xTest, type = "class")
sum(yTest == TRUE) / length(yTest)
sum(p == yTest) / length(yTest)
sum(p[which(yTest == TRUE)] == yTest[which(yTest == TRUE)]) / 
              length(yTest[which(yTest == TRUE)])
sum(p[which(yTest == FALSE)] == yTest[which(yTest == FALSE)]) / 
              length(yTest[which(yTest == FALSE)])

# Create a dataframe
df <- data.frame(importance = m$importance)
df$words <- row.names(m$importance)
row.names(df) <- 1:nrow(df)
head(df, 15)

# Most frequent words are most associated with service and friendliness