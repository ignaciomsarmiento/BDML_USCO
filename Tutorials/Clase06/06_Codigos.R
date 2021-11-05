#######################################################################
#  Aprendizaje y Minería de Datos para los Negocios 
#  Author: Ignacio Sarmiento-Barbieri (i.sarmiento at uniandes.edu.co)
#  please do not cite or circulate without permission
#######################################################################

# Carga de Paquetes a utilizar
library("here") #project location
library("tidyverse") #for data wrangling






# install.packages("wordcloud")
# install.packages("pdftools")
# install.packages("tm")
# install.packages("RColorBrewer")
# install.packages("factoextra")
# install.packages("textir")
# install.packages("maptpx")
# install.packages("text2vec")
# Extraer data de archivos con texto --------------------------------------
## the tm library (and related plugins) is R's ecosystem for text mining. for an intro see http://cran.r-project.org/web/packages/tm/vignettes/tm.pdf
library("tm") 
library("wordcloud")
library("RColorBrewer")
## the way file input works with tm is you create a reader function,
## depending on document type.  Each of the reader functions
## have arguments elem, language, id (see ?readPlain,?readPDF,etc)
## I wrap another function around them to specify these arguments.

## for example, a reader to input plain text files 
## (Note: there are many other ways to do this)
readerPlain <- function(fname){
  readPlain(elem=list(content=readLines(fname)), 
            id=fname, language='en') }
## test it on this script
## (the file name will change depending on where you store stuff).
rcode <- readerPlain(here("../Tutorials/Clase05/05_Codigos.R"))
rcode # this is the tm 'PlainTextDocument'
content(rcode)[1:21] # this is the actual text part


## *** Reading PDFs ***

## from the tm docs: "Note that this PDF reader needs the  tool pdftotext installed and accessible on your system,  available as command line utility in the Poppler PDF  rendering library (see http://poppler.freedesktop.org/)." this appears to be the default on windows

## we'll create a 'reader' function to interpret pdfs,  using tm's readPDF (see help(readPDF) examples)

readerPDF <- function(fname){
  txt <- 
    return(txt)
}


## read the TRANSPARENCY AND DELIBERATION WITHIN THE FOMC: A COMPUTATIONAL LINGUISTICS APPROACH paper
notes<-readPDF(control = list(text = "-layout -enc UTF-8"))(elem=list(uri=here("Clase06/qje_2018.pdf")), id=fname, language='en')

names(notes)
writeLines(content(notes)[1]) # the cover slide

content(notes) <-iconv(content(notes), from="UTF-8", to="ASCII", sub="")

## once you have a bunch of docs in a vector, you  create a text mining 'corpus' with: 
docs <- Corpus(VectorSource(notes))


names(docs) <- names(notes) # no idea why this doesn't just happen
## you can then do some cleaning here

docs <- docs %>%
  tm_map(removeNumbers) %>% ## remove numbers
  tm_map(removePunctuation) %>% ## remove punctuation
  tm_map(stripWhitespace) ## remove excess white-space
docs <- tm_map(docs, content_transformer(tolower)) ## make everything lowercase
docs <- tm_map(docs, removeWords, stopwords("english"))

#stopwords("SMART")
## create a doc-term-matrix
dtm <- DocumentTermMatrix(docs)
dtm 

## Drop some terms
dtm <- removeSparseTerms(dtm, 0.80)
dtm # now near 700 terms


## These are special sparse matrices.  
class(dtm)
## You can inspect them:
inspect(dtm[1:5,1:8])
## find words with greater than a min count
findFreqTerms(dtm,50)
## or grab words whose count correlates with given words
findAssocs(dtm, "college", .1) 



matrix <- as.matrix(dtm) 
words <- sort(rowSums(matrix),decreasing=TRUE) 
df <- data.frame(word = names(words),freq=words)

set.seed(1234) # for reproducibility 
wordcloud(words = df$word, freq = df$freq, min.freq = 20,          
          max.words=200, random.order=FALSE, rot.per=0.35,           
          colors=brewer.pal(8, "Dark2"))




# regressions -------------------------------------------------------------
# Logistic regression: Spam data
email <- read.csv(here("Clase06/spam.csv"))

## fit the full model
spammy <- glm(spam ~ ., data=email, family='binomial')
## you don't need to worry about this warning.  
## It says that some covariates are nearly perfect predictors.

## the guy is named george and he works in a cs dept
table(email$spam, email$word_george)
table(email$spam, email$word_free)

## the coefficients
b <- coef(spammy)
exp(b["word_george"]) # George => !SPAM
exp(b["word_free"]) # Free => SPAM

# fit plot
plot(spammy$fit~email$spam, 
     xlab="", ylab=c("fitted probability of spam"), 
     col=c("navy","red"))

# predict spam v not for first 2 obsv
predict(spammy, newdata=email[c(1,4000),])
predict(spammy, newdata=email[c(1,4000),], type="response")




# Ejemplo Congreso ---------------------------------------------
#load packages
library("textir") 
require("factoextra")

#load data
data(congress109)
congress109Counts[c("Barack Obama","John Boehner"),995:998]

congress109Ideology[1:4,1:5]



wordcloud(words = colnames(congress109Counts), 
          freq = colSums(congress109Counts),
          min.freq = 100,
          scale = c(3, 0.1), max.words=200, 
          random.order=FALSE, rot.per=0.35, 
          colors=brewer.pal(8, "Set1"))



tail(colSums(congress109Counts))


wordcloud(words = colnames(congress109Counts), 
          freq = colSums(congress109Counts),
          min.freq = 1000, 
          scale = c(3, 0.1), max.words=30, 
          random.order=FALSE, rot.per=0.35, 
          colors=brewer.pal(8, "Set1"))







# PCA ---------------------------------------------------------------------
votes <- read.csv(here("Clase06/rollcall-votes.csv"))
legis <- read.csv(here("Clase06/rollcall-members.csv"))



pcavote <- prcomp(votes, scale=TRUE)
plot(pcavote, main="")
mtext(side=1, "Rollcall-Vote Principle Components",  line=1, font=2)



# Eigenvalues
eig.val <- get_eigenvalue(pcavote)
head(eig.val)

var_explained_df <- data.frame(PC= paste0("PC",1:445),
                               var_explained=(pcavote$sdev)^2/sum((pcavote$sdev)^2))
var_explained_df <- var_explained_df %>% mutate(cum_sum=cumsum(var_explained))

var_explained_df[1:5,] %>%
  ggplot(aes(x=PC,y=cum_sum, group=1))+
  ylab("cumulative.variance.percent") +
  geom_point(size=4)+
  geom_line()+
  theme_bw()

votepc <- predict(pcavote) # scale(votes)%*%pcavote$rotation
plot(votepc[,1:2], pch=21, bg=(4:2)[legis$party], main="")

# big scores on pc1 are left and right ideologically
votepc[order(votepc[,1])[1:5],1]
votepc[order(-votepc[,1])[1:5],1]

# big scores -/+ on pc 2?
votepc[order(votepc[,2])[1:5],2]
votepc[order(-votepc[,2])[1:5],2]

# look at the loadings
loadings <- pcavote$rotation[,1:2]

## the 1st is traditional left-right
hist(loadings[,1], main="", xlab="1st Principle Component Vote-Loadings",
     col=8, border=grey(.9))
abline(v=loadings[884,1], col=2)
text(x=loadings[884,1], y=550, "Afford. Health (amdt.)", xpd=TRUE, col=2, font=3)
abline(v=loadings[25,1], col=4)
text(x=loadings[25,1], y=550, "TARP", xpd=TRUE, col=4, font=3)

## trying to interpret the 2nd factor
loadings[order(abs(loadings[,2]), decreasing=TRUE)[1:5],2]
## attendance!
sort(rowSums(votes==0), decreasing=TRUE)[1:5]






# lasso 
lassoslant <- cv.gamlr(congress109Counts>0, y)
B <- coef(lassoslant$gamlr)[-1,]
head(sort(round(B[B!=0],4)),10)

tail(sort(round(B[B!=0],4)),10)




# Slant  PCA-------------------------------------------------------------------

slant <- pls(f, y, K=3)

# pictures
for(k in 1:3)
  plot(slant$y, slant$fitted[,k], ylim=c(-.05,.85), xlab="", ylab="",
       main=sprintf("PLS(%d)", k), 
       pch=20, col=c(4,3,2)[congress109Ideology$party], bty="n")
mtext(side=1, "repshare", outer=TRUE, line=-1.25)
mtext(side=2, "fitted", outer=TRUE, line=-1.25)



# Topics  -----------------------------------------------------------------
# we8there
library(textir)
library(maptpx) # for the topics function
data(we8there)

#PCA
x_pca <- we8thereCounts
pca <- prcomp(x_pca, scale=TRUE) # can take a long time
v <- predict(pca)[,1:4]

par(mai=c(.8,.8,.1,.1))
boxplot(v[,1] ~ we8thereRatings$Overall, xlab="overall rating", ylab="PC1 score")


# you need to convert from a Matrix to a `slam' simple_triplet_matrix
x <- as.simple_triplet_matrix(we8thereCounts)

# to fit, just give it the counts, number of `topics' K, and any other args
tpc <- topics(x,K=10) 

# choosing the number of topics
tpcs <- topics(x,K=5*(1:5), verb=1) # it chooses 10 topics 


## interpretation
# summary prints the top `n' words for each topic,
# under ordering by `topic over aggregate' lift:
#    the topic word prob over marginal word prob.
summary(tpcs, n=10) 
# this will promote rare words that with high in-topic prob



# alternatively, you can look at words ordered by simple in-topic prob
## the topic-term probability matrix is called 'theta', 
## and each column is a topic
## we can use these to rank terms by probability within topics
rownames(tpcs$theta)[order(tpcs$theta[,1], decreasing=TRUE)[1:10]]
rownames(tpcs$theta)[order(tpcs$theta[,2], decreasing=TRUE)[1:10]]

boxplot(tpcs$omega[,1] ~ we8thereRatings$Overall, col="gold", xlab="overall rating", ylab="topic 1 score")
boxplot(tpcs$omega[,2] ~ we8thereRatings$Overall, col="pink", xlab="overall rating", ylab="topic 2 score")


# Word Embedings  ---------------------------------------------------------
library("text2vec")
load('shakes_words_df_4text2vec.RData')
head(shakes_words)




shakes_words_ls <- list(shakes_words$word)
it <- itoken(shakes_words_ls, progressbar = FALSE)
shakes_vocab <- create_vocabulary(it)
shakes_vocab <- prune_vocabulary(shakes_vocab, term_count_min= 5)

#Let’s take a look at what we have at this point. We’ve just created word counts, that’s all the vocabulary object is.


head(shakes_vocab)


#The next step is to create the token co-occurrence matrix (TCM). The definition of whether two words occur together is arbitrary. Should we just look at previous and next word? Five behind and forward? This will definitely affect results so you will want to play around with it.

# maps words to indices
vectorizer <- vocab_vectorizer(shakes_vocab)



# use window of 10 for context words
shakes_tcm <- create_tcm(it, vectorizer, skip_grams_window = 10)


#Note that such a matrix will be extremely sparse. Most words do not go with other words in the grand scheme of things. So when they do, it usually matters.

#Now we are ready to create the word vectors based on the GloVe model. Various options exist, so you’ll want to dive into the associated help files and perhaps the original articles to see how you might play around with it. The following takes roughly a minute or two on my machine. I suggest you start with n_iter <- 10 and/or convergence_tol <- 0.001 to gauge how long you might have to wait.

#In this setting, we can think of our word of interest as the target, and any/all other words (within the window) as the context. Word vectors are learned for both.

glove <- GlobalVectors$new(rank = 50, x_max = 10)
shakes_wv_main = glove$fit_transform(shakes_tcm, n_iter = 10, convergence_tol = 0.01, n_threads = 8)


dim(shakes_wv_main)
shakes_wv_context <- glove$components



dim(shakes_wv_context)


# Either word-vectors matrices could work, but the developers of the technique
# suggest the sum/mean may work better
shakes_word_vectors <- shakes_wv_main + t(shakes_wv_context)


#Now we can start to play. The measure of interest in comparing two vectors will be cosine similarity, which, if you’re not familiar, you can think of it similarly to the standard correlation12. Let’s see what is similar to Romeo.


rom <- shakes_word_vectors["romeo", , drop = F]
# ham <- shakes_word_vectors["hamlet", , drop =F]


cos_sim_rom <- sim2(x =shakes_word_vectors, y = rom, method = "cosine", norm = "l2")
head(sort(cos_sim_rom[,1], decreasing <- T), 10)




#Obviously Romeo is most like Romeo, but after that comes the rest of the crew in the play. As this text is somewhat raw, it is likely due to names associated with lines in the play. As such, one may want to narrow the window13. Let’s try love.


love <- shakes_word_vectors["love", , drop = F]



cos_sim_rom <- sim2(x <- shakes_word_vectors, y = love, method = "cosine", norm = "l2")
head(sort(cos_sim_rom[,1], decreasing <- T), 10)


#The issue here is that love is so commonly used in Shakespeare, it’s most like other very common words. What if we take Romeo, subtract his friend Mercutio, and add Nurse? This is similar to the analogy example we had at the start.


test <- shakes_word_vectors["romeo", , drop = F] -
  shakes_word_vectors["mercutio", , drop = F] +
  shakes_word_vectors["nurse", , drop = F]

cos_sim_test <- sim2(x = shakes_word_vectors, y = test, method = "cosine", norm = "l2")
head(sort(cos_sim_test[,1], decreasing = T), 10)


#It looks like we get Juliet as the most likely word (after the ones we actually used), just as we might have expected. Again, we can think of this as Romeo is to Mercutio as Juliet is to the Nurse. Let’s try another like that.


test <- shakes_word_vectors["romeo", , drop = F] - 
  shakes_word_vectors["juliet", , drop = F] + 
  shakes_word_vectors["cleopatra", , drop = F] 

cos_sim_test <- sim2(x = shakes_word_vectors, y = test, method = "cosine", norm = "l2")
head(sort(cos_sim_test[,1], decreasing = T), 3)



#One can play with stuff like this all day. For example, you may find that a Romeo without love is a Tybalt!