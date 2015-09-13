# Create subset of yelp data for analysis

loc <- '/Users/josiahdavis/Documents/DraftBlog/yelp_dataset_challenge_academic_dataset/'

# Read in business attributes
db <- read.csv(paste(loc, 'yelp_academic_dataset_business.csv', sep=""))

# Which states are most representative?
summary(db$state)

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
db <- db[grepl("Bank of America", db$name) | grepl("Wells Fargo", db$name) | grepl("Chase Bank", db$name),]
dim(db)

# Read in review text
dr <- read.csv(paste(loc, 'yelp_academic_dataset_review.csv', sep=""), sep=",")

# Subset to only include those for Verizon Wireless
dr <- dr[dr$business_id %in% db$business_id, ]

# Write subset data
newLoc <- '/Users/josiahdavis/Documents/GitHub/earl/'
write.csv(db, paste(newLoc, 'yelp_business.csv', sep=""), row.names=FALSE)
write.csv(dr, paste(newLoc, 'yelp_review.csv', sep=""), row.names=FALSE)
