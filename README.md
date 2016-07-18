# Parallel Letter Frequency

Write a program that counts the frequency of letters in texts using parallel computation.

Parallelism is about doing things in parallel that can also be done
sequentially. A common example is counting the frequency of letters.
Create a function that returns the total frequency of each letter in a
list of texts and that employs parallelism.

# Solution

1. Split input texts into chunks according to a given number of workers (using simple round robin approach)
2. Process every chunk (list of strings) via separate asynchronous Task
3. Convert all strings to lower case.
4. Extract Unicode letters from every string into a list of separate letters (binaries).
5. Every list of letters is reduced into a letters frequency map containing letters as keys and frequency counter as values.
6. Merge all maps into one resulting map containing frequency of letters from all input texts.

# Tests

Few additional tests were added to Exercism test suite new functions
