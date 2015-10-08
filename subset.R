# Create subset of yelp data for analysis

# Clear working space
rm(list = ls())
gc()

# Read in business attributes
loc <- '/Users/josiahdavis/Documents/DraftBlog/yelp_dataset_challenge_academic_dataset/'
db <- read.csv(paste(loc, 'yelp_academic_dataset_business.csv', sep=""))

# Subset to only include business information for coffee shops
db <- db[grepl("Coffee & Tea", db$categories),]

# Read in review text
dr <- read.csv(paste(loc, 'yelp_academic_dataset_review.csv', sep=""), sep=",")

# Subset reviews to only include those from the businesses of interest
dr <- dr[dr$business_id %in% db$business_id, ]
dim(dr)

# Add business information into the main dataframe
d <- merge(dr, db[,c("business_id", "name", "categories", "city", "state")],
      by = "business_id", all.x = TRUE, all.y = FALSE)

# Subset for only major states
states <- c("AZ", "NV", "NC", "PA", "WI", "IL", "SC")
d <- d[d$state %in% states,]

# Subset only for Starbucks records (also filter out German records)
dr <- dr[(dr$name == "Starbucks") & 
           (dr$votes_useful > 0) &
           !(grepl(pattern = "das", x = dr$text)) & 
           !(grepl(pattern = "haw", x = dr$text)) & 
           !(grepl(pattern = "tres", x = dr$text)),]


# Write subset data
newLoc <- '/Users/josiahdavis/Documents/GitHub/earl/'
write.csv(d, paste(newLoc, 'yelp_review.csv', sep=""), row.names=FALSE)
