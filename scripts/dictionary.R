# ====================
# WORD COUNTS BASED ON 
# A DICTIONARY
# =====================

library(stringr)

# Clear working space
rm(list = ls()); gc()

# Load the Data
loc <- '/Users/josiahdavis/Documents/GitHub/earl/data/'
d <- read.csv(paste(loc, 'yelp_review_Macys.csv', sep=""))

# Define the dictionary of words and word patterns
words <- c("Management" = "\\b[Mm]anage[rsment]*\\b",
           "Jewelry" = "\\b[Jj]ewelry\\b|\\b[Rr]ing\\b|\\b[Ee]rr?ing\\b|\\b[Nn]ecklaces?\\b|\\b[Bb]racelets?\\b",
           "Macy's Card" = "\\b([Mm]acy'?s )?([Cc]redit )?[Cc]ards?\\b",
           "Returns" = "\\b[Rr]eturns?(ing)?\\b",
           "Location" = "\\b[Ll]ocation\\b",
           "Shoes" = "\\b[Ss]hoes?\\b|\\b[Hh]eels\\b|\\b[Ss]neakers\\b|\\b[Bb]oots?(ies)?\\b|\\b[Pp]umps\\b
                      |\\b[Ss]lippers?\\b",
           "Customer Service" = "\\b([Cc]ustomer )?[Ss]ervice\\b",
           "Associate" = "\\b[Aa]ssociates?\\b|\\b[Cc]lerks?\\b|\\b[Ee]mployees?\\b",
           "Purse" = "\\[Pp]urses?\\b|\\b[Hh]andbags?\\b",
           "Delivery" = "\\b[Dd]elivery\\b",
           "Website" = "\\b([Ww]eb)?[Ss]ite|[Oo]nline\\b",
           "Display" = "\\b[Dd]isplays?\\b",
           "Fashion" = "\\b[Ff]ashion\\b",
           "Dillard's" = "\\b[Dd]ill?ards?\\b",
           "Kohl's" = "\\b[Kk][oh]+l'?s\\b",
           "J.C. Penny's" = "\\b[Pp]enny'?s\\b",
           "Neiman Marcus" = "\\b[Nnei]+man [Mm]arcus\\b",
           "Register" = "\\b[Rr]egisters?\\b",
           "Time" = "\\b[Tt]im[eing]+\\b|\\b[Hh]ours?\\b|[Mm]inutes?\\b",
           "Deal" = "\\b[Dd]eals?\\b|\\b[Dd]iscount(ed)?\\b|\\b[Ss]ales?\\b|\\b[Cc]learance\\b|\\b[Bb]argains?\\b",
           "Quality" = "\\b[Qq]uality\\b",
           "Clothing" = "\\b[Tt-]?[Ss]hirts?\\b|\\b[Ss]horts?\\b|\\b[Pp]ants?\\b|\\b[Ss]kirts?\\b|\\b[Ss]uit?s\\b
                        |\\b[Dd]ress(es)?\\b|\\b[Bb]louses?\\b|\\b[Ss]ocks\\b|\\b[Pp]olos?\\b|\\b[Jj]eans?\\b",
           "Clean" = "\\b[Cc]lean(liness)?\\b",
           "Cosmetics" = "\\b[Cc]osmetics\\b|\\b[Mm]akeup\\b|\\b[Ll]ipstick\\b|\\b[Pp]erfume\\b|\\b[Cc]ologne\\b",
           "Price" = "\\b[Pp]ric(es)?\\b",
           "Women" = "\\b[Ww]omens?\\b|\\b[Ff]emales?\\b",
           "Men" = "\\b[Mm]ens?\\b|\\b[Mm]ales?\\b",
           "Bedding" = "\\b[Bb]eds?d?(ing)?\\b|\\b[Ss]heets?\\b|[Pp]illows?\\b|\\b[Cc]omforters?\\b
                        |\\b[Dd]uvet\\b",
           "Wedding" = "\\b[Ww]edding\\b|\\b[Bb]rides?\\b|\\b[Gg]rooms?\\b|\\b[Rr]egistry\\b",
           "Mattress" = "\\b[Mm]attress(es)?\\b|\\b[Mm]emory [Ff]oam\\b",
           "Bathroom" = "\\b[Bb]athrooms?\\b",
           "Lamps" = "\\b[Ll]amps?\\b|\\b[Ll]ight(ing)?\\b",
           "Watches" = "\\b[Ww]atch(es)?\\b", 
           "Furniture" = "\\b[Ff]urniture\\b|\\b[Dd]resser\\b|\\b[Tt]ables?\\b|\\b[Ss]ofas?\\b
                          |\\b[Cc]hairs?\\b|\\b[Ss]tools?\\b|\\b[Cc]ouch(es)?\\b|\\b[Rr]ecliners?\\b")

# Count the words associated with a particular text
countWords <- function(w, x) {
  str_count(x, w)
}

## NEED TO FIX TO INCLUDE 2 WORD PHRASES, RIGHT NOW THAT IS NOT WORKING.

# Create the dictionary of word counts
dtm <- t(sapply(d$text, function(x) sapply(words, function(w) countWords(w, x) )))
dtm <- dtm[,colSums(dtm) > 0]
colSums(dtm)

# Add the stars into the matrix
dtm <- cbind(d$stars, dtm)
colnames(dtm)[1] <- "stars"

# Write out to csv in the wide format
write.csv(dtm, paste(loc, 'dictionaryWide.csv', sep=""), row.names=FALSE)

# Create a long version of the same file
dtmL <- t(ddply(data.frame(dtm), .(stars), colSums))
dtmL <- melt(dtmL[-1,])
colnames(dtmL) <- c("word", "stars", "counts")
write.csv(dtmL, paste(loc, 'dictionaryLong.csv', sep=""), row.names=FALSE)
