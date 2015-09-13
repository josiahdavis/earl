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

## Helpful Resources
* ["Secret” Recipe for Topic Modeling Themes"](http://www.matthewjockers.net/2013/04/12/secret-recipe-for-topic-modeling-themes/) by Matthew L. Jockers (April 2013)
* [Finding scientific topics](http://psiexp.ss.uci.edu/research/papers/sciencetopics.pdf) by Steyvers and Griffiths (April 2004)
* [LDAvis: A method for visualizing and interpreting topics](http://nlp.stanford.edu/events/illvi2014/papers/sievert-illvi2014.pdf) by Sievert and Shirley (2014)
* [An introduction to topic modeling of early American sources](http://www.common-place.org/vol-06/no-02/tales/)

> Remember the $10,000 Pyramid hosted by Dick Clark? It was a game show started in the 1970s in which minor celebrities shouted a series of words or phrases and their contestant partners tried to guess the category to which those words belonged. So "dog…parrot…cat…goldfish…pot-bellied pig" would be possible hints for the category "Animals you keep as pets!"

## Resources to Explore
* **Paper:** [Personalizing Yelp Star Ratings: a Semantic Topic Modeling Approach](http://www.yelp.com/html/pdf/YelpDatasetChallengeWinner_PersonalizingRatings.pdf). Interesting because "that a reviewer would draw from a different set of words when writing about 5-star quality food and 1-star quality food"
* **Article:** [Introduction to Latent Dirichlet Allocation](http://blog.echen.me/2011/08/22/introduction-to-latent-dirichlet-allocation/) by Edwin Chen.
* **Paper:** [Inferring Business Similarity from Topic Modeling](http://cseweb.ucsd.edu/~jmcauley/cse190/reports/004.pdf) paper uses Latent Dirichlet Allocation and Jaccard Similarity applied to Yelp reviews
* **Paper:** [Improving Restaurants by Extracting Subtopics from Yelp Reviews](http://www.yelp.com/html/pdf/YelpDatasetChallengeWinner_ImprovingRestaurants.pdf)
* **Paper:** [Hidden Factors and Hidden Topics: Understanding Rating Dimensions with Review Text](http://cs.stanford.edu/people/jure/pubs/reviews-recsys13.pdf)
* **Paper:** [Prediction of Yelp Restaurant Review Score](http://newport.eecs.uci.edu/~xis2/Yelp/Final-report-pp16.pdf)
* **Paper:** [Termite: Visualization Techniques for Assessing Textual Topic Models](http://vis.stanford.edu/files/2012-Termite-AVI.pdf) (2012)
* **Article:** [The Digital Humanities Contribution to Topic Modeling](http://journalofdigitalhumanities.org/2-1/dh-contribution-to-topic-modeling/)
* **Python Package:** [Gensism](https://radimrehurek.com/gensim/index.html) topic modeling for humans.
* **Python Package:** [SpaCy](http://spacy.io/) a library for natural language processing in Python.
