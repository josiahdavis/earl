# Create subset of yelp data for analysis

loc <- '/Users/josiahdavis/Documents/DraftBlog/yelp_dataset_challenge_academic_dataset/'

# Read in business attributes
db <- read.csv(paste(loc, 'yelp_academic_dataset_business.csv', sep=""))

# Subset to only include Verizon Wireless business information
db <- db[grepl("Verizon Wireless", db$name),]

# Read in review text
dr <- read.csv(paste(loc, 'yelp_academic_dataset_review.csv', sep=""), sep=",")

# Subset to only include those for Verizon Wireless
dr <- dr[dr$business_id %in% db$business_id, ]

# Write subset data
newLoc <- '/Users/josiahdavis/Documents/GitHub/earl/'
write.csv(db, paste(newLoc, 'yelp_business.csv', sep=""), row.names=FALSE)
write.csv(dr, paste(newLoc, 'yelp_review.csv', sep=""), row.names=FALSE)