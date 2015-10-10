# REGRESSION
# Poisson Regression may be appropriate

# Load the Data
loc <- '/Users/josiahdavis/Documents/GitHub/earl/'
dr <- read.csv(paste(loc, 'yelp_review_Banking.csv', sep=""))

mg <- glm(votes_useful ~ age + entropy, family="poisson", data=dr)
summary(mg) # Both age and entropy are significant
gp <- predict.glm(mg, dr[,c("age", "entropy")],  type = "response")

# THIS PART NOT WORKING YET
dtm_new <- cbind(dr$votes_useful, dtm[,order(colSums(dtm), decreasing = TRUE)[1:500]])
dtm_new <- dtm_new[,colSums(dtm_new) > 0]
dtm_new <- data.frame(dtm_new)
names(dtm_new)[1] <- "votes_useful"
mg <- glm(votes_useful ~ paste0(names(dtm_new)[-1], collapse = " + "), family="poisson", data=dtm_new)
summary(mg)