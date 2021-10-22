#######################################################################
#  Aprendizaje y Minería de Datos para los Negocios 
#  Author: Ignacio Sarmiento-Barbieri (i.sarmiento at uniandes.edu.co)
#  please do not cite or circulate without permission
#######################################################################

# Carga de Paquetes a utilizar
library("here") #project location
library("tidyverse") #data wrangling
library("caret") #ML

# # -----------------------------------------------------------------------
# Leer los datos
#(Fuente: https://www.kaggle.com/austinreese/craigslist-carstrucks-data?select=vehicles.csv)
# # -----------------------------------------------------------------------

dta_sample<-read_csv("sample_vehicles.csv") #tidyverse



# # -----------------------------------------------------------------------
# Regresion Lineal --------------------------------------------------------
# # -----------------------------------------------------------------------
?lm #se usa para modelos del estilo de clase f(x)=\beta_0 + \beta_1 x1 + ....+\beta_p xp

dta_sample<-dta_sample %>% dplyr::filter(price>0)
reg1<-lm(price~odometer,data=dta_sample)
summary(reg1)


reg2<-lm(log(price)~odometer,data=dta_sample)
summary(reg2)


stargazer::stargazer(reg1,reg2,type="text")




dta_sample_small <- dta_sample %>% dplyr::select(odometer,type,manufacturer,region)
summary(dta_sample_small)  
dta_sample_small <- na.omit(dta_sample_small)            


index <- createDataPartition(dta_sample$price, p = 0.8, list = FALSE)
training <- dta_sample[index,]
testing <- dta_sample[-index,]


#crossvalidation
regressControl  <- trainControl(method="cv",
                                number = 5
) 

mod1 <- train(price ~ odometer,
                 data = dta_sample,
                 method  = "lm",
                 trControl = regressControl)




mod2 <- train(price ~ odometer + factor(type),
                 data = dta_sample,
                 method  = "lm",
                 trControl = regressControl)

mod3 <- train(price ~ odometer + factor(type)+factor(manufacturer),
              data = dta_sample,
              method  = "lm",
              trControl = regressControl)

mod4 <- train(price ~ odometer + factor(type)+factor(manufacturer)+factor(model),
              data = dta_sample,
              method  = "lm",
              trControl = regressControl)

