# Create subset of yelp data for analysis

# Clear working space
rm(list = ls())
gc()

# Read in business attributes
loc <- '/Users/josiahdavis/Documents/DraftBlog/yelp_dataset_challenge_academic_dataset/'
db <- read.csv(paste(loc, 'yelp_academic_dataset_business.csv', sep=""))

# Read in review text
dr <- read.csv(paste(loc, 'yelp_academic_dataset_review.csv', sep=""), sep=",")

# Subset to only include business information for coffee shops
db <- db[grepl("Coffee & Tea", db$categories) | 
          grepl("Clothing", db$categories) | 
           grepl("Banks", db$categories) | 
           grepl("Ice Cream & Frozen Yogurt", db$categories),]

# Subset to only include particular stores of interest
botiqueCoffee <- c("Dutch Bros Coffee", "Second Cup", "Costa Coffee", "Crazy Mocha Coffee", 
           "Crazy Mocha Coffee Co", "Java U", "Lola Coffee", "Affogato", "Beanscene", 
           "Bevande Coffee", "Blynk Organic", "Bunna Coffee", "Cafe Java U", 
           "Saxby's Coffee", "The Roasted Bean")

clothing <- c("Kohl's Department Stores", "JCPenney", "Men's Wearhouse",
              "Gap", "Banana Republic", "Urban Outfitters", "American Apparel",
              "Forever 21", "Old Navy", "Anthropologie")

banks <- c("Wells Fargo Bank", "Bank of America", "Chase Bank")

iceCream <- c("Cold Stone Creamery", "Dairy Queen", "Baskin Robbins", "Baskin-Robbins")

shops <- c(banks, clothing, botiqueCoffee, iceCream)

db <- db[db$name %in% shops,]

# Subset reviews to only include those from the businesses of interest
dr <- dr[dr$business_id %in% db$business_id, ]
dim(dr)

db$industry <- ifelse(grepl("Coffee & Tea", db$categories), "Coffee", 
                      ifelse(grepl("Banks", db$categories), "Banking", 
                             ifelse(grepl("Ice Cream",db$categories), "Ice Cream","Clothing")
                             )
                      )

# Add business information into the main dataframe
d <- merge(dr, db[,c("business_id", "name", "categories", "city", "state", "industry")],
      by = "business_id", all.x = TRUE, all.y = FALSE)


# Subset for only major states
states <- c("AZ", "NV", "NC", "PA", "WI", "IL", "SC")
d <- d[d$state %in% states,]

# Filter out German records
d <- d[!(grepl(pattern = "das", x = d$text)) & 
           !(grepl(pattern = "haw", x = d$text)) & 
           !(grepl(pattern = "tres", x = d$text)),]

# Write subset data into seperate files for industries
newLoc <- '/Users/josiahdavis/Documents/GitHub/earl/'
industries <- names(summary(d$industry))
for (i in industries){
  fn <- paste(newLoc, 'yelp_review_', i, '.csv', sep="")
  write.csv(d[d$industry == i,], fn, row.names=FALSE)
}

# Write out complete file
write.csv(d, paste(newLoc, 'yelp_review.csv', sep=""), row.names=FALSE)