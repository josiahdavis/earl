# Create subset of yelp data for analysis

# Read in business attributes
loc <- '/Users/josiahdavis/Documents/DraftBlog/yelp_dataset_challenge_academic_dataset/'
db <- read.csv(paste(loc, 'yelp_academic_dataset_business.csv', sep=""))


# Which business categories are their? 
#     Arts & Entertainment,Performing Arts
#     Banks & Credit Unions,Financial Services
#     Breakfast & Brunch,Restaurants
#     Food,Coffee & Tea
summary(db$categories)

# How many businesses are labeled as various venus?
summary(db[grepl("Financial Services", db$categories),]$name)
summary(db[grepl("Coffee & Tea", db$categories),]$name)

# Subset to only include business information for one of three banks
db <- db[(db$name == "Bank of America") | (db$name == "Chase Bank") | (db$name == "Wells Fargo Bank"),]
dim(db)

# Read in review text
dr <- read.csv(paste(loc, 'yelp_academic_dataset_review.csv', sep=""), sep=",")

# Subset reviews to only include those for one of three banks
dr <- dr[dr$business_id %in% db$business_id, ]

# Add business information into the main dataframe
d <- merge(dr, db[,c("business_id", "name", "review_count", "stars", "state", "full_address")],
      by = "business_id", all.x = TRUE, all.y = FALSE)

# Write subset data
newLoc <- '/Users/josiahdavis/Documents/GitHub/earl/'
# write.csv(db, paste(newLoc, 'yelp_business.csv', sep=""), row.names=FALSE)
write.csv(d, paste(newLoc, 'yelp_review.csv', sep=""), row.names=FALSE)
