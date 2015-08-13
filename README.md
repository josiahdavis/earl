## Progress
* Downloaded the [Yelp Dataset](http://www.yelp.com/dataset_challenge).
* Created a subset of Yelp Reviews for a particular company ([script](/subset.R))
* Removed stopwords, tokenized the review text, and listed the most common words, their associated positivity, negativity ([script](/wordCounts.R)).

## Next Steps
* Identify Parts of Speech within a review.
  * When was a person mentioned?
  * Are nouns and verbs more informative than adjectives?
* Come up with a better way to quantify the interestingness of a word.
  * Update the list of stopwords to remove all domain specific stop words.
  * Compare the  the sentiment of the word with the rating of the review.

## Objectives
* Identify the most informative topics within a review.
* Create a visualization that displays these topics.
* Demonstrate the connection between topics and the reviews themselves.
