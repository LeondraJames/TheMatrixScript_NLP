#Sentiment Analysis & Topic Modeling of the script to "The Matrix"

#Load libraries
library(readxl)
library(tidyverse)
library(tidytext)
library(broom)
library(stringr)
library(stopwords)
library(ggthemes)
library(wordcloud)
library(wordcloud2)
library(reshape2)
library(tm)
library(topicmodels)
library(webshot)
library(htmlwidgets)


#Read data
df <- read_excel("C:/Users/Leondra/Downloads/TheMatrixScript (1).xlsx")
df <- df %>% 
  rename(text = '(Cellular)')

#Remove location / setting text
df$text <- gsub("^\\(.+\\)$", "", df$text, fixed = F)

#Remove all NAs
df <- na.omit(df)

#Create tibble and unnest_tokens to obtain 1 word per row
script <- tibble(lines = 1:nrow(df), 
                 text = df$text)

unnest_script <- script %>% 
  unnest_tokens(word, text)

#Remove stop words
data(stop_words)
my_stops <- tribble(
  ~word, ~lexicon,
  "cypher","CUSTOM",
  "trinity","CUSTOM",
  "morpheus","CUSTOM",
  "neo","CUSTOM",
  "switch","CUSTOM",
  "apoc","CUSTOM",
  "tank","CUSTOM",
  "dozer","CUSTOM",
  "oracle","CUSTOM",
  "mouse","CUSTOM",
  "choi","CUSTOM",
  "dujour","CUSTOM",
  "agent smith","CUSTOM",
  "agent brown","CUSTOM",
  "agent jones","CUSTOM",
  "smith", "CUSTOM",
  "brown","CUSTOM",
  "jones","CUSTOM",
  "anderson","CUSTOM",
  "yeah","CUSTOM"
)

all_stops <- stop_words %>% 
  bind_rows(my_stops)

unnest_script <- unnest_script %>% 
  anti_join(all_stops)

#Preliminary EDA
unnest_script %>% 
  count(word, sort = T) %>% 
  filter(n > 10) %>% 
  mutate(word = reorder(word, n)) %>% 
  ggplot(aes(word, n)) + 
  geom_col(fill = 'green4') + 
  xlab(NULL) + 
  coord_flip() +
  theme_hc()

#Sentiment Analysis
nrc <- get_sentiments("nrc")
unique(nrc$sentiment)



#Fear
unnest_script %>% 
  inner_join(nrc) %>% 
  filter(sentiment == 'fear') %>% 
  count(word, sort = T)

#Anger
unnest_script %>% 
  inner_join(nrc) %>% 
  filter(sentiment == 'anger') %>% 
  count(word, sort = T)

#Positive
unnest_script %>% 
  inner_join(nrc) %>% 
  filter(sentiment == 'positive') %>% 
  count(word, sort = T)

#Sentiment rating
rating <- unnest_script %>% 
  inner_join(get_sentiments('bing')) %>% 
  count(word, sentiment, sort = T) %>% 
  spread(sentiment, n, fill = 0) %>% 
  mutate(sentiment = positive - negative)

#Script words on sentiment scale
rating %>% 
  ggplot(.,aes(word, sentiment, fill = sentiment)) +
  geom_col(show.legend = F)+
  xlab(NULL) +
  theme(axis.text.x= element_blank(), axis.ticks.x = element_blank())+
  theme_hc()

#Top positive words
rating %>% 
  arrange(desc(sentiment)) %>% 
  head()

#Top negative words
rating %>% 
  arrange(sentiment) %>% 
  head()


#Negative vs. Positive
neg.pos <- unnest_script %>%
  inner_join(get_sentiments("bing")) %>%
  count(word, sentiment, sort = TRUE) %>%
  ungroup()

neg.pos %>% 
  group_by(sentiment) %>% 
  top_n(15) %>% 
  ungroup %>% 
  mutate(word = reorder(word, n)) %>% 
  ggplot(.,aes(word, n, fill = sentiment)) +
  geom_col(show.legend = F) +
  facet_wrap(~sentiment, scales = 'free_y') +
  labs(x = NULL , y = 'Sentiment Score') +
  coord_flip() +
  theme_hc()

#Wordclouds
unnest_script %>% 
  count(word) %>% 
  with(wordcloud(word, n, maxwords = 100, colors = 'green'))



unnest_script %>%
  inner_join(get_sentiments("bing")) %>%
  count(word, sentiment, sort = TRUE) %>%
  acast(word ~ sentiment, value.var = "n", fill = 0) %>%
  comparison.cloud(colors = c("green", "darkgreen"),
                   max.words = 50)  

#The Matrix wordcloud
webshot::install_phantomjs()

tmwc <- unnest_script %>% 
  count(word) %>% 
  wordcloud2(., color = "darkgreen", backgroundColor = "black", rotateRatio = 1,
             minRotation = pi/2, maxRotation = pi/2)

saveWidget(tmwc,"tmwc.html",selfcontained = F) #HTML
webshot("tmwc.html","tmwc.pdf", delay =5, vwidth = 480, vheight=480) #PNG


#Document Term Matrix
corpus <- VCorpus(VectorSource(unnest_script$word))
dtm <- DocumentTermMatrix(corpus, control = list(
  tolower= T, removeNumbers = T, removePunctuation = T, stemming = T))

inspect(dtm[1:5, 50:60]) #Take a peak at matrix

#Remove sparse terms
dtm <- removeSparseTerms(dtm, 0.99)

#View most frequent terms
findFreqTerms(dtm, 10)

#Remove documents (rows) with 0 words
rowTotals <- apply(dtm, 1, sum)
dtm.new <- dtm[rowTotals > 0,]

#LDA Model - 2 topics
lda_2 <- LDA(dtm.new, k = 2, control = list(seed = 101))

#Beta aka per topic, per word
topics <- tidytext::tidy(lda_2, matrix = 'beta')

#Top topics for 2 topic model
top_topics <- topics %>% 
  group_by(topic) %>% 
  top_n(10, beta) %>% 
  ungroup %>% 
  arrange(topic, -beta)

top_topics

top_topics %>% 
  mutate(term = reorder(term, beta)) %>% 
  ggplot(aes(term, beta, fill = factor(topic)))+
  geom_col(show.legend = F)+
  facet_wrap(~topic, scales = 'free') +
  coord_flip()+
  theme_hc()

#LDA Model - 3 topics
lda_3 <- LDA(dtm.new, k = 3, control = list(seed = 101))

topics_3 <- tidytext::tidy(lda_3, matrix = 'beta')

#Top topics for 3 topic model
top_topics_3 <- topics_3 %>% 
  group_by(topic) %>% 
  top_n(10, beta) %>% 
  ungroup %>% 
  arrange(topic, -beta)

top_topics_3

top_topics_3 %>% 
  mutate(term = reorder(term, beta)) %>% 
  ggplot(aes(term, beta, fill = factor(topic)))+
  geom_col(show.legend = F)+
  facet_wrap(~topic, scales = 'free') +
  coord_flip()+
  theme_hc()
  
