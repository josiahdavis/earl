## Progress
* Downloaded the [Yelp Dataset](http://www.yelp.com/dataset_challenge).
* Created a subset of Yelp Reviews for retail banks ([script](/subset.R))
* Removed standard stopwords, tokenized the review text, and listed the most common words, their associated positivity, negativity ([script](/wordCounts.R), [data](/words.csv)).
* Created a topic model and a visualization for interpretive purposes using [LDAvis](https://github.com/cpsievert/LDAvis) ([script](/topicModels.R))
* Determined the best number of topics using [bayesian model selection](http://cpsievert.github.io/projects/615/xkcd/)
* Determined the sentiment of sentances using [syuzhet](https://cran.r-project.org/web/packages/syuzhet/index.html) package ([script](/reviewSentiment.R), [data](/sentiment.csv))

## Next Step
* Filter out all non-noun words using the using [OpenNLP](https://cran.r-project.org/web/packages/openNLP/openNLP.pdf).
* Determine method for measuring the [Halo Effect](https://en.wikipedia.org/wiki/Halo_effect).

## Objectives
* Identify the most informative topics within a review.
* Create a visualization that displays these topics.
* Demonstrate the connection between topics and the reviews themselves.
