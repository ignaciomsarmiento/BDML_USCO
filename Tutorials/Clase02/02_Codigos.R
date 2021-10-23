#######################################################################
#  Aprendizaje y Minería de Datos para los Negocios 
#  Author: Ignacio Sarmiento-Barbieri (i.sarmiento at uniandes.edu.co)
#  please do not cite or circulate without permission
#######################################################################

# Carga de Paquetes a utilizar
library("here") #project location
library("tidyverse") #data wrangling
library("caret") #ML

setwd("~/Dropbox/Teaching/2021/Surcolombiana/Tutorials/") #forma equivalente de setear working directory
# # -----------------------------------------------------------------------
# Leer los datos
#(Fuente: https://www.kaggle.com/austinreese/craigslist-carstrucks-data?select=vehicles.csv)
# # -----------------------------------------------------------------------
dta_sample<-read_csv(here("sample_vehicles.csv")) #tidyverse

glimpse(dta_sample)

summary(dta_sample) #hacer resumen

table(dta_sample$state) 

dta_sample<-dta_sample %>% filter(state %in% c("ak","al","ar","az","ca"))
table(dta_sample$state) 


dta_sample<-dta_sample %>% mutate(ak=ifelse(state=="ak",1,0),
                                  al=ifelse(state=="al",1,0),
                                  ar=ifelse(state=="ar",1,0),
                                  az=ifelse(state=="az",1,0),
                                  ca=ifelse(state=="ca",1,0),
                                  )


summary(dta_sample)

table(dta_sample$manufacturer)
class(dta_sample$manufacturer)
dta_sample<-dta_sample %>% mutate(manufacturer=factor(manufacturer)) #crea factor
class(dta_sample$manufacturer)

summary(dta_sample) #hacer resumen

plot(density(log(dta_sample$price)))

quantile(dta_sample$price)


dta_sample <- dta_sample %>% filter(price>1000,
                                    price<30000000,
                                    odometer<500000,
                                    odometer>1000)
quantile(dta_sample$odometer,seq(0,1,.01))

dta_sample<- dta_sample %>% mutate(log_price=log(price))

dta_sample_small <- dta_sample %>% dplyr::select(log_price,odometer,type,manufacturer, ak,al,ar, az ,ca)

dta_sample_small <- na.omit(dta_sample_small) #tiro las missing
# # -----------------------------------------------------------------------
# Regresion Lineal --------------------------------------------------------
# # -----------------------------------------------------------------------
?lm #se usa para modelos del estilo de clase f(x)=\beta_0 + \beta_1 x1 + ....+\beta_p xp


reg1<-lm(log_price~odometer,data=dta_sample_small)
summary(reg1)


reg2<-lm(log_price~odometer+ak+al+ar+az,data=dta_sample_small)
summary(reg2)

yhat_r1<-predict(reg1) #prediccion
yhat_r2<-predict(reg2) #prediccion
tail(yhat_r1)

stargazer::stargazer(reg1,reg2,type="text")



# Enfoque de validacion

index <- createDataPartition(dta_sample_small$log_price, p = 0.7, list = FALSE)
?createDataPartition #help
training <- dta_sample_small[index,]
testing <- dta_sample_small[-index,]


reg1<-lm(log_price~odometer,data=training)
reg2<-lm(log_price~odometer+ak+al+ar+az,data=training)
reg3<-lm(log_price~odometer+ak+al+ar+az+manufacturer,data=training)
reg4<-lm(log_price~odometer+ak+al+ar+az+manufacturer+factor(type),data=training)
reg5<-lm(log_price~poly(odometer,5):factor(type)+ak+al+ar+az+manufacturer,data=training)
#stargazer::stargazer(reg1,reg2,reg3,type="text")


testing<-testing %>% mutate(yhat1=predict(reg1,newdata = testing),
                            yhat2=predict(reg2,newdata = testing),
                            yhat3=predict(reg3,newdata = testing),
                            yhat4=predict(reg4,newdata = testing),
                            yhat5=predict(reg5,newdata = testing)
                            )

testing<-testing %>% mutate(y_yhat1=(log_price-yhat1)^2,
                            y_yhat2=(log_price-yhat2)^2,
                            y_yhat3=(log_price-yhat3)^2,
                            y_yhat4=(log_price-yhat4)^2,
                            y_yhat5=(log_price-yhat5)^2
)

#MSE= Bias^2(f) +V(f)
mean(testing$y_yhat1)
mean(testing$y_yhat2)
mean(testing$y_yhat3)
mean(testing$y_yhat4)
mean(testing$y_yhat5)


#LOOCV, with caret



regressControl  <- trainControl(method="LOOCV") 

mod1 <- train(log_price ~ odometer,
                 data = training[1:100,],
                 method  = "lm",
                 trControl = regressControl)

print(mod1)


mod2 <- train(log_price ~ odometer + factor(type),
                 data = training[1:100,],
                 method  = "lm",
                 trControl = regressControl)
print(mod1)
print(mod2)




regressControlcv  <- trainControl(method="cv",
                                number=10) 

mod3 <- train(log_price ~ odometer + factor(type)+manufacturer,
              data = training,
              method  = "lm",
              trControl = regressControlcv)

print(mod3)


mod4 <- train(log_price ~ odometer:factor(type):factor(manufacturer),
              data = training,
              method  = "lm",
              trControl = regressControlcv)
print(mod4)
