# Create subset of yelp data for analysis

# Clear working space
rm(list = ls())
gc()

# Read in business attributes
loc <- '/Users/josiahdavis/Documents/DraftBlog/yelp_dataset_challenge_academic_dataset/'
db <- read.csv(paste(loc, 'yelp_academic_dataset_business.csv', sep=""))


# Read in review text
dr <- read.csv(paste(loc, 'yelp_academic_dataset_review.csv', sep=""), sep=",")

# Subset to only include Macy's stores
db <- db[db$name == "Macy's",]
dr <- dr[dr$business_id %in% factor(db$business_id), ]
dim(dr)

# Add business information into the main dataframe
d <- merge(dr, db[,c("business_id", "name", "categories", "city", "state")],
      by = "business_id", all.x = TRUE, all.y = FALSE)

# Subet to only include variables of interest
d <- d[, c("business_id", "review_id", "date", "stars", "text", "votes_useful", "state", "city")]

# Write to csv
loc <- '/Users/josiahdavis/Documents/GitHub/earl/'
write.csv(d, paste(loc, 'yelp_review_Macys.csv', sep=""), row.names=FALSE)
