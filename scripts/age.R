# CALCULATE THE AGE OF THE REVIEW
# Start at the first review date

library(dplyr)

# Load the Data
loc <- '/Users/josiahdavis/Documents/GitHub/earl/'
dr <- read.csv(paste(loc, 'yelp_review_Banking.csv', sep=""))
dr$date <- as.Date(dr$date, "%Y-%m-%d")
str(dr)

group <- group_by(dr, business_id)
earliestDate <- summarise(group, 
                          firstReview = min(date))

# Join by the business ID
dr <- left_join(dr, earliestDate, by = "business_id")

# Calculate the days since the opening and since date of last review
dr$daysSinceOpen <- as.numeric(dr$date - dr$firstReview)
dr$age <- as.numeric(max(dr$date) - dr$date)

# Write to csv
fn <- paste(newLoc, 'yelp_review_Banking.csv', sep="")
write.csv(dr, fn, row.names=FALSE)