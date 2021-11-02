#######################################################################
#  Aprendizaje y Minería de Datos para los Negocios 
#  Author: Ignacio Sarmiento-Barbieri (i.sarmiento at uniandes.edu.co)
#  please do not cite or circulate without permission
#######################################################################

# Carga de Paquetes a utilizar
library("here") #project location
library("tidyverse") #for data wrangling
library("caret") #ML

#install.packages("caret",dependencies = TRUE)

# # -----------------------------------------------------------------------
# Classification -------------------------------------------------------------------
# # -----------------------------------------------------------------------
set.seed(101010) #sets a seed 

credit<-readRDS(here("credit_class.rds")) #leer los datos

#Inspeccionar los datos
glimpse(credit)
summary(credit)
prop.table(table(credit$foreign)) #porcentajes
table(credit$purpose)
table(credit$rent)


default<-credit$Default #defino ahora va a servir después

#mutacion de datos
credit<-credit %>% mutate(Default=factor(Default,levels=c(0,1),labels=c("No","Si")),
                          history=factor(history,levels=c("good","poor","terrible"),labels=c("buena","mala","terrible")),
                          foreign=factor(foreign,levels=c("foreign","german"),labels=c("extranjero","aleman")),
                          purpose=factor(purpose,levels=c("newcar","usedcar","goods/repair","edu", "biz" ),labels=c("auto_nuevo","auto_usado","bienes","educacion","negocios"))) %>% 
                   rename(historia=history,
                          extranjero=foreign,
                          proposito=purpose,
                          edad=age,
                          cantidad=amount,
                          duracion=duration,
                          cuotas=installment)

glimpse(credit)
# # -----------------------------------------------------------------------
# Estadisticas Descriptivas -----------------------------------------------
# # -----------------------------------------------------------------------
require("gtsummary") #buen paquete para tablas descriptivas
tbl_summary(credit)
tbl_summary(credit,by = Default)

## plot a mosaic
plot(Default ~ historia, data=credit, col=c(8,2), ylab="Default") ## surprise!
## the dangers of choice-based sampling!  




# # -----------------------------------------------------------------------
# Logit  ------------------------------------------------------------------
# # -----------------------------------------------------------------------

# usando la funcion `glm()` que viene en R
mylogit <- glm(Default~., data = credit, family = "binomial")
summary(mylogit,type="text")

pred<-predict(mylogit,newdata = credit, type = "response")
summary(pred)






# Caret y ML --------------------------------------------------------------
#80% train 20% holdoup
index <- createDataPartition(credit$Default, p = 0.8, list = FALSE)
train <- credit[index,]
holdout  <- credit[-index,]


trainControl <- trainControl(
  method = "cv",
  number = 5,
  classProbs = TRUE,
  summaryFunction = twoClassSummary,
  savePredictions = T
)
?trainControl #helps para ver que hay adentro
?twoClassSummary

#logit
mylogit_caret <- train(
  Default ~.,
  data = train, 
  method = "glm", #for logit
  trControl = trainControl,
  family = "binomial", 
  metric = "ROC",
  preProcess = c("center", "scale")
)
mylogit_caret

#Lasso
lambda_grid <- 10^seq(-3, 0.1, length = 100) #en la practica se suele usar una grilla de 200 o 300
lambda_grid

mylogit_lasso <- train(
  Default ~., data = train, 
  method = "glmnet",
  trControl = trainControl,
  family = "binomial", 
  metric = "ROC",
  tuneGrid = expand.grid(alpha = 0,lambda=lambda_grid), 
  preProcess = c("center", "scale")
)
mylogit_lasso



credx <- model.matrix( Default ~ .^2, data=credit)[,-1]
dim(credx)

mylogit_lasso_massive <- train(
  Default ~.^2, 
  data = train, 
  method = "glmnet",
  trControl = trainControl,
  family = "binomial", 
  metric = "ROC",
  tuneGrid = expand.grid(alpha = 0,lambda=lambda_grid), 
  preProcess = c("center", "scale")
)

mylogit_lasso_massive

alpha_grid<-seq(0,1,by=.1)
alpha_grid

grilla_bidimensional<-expand.grid(alpha = alpha_grid,lambda=lambda_grid)

mylogit_lasso_grid <- train(
  Default ~., 
  data = train, 
  method = "glmnet",
  trControl = trainControl,
  family = "binomial", 
  metric = "ROC",
  tuneGrid = expand.grid(alpha = alpha_grid,lambda=lambda_grid), 
  preProcess = c("center", "scale")
)

mylogit_lasso_grid


#install.packages("MLeval")
require("MLeval")
?require
res <- evalm(list(mylogit_caret,
                  mylogit_lasso,
                  mylogit_lasso_massive,
                  mylogit_lasso_grid),gnames=c('logit','lasso',"masive","grid"))





# Arbol -------------------------------------------------------------------

#?rpart
#install.packages("rpart")
glimpse(train)
cp_alpha<-seq(from = 0, to = 1, length = 100)
tree <- train(
  Default ~duracion+cantidad+cuotas+edad, 
  data = train, 
  method = "rpart",
  trControl = trainControl,
  metric = "ROC",
  tuneGrid = expand.grid(cp = cp_alpha)
)
tree
tree$bestTune
plot(tree$finalModel)

library("rattle")
fancyRpartPlot(tree$finalModel)

tree$finalModel


# Random Forests ----------------------------------------------------------


forest <- train(
  Default ~., 
  data = train, 
  method = "rf",
  trControl = trainControl,
  family = "binomial", 
  metric = "ROC",
  preProcess = c("center", "scale")
)



adaboost <- train(
  Default ~., data = train, 
  method = "adaboost",
  trControl = trainControl,
  family = "binomial", 
  metric = "ROC",
  preProcess = c("center", "scale")
)


res <- evalm(list(mylogit_caret,
                  mylogit_lasso,
                  mylogit_lasso_massive,
                  mylogit_lasso_grid,
                  tree,
                  forest,
                  adaboost),
             gnames=c('logit','lasso',"masive","grid","tree","forest","ada"))





# Evaluar en los holdout sets ---------------------------------------------

#Arbol
db_tree_test<-predict(tree,newdata=holdout,type="prob")
db_tree_test = data.frame(db_tree_test, holdout$Default)
ev_tree<-evalm(db_tree_test)
#.61
#logit
db_logit_test<-predict(mylogit_caret,newdata=holdout,type="prob")
db_logit_test = data.frame(db_logit_test, holdout$Default)
ev_logit<-evalm(db_logit_test)
#.71

db_lasso_test<-predict(mylogit_lasso,newdata=holdout,type="prob")
db_lasso_test = data.frame(db_lasso_test, holdout$Default)
ev_lasso<-evalm(db_lasso_test)
#71