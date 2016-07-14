# Parallel Letter Frequency

Write a program that counts the frequency of letters in texts using parallel computation.

Parallelism is about doing things in parallel that can also be done
sequentially. A common example is counting the frequency of letters.
Create a function that returns the total frequency of each letter in a
list of texts and that employs parallelism.

# Solution

1. Get list of binary strings as input.
2. Convert all input strings to lower case.
3. Extract Unicode characters from every string into separate list of characters (binaries). Every string containing letters will result into list so we will have a list of lists as an output of this step.
3. Divide list in chunks of lists - each chunk will contain a number of lists according to a given number of workers.
4. Now we can iterate over chunks and process all lists in every chunk separately and asynchronously. Every list of letters is asynchronously reduced into a letters frequency map containing letters as keys and frequency counter as values.
5. Merge all maps into one resulting map containing frequency of letters from all input texts.

# Tests

Few additional tests were added to Exercism test suite for my new functions
