# "The Matrix" Script NLP Project
A project utilizing NLP techniques and analysis including text mining, document term matrices, sentiment analysis, wordclouds and topic modeling with LDA.

# Why The Matrix
The Matrix is my all time favorite film and arguably the jumpstart to my passion for computer programming. When I first saw the film, I was 8 years old and had very little knowledge or exporsure to computer science or philosophy. Little did I know, I was up for quite the thrill ride! 

Having just attended a 20th Year Anniversary screening of The Matrix at the Cinespia's Hollywood Cemetery outdoor films (and having just recently re-opened my copy of "Philosophers Explore The Matrix" by Christopher Grau), it made me realize how crutial this film has been in my journey as an action fan, tech professional and adult living in the 21st century. It was quotes like this from Agent Smith, that made me realize just a few weeks ago, how timeless and relevant this film in contemporary times of AI:

*"Did you know that the first Matrix was designed to be a perfect human world, where none suffered, where everyone would be happy? It was a disaster. No one would accept the program, entire crops were lost. Some believed we lacked the programming language to describe your perfect world, but I believe that, as a species, human beings define their reality through misery and suffering. The perfect world was a dream that your primitive cerebrum kept trying to wake up from. Which is why the Matrix was redesigned to this, the peak of your civilization. I say your civilization, because as soon as we started thinking for you it really became our civilization, which is of course what this is all about. Evolution, Morpheus, evolution. Like the dinosaur. Look out that window. You've had your time. The future is our world, Morpheus. The future is our time."*

I could talk for days about the lessons I've learned from The Matrix. But instead, I decided to do an analysis of the script!

# The Analysis
After removing missing rows, location headers, and stop words (both publically available stopwords and my own custom stopwords - mainly cast names), my first step was to normalize the terms with unnest_tokens() (lower case, remove punctuation, etc.) and analyze the term frequency in the document. While I was expecting to see "agent" and "matrix" frequently, what I did not expect was "told", "life" or "god". Since the film certaintly touches on religious undertones, as well as the human condition / life and our relationship with authority and reality, this seemed to make sense.

Next, I wanted to explore the most frequent words under each sentiment. Interesting enough, the top 5 "fearful" words were "god", "hell", "change", "afraid" and "die". As expected, the top "angry" words were all curse words, and the most "positive" words included "god", "real" and "truth". When I graphed all words from the script on a sentiment plane, we see that the overall script tends to lean "negative" more than "positive", with the pattern following that of a typical Hollywood script architecture (ie: strong negativity right at the climax of drama). 

Then, I created a "Matrix-style" animated wordcloud to show the occurence of unique terms in the script. The most frequent word of all was "agent".

Lastly, I created a document term matrix, removing the sparsity in the data, and using LDA to determine the probability of certain terms occuring in each topic. I used a 2 and 3-topic model to see if there were any major differences in topics if split 2 or 3 ways respectively. What I found was that the topics were very similar and shared many of the same top terms, although they did have little differences.

# My Takeaway
My regard of The Matrix has not changed since partaking in this analysis, but my biggest takeaway was mainly sentimental. I feel as if I've come full circle since being that little girl who first saw this amazing film with wide eyes and curiosity, to an adult woman, still a huge fan of AI, philosophy, action films, Keanu Reeves, and hacking. 
