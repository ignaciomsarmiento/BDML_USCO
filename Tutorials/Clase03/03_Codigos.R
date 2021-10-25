#######################################################################
#  Aprendizaje y Minería de Datos para los Negocios 
#  Author: Ignacio Sarmiento-Barbieri (i.sarmiento at uniandes.edu.co)
#  please do not cite or circulate without permission
#######################################################################

# Carga de Paquetes a utilizar

#Load the required packages
library("here") #project location
library("tidyverse") #for data wrangling
library("caret") #ML





# # -----------------------------------------------------------------------
# Lasso y Ridge -----------------------------------------------------------
# # -----------------------------------------------------------------------
data(swiss) #loads the data set
?swiss
set.seed(123) #set the seed for replication purposes
glipse(swiss) #compact display

#hold-up sample
index <- createDataPartition(swiss$Fertility, p = 0.8, list = FALSE)
treain <- swiss[index,]
holdout  <- swiss[-index,]



ols <- train(Fertility ~ .,   # model to fit
             data = swiss,                        
             trControl = trainControl(method = "cv", number = 5),
             method = "lm")                     

print(ols)



lambda <- 10^seq(-2, 3, length = 100)

lasso <- train(
  Fertility ~., data = swiss, method = "glmnet",
  trControl = trainControl("cv", number = 5),
  tuneGrid = expand.grid(alpha = 1, lambda=lambda), preProcess = c("center", "scale")
)
print(lasso)



ridge <- train(
  Fertility ~., data = swiss, method = "glmnet",
  trControl = trainControl("cv", number = 5),
  tuneGrid = expand.grid(alpha = 0,lambda=lambda), preProcess = c("center", "scale")
)
print(ridge)




models <- list(ols=ols,ridge = ridge, lasso = lasso)
resamples(models) %>% summary( metric = "RMSE")



coef_lasso<-predict(lasso$finalModel, type = "coef", mode = "fraction", s = as.numeric(lasso$bestTune))
coef_ridge<-predict(ridge$finalModel, type = "coef", mode = "fraction", s = as.numeric(ridge$bestTune))


ols <- train(Fertility ~ ., data = swiss,
             method="lm",
             trControl=trainControl("none"),
             preProcess = c("center", "scale"))

coef_ols<-ols$finalModel$coefficients




cl<-data.frame(name=rownames(coef_lasso),coef=as.matrix(coef_lasso)[,1],model="Lasso")
cr<-data.frame(name=rownames(coef_ridge),coef=as.matrix(coef_ridge)[,1],model="Ridge")
#cel<-data.frame(name=rownames(coef_el),coef=as.matrix(coef_el)[,1],model="Elastic")
ols<-data.frame(name=rownames(coef_lasso),coef=as.matrix(coef_ols)[,1],model="OLS")

db_coefs<-rbind(cl,cr,ols)


db_coefs<- db_coefs %>% filter(grepl("Intercept",name)==FALSE)

ggplot(db_coefs, aes(x=name,y=coef,group=model,col=model)) +
  geom_point(position=position_jitter(h=0.05, w=0.05), alpha = 0.5, size = 3) +
  geom_hline(yintercept = 0, lty="dashed", col="black") +
  xlab("predictores") +
  ylab("coeficientes") +
  theme_bw() 





# # -----------------------------------------------------------------------
# Logit -------------------------------------------------------------------
# # -----------------------------------------------------------------------

#Read the data

set.seed(101010) #sets a seed 
credit<-readRDS(here("credit_class.rds"))
glimpse(credit)
summary(credit)
table(credit$foreign)
table(credit$purpose)
table(credit$rent)
default<-credit$Default #define ahora va a servir despues

credit<-credit %>% mutate(Default=factor(Default,levels=c(0,1),labels=c("No","Si")),
                          history=factor(history,levels=c("good","poor","terrible"),labels=c("buena","mala","terrible")),
                          foreign=factor(foreign,levels=c("foreign","german"),labels=c("extranjero","aleman")),
                          purpose=factor(purpose,levels=c("newcar","usedcar","goods/repair","edu", "biz" ),labels=c("auto_nuevo","auto_usado","bienes","educacion","negocios")))         


require("gtsummary") #buen paquete 
tbl_summary(credit)
tbl_summary(credit,by = Default)

## plot a mosaic
plot(Default ~ history, data=credit, col=c(8,2), ylab="Default") ## surprise!
## the dangers of choice-based sampling!  




mylogit <- glm(Default~duration + amount + installment + age + factor(history) + factor(purpose) + factor(foreign) + factor(rent), data = credit, family = "binomial")
summary(mylogit,type="text")


pred<-predict(mylogit,newdata = credit, type = "response")
summary(pred)

## what are our misclassification rates?
rule <- 1/2 

sum( (pred>rule)[default==0] )/sum(pred>rule) ## false positive rate
sum( (pred<rule)[default==1] )/sum(pred<rule) ## false negative rate

sum( (pred>rule)[default==1] )/sum(default==1) ## sensitivity 
sum( (pred<rule)[default==0] )/sum(default==0) ## specificity

## what are our misclassification rates?
rule <- 1/5 
sum( (pred>rule)[default==0] )/sum(pred>rule) ## false positive rate
sum( (pred<rule)[default==1] )/sum(pred<rule) ## false negative rate

sum( (pred>rule)[default==1] )/sum(default==1) ## sensitivity: Tasa Verdaderos Positivos
sum( (pred<rule)[default==0] )/sum(default==0) ## specificity: Tasa de Verdaderos Negativos


## roc curve and fitted distributions


source(here("Clase03/roc.R"))

roc(p=pred, y=default, bty="n")
## our 1/5 rule cutoff
points(x= 1-mean((pred<.2)[default==0]), 
       y=mean((pred>.2)[default==1]), 
       cex=1.5, pch=20, col='red') 
## a standard `max prob' (p=.5) rule
points(x= 1-mean((pred<.5)[default==0]), 
       y=mean((pred>.5)[default==1]), 
       cex=1.5, pch=20, col='blue') 
legend("bottomright",fill=c("red","blue"),
       legend=c("p=1/5","p=1/2"),bty="n",title="cutoff")





# Caret y ML --------------------------------------------------------------


#70% train
indic<-sample(1:nrow(credit),floor(.7*nrow(credit)))

#Partition the sample
train<-credit[indic,]
test<-credit[-indic,]
head(credit)
dim(credit)




mylogit <- glm(Default~duration + amount + installment + age + factor(history) + factor(purpose) + factor(foreign) + factor(rent), data = train, family = "binomial")
summary(mylogit)


test$phat<- predict(mylogit, test, type="response")
test$Default_hat<-ifelse(test$phat>.5,1,0)
with(test,prop.table(table(Default,Default_hat)))





trainControl <- trainControl(
  method = "cv",
  number = 5,
  classProbs = TRUE,
  summaryFunction = twoClassSummary
)



mylogit_caret <- train(
  Default ~., data = train, method = "glmnet",
  trControl = trainControl,
  family = "binomial", 
  metric = "ROC",
  tuneGrid = expand.grid(alpha = 0,lambda=lambda), preProcess = c("center", "scale")
)

print(mylogit_caret)


predictTest <- data.frame(
  obs = test$Default,                                    ## observed class labels
  predict(mylogit_caret, newdata = test, type = "prob"),         ## predicted class probabilities
  pred = predict(mylogit_caret, newdata = test, type = "raw")    ## predicted class labels
)

twoClassSummary(data = predictTest, lev = levels(predictTest$obs))

with(test,prop.table(table(Default,Default_hat)))
with(predictTest,prop.table(table(obs,pred)))

# Roc
##Logit

library("ROCR") #Roc
pred <- prediction(test$phat, test$Default)
roc_ROCR <- performance(pred,"tpr","fpr")
plot(roc_ROCR, main = "ROC curve", colorize = T)
abline(a = 0, b = 1)


auc_ROCR <- performance(pred, measure = "auc")
auc_ROCR@y.values[[1]]

?prediction
pred_lasso <- prediction(predictTest$pred, predictTest$obs)
roc_ROCR <- performance(pred,"tpr","fpr")

plot(roc_ROCR, main = "ROC curve", colorize = FALSE, col="red")
plot(roc_mylda,add=TRUE, colorize = FALSE, col="blue")
abline(a = 0, b = 1)





## build a design matrix 
#install.packages("gamlr")
str(credit$foreign)
source(here("Clase03/naref.R"))
credit<-naref(credit)

credx <- model.matrix( Default ~ .^2, data=credit)[,-1]
dim(credx)
colnames(credx)[c(1,2,16,17,18)]




credx <- sparse.model.matrix( Default ~ .^2, data=credit)[,-1]
head(credx)




default <- credit$Default
credscore <- cv.gamlr(credx, default, family="binomial", verb=TRUE)

plot(credscore)



sum(coef(credscore, s="min")!=0) # min
sum(coef(credscore$gamlr)!=0) # AICc




sum(coef(credscore)!=0) # 1se
sum(coef(credscore$gamlr, s=which.min(AIC(credscore$gamlr)))!=0) # AIC
sum(coef(credscore$gamlr, s=which.min(BIC(credscore$gamlr)))!=0) # BIC




# the OOS R^2
1 - credscore$cvm[credscore$seg.min]/credscore$cvm[1]

## What are the underlying default probabilities
## In sample probability estimates
pred <- predict(credscore$gamlr, credx, type="response")
pred <- drop(pred) # remove the sparse Matrix formatting
boxplot(pred ~ default, xlab="default", ylab="prob of default", col=c("pink","dodgerblue"))
