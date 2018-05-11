# WordFrequencyComparison
A perl tool to compare word frequencies in an input text with those of a reference one (aka corpus).

The reference defaults to the list of the most common 333,333 words made public by Google

As input a txt file (of a book, presumably) is required.

Outputs a space-separated-file in the follofing format:

  Term  relative_freq_in_the_reference_corpus relative_freq_in_the_input_book

Companion to the Medium article:
https://medium.com/@RafDouglas/a-descent-into-the-wordstr%C3%B6m-51c398d5163
