#######################################################################
#  Aprendizaje y Minería de Datos para los Negocios 
#  Author: Ignacio Sarmiento-Barbieri (i.sarmiento at uniandes.edu.co)
#  please do not cite or circulate without permission
#######################################################################

# Carga de Paquetes a utilizar
library("here") #project location
library("tidyverse") #for data wrangling






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





# Networks ----------------------------------------------------------------



#packages
library(tensorflow)
library(keras)

#load the data
cifar <- dataset_cifar10()

#fix names
class_names <- c('airplane', 'automobile', 'bird', 'cat', 'deer',
                 'dog', 'frog', 'horse', 'ship', 'truck')


index <- 1:30

par(mfcol = c(5,6), mar = rep(1, 4), oma = rep(0.2, 4))
cifar$train$x[index,,,] %>% 
  purrr::array_tree(1) %>%
  purrr::set_names(class_names[cifar$train$y[index] + 1]) %>% 
  purrr::map(as.raster, max = 255) %>%
  purrr::iwalk(~{plot(.x); title(.y)})


#Create the convolutional base


model <- keras_model_sequential() %>% 
  layer_conv_2d(filters = 32, kernel_size = c(3,3), activation = "relu", 
                input_shape = c(32,32,3)) %>% 
  layer_max_pooling_2d(pool_size = c(2,2)) %>% 
  layer_conv_2d(filters = 64, kernel_size = c(3,3), activation = "relu") %>% 
  layer_max_pooling_2d(pool_size = c(2,2)) %>% 
  layer_conv_2d(filters = 64, kernel_size = c(3,3), activation = "relu")



summary(model)



model %>% 
  layer_flatten() %>% 
  layer_dense(units = 64, activation = "relu") %>% 
  layer_dense(units = 10, activation = "softmax")

summary(model)



model %>% compile(
  optimizer = "adam",
  loss = "sparse_categorical_crossentropy",
  metrics = "accuracy"
)

history <- model %>% 
  fit(
    x = cifar$train$x, y = cifar$train$y,
    epochs = 10,
    validation_data = unname(cifar$test),
    verbose = 2
  )



plot(history)

evaluate(model, cifar$test$x, cifar$test$y, verbose = 0)



