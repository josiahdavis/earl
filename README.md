## Progress
* Downloaded the [Yelp Dataset](http://www.yelp.com/dataset_challenge).
* Created a subset of Yelp Reviews for a particular company ([script](/subset.R))
* Removed stopwords, tokenized the review text, and listed the most common words, their associated positivity, negativity ([script](/wordCounts.R)).

## Next Steps
* Identify when a person was mentioned within a review using [OpenNLP](https://cran.r-project.org/web/packages/openNLP/openNLP.pdf)
* Determine the sentiment of a sentance using [syuzhet](https://cran.r-project.org/web/packages/syuzhet/index.html)
* Compare the sentiment of a sentance with the Yelp Rating
* Create a topic model and use [LDAvis](https://github.com/cpsievert/LDAvis) to visualize and interpret.
* Determine the best number of topics using [bayesian model selection](http://cpsievert.github.io/projects/615/xkcd/)

## Objectives
* Identify the most informative topics within a review.
* Create a visualization that displays these topics.
* Demonstrate the connection between topics and the reviews themselves.
