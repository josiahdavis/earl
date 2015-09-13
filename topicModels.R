# ANALYSIS OF YELP DATA
# This script groups topics within Yelp Reviews


# =====================================
# ---- To-Do ----
# Filter out more stop words 
# Choose business to analyze
# Filter out non-noun words
# =====================================



# =====================================
# Load packages 
# and prepare data
# =====================================

# Load packages
library(LDAvis)
library(RTextTools)
library(topicmodels)
library(SnowballC)
library(tm)

# Load the Data
loc <- '/Users/josiahdavis/Documents/GitHub/earl/'
dr <- read.csv(paste(loc, 'yelp_review.csv', sep=""))
str(dr)

# Convert the relevant data into a corpus object with the tm package
d <- Corpus(VectorSource(dr$text))

# View a particular review and rating
print(paste("(",dr$stars[10],"stars)", d[[10]]$content))

# Convert everything to lower case
d <- tm_map(d, content_transformer(tolower))

# Remove numbers
d <- tm_map(d, removeNumbers)

# Remove punctuation
d <- tm_map(d, removePunctuation)

# Perform specific transfomrations (Good way to handle misspellings and acronyms)
# transformString <- content_transformer(function(x, from, to) gsub(from, to, x))
# d <- tm_map(d, transformString, "servcie", "service")

# Remove stopwords (generic)
d <- tm_map(d, removeWords, stopwords("english"))

# Remove stopwords (specific to context)
sw <- c("verizon", "can", "even", "said", "went", "get")
d <- tm_map(d, removeWords, sw)

# Stem the stopwords using a snowball stemmer
# tm_map(Corpus(VectorSource("clothe clothes clothed clothing")), stemDocument)[[1]]$content
d <- tm_map(d, stemDocument)

# Strip whitespace
d <- tm_map(d, stripWhitespace)

# Convert to a document term matrix (rows are documents, columns are words)
dtm <- DocumentTermMatrix(d)
dim(dtm)

# Look up most frequent terms
freq <- colSums(as.matrix(dtm))
ord <- order(freq)
freq[tail(ord, 25)]

# Subset to only include words appearing at least 10 times
top <- findFreqTerms(dtm, lowfreq=10)
dtmd <- as.matrix(dtm)
dtmd <- dtmd[,top]
dim(dtm)
dim(dtmd)  # Reduce from 36xx to 5xx terms


# =====================================
# Perform Latent 
# Dirichlet Allocation 
# =====================================

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

# =====================================
# Find the ideal 
# number of topics
# =====================================

df <- data.frame(matrix(nrow=5, ncol=2))
names(df) <- c("topics", "ll")
count = 1;
for(i in seq(from = 2, to = 5, by = 1)){
  mod <- LDA(dtmd, i)
  df$topics[count] <- i
  df$ll[count] <- sum(mod@loglikelihood)
  count = count + 1
}


library(ggplot2)
ggplot(df, aes(x=topics, y=ll)) + 
  xlab("Number of topics") + ylab("Log likelihood of the model") + 
  geom_point() +
  geom_line() +
  theme_bw()  + 
  theme(axis.title.x = element_text(vjust = -0.25, size = 14)) + 
  theme(axis.title.y = element_text(size = 14, angle=90))

# =====================================
# Detailed 
# Exploration
# =====================================

# Print the first document
d[[1]]$content

# Print the probabilities associating topics with documents (for the first document)
lda@gamma[1:5,]

# Print the topic of the 1st document
which.max(lda@gamma[1,])

# Alternatively...
topics[1]

# Print the "probabilities" associating words with topics (for the 3rd topic)
lda@beta[3,]

# Print out the top 10 words for the 3rd topic (Topic 3 is most likely to map to the 1st document)
idxs <- match( sort(lda@beta[3,], decreasing = TRUE)[1:10], lda@beta[3,])
attributes(dtmd)$dimnames$Terms[idxs]

# Alternatively....
terms[,3]

# =====================================
# Additional notes
# and Experimentation
# =====================================

# A simple_triplet_matrix is a sparse matrix
str(matrix)

# A simple_triplet_matrix can be converted to a matrix
matrix_array <- as.matrix(matrix)
matrix_array[1:10, 1:20]