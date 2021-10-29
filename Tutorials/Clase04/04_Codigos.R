#######################################################################
#  Aprendizaje y Minería de Datos para los Negocios 
#  Author: Ignacio Sarmiento-Barbieri (i.sarmiento at uniandes.edu.co)
#  please do not cite or circulate without permission
#######################################################################

# Carga de Paquetes a utilizar
library("here") #project location
library("tidyverse") #for data wrangling
library("ISLR") #ML

#install.packages("ISLR",dependencies = TRUE)

# # -----------------------------------------------------------------------
# PCA -------------------------------------------------------------------
# # -----------------------------------------------------------------------
set.seed(101010) #sets a seed 

data(USArrests)
View(USArrests)


S<-cov(USArrests)
eigen(USArrests)

eig<-eigen(S)
eig_values<-eig$values
eig_values<-eig$vectors


results<-prcomp(dtaw[-1],scale=TRUE)
ev <- results$sdev^2
ev
#stats::screeplot(x)
results
#calculate total variance explained by each principal component
var_explained = results$sdev^2 / sum(results$sdev^2)
length(var_explained)
#create scree plot
library(ggplot2)


db<-tibble(x=c(1:12), var=var_explained)
db<- db %>% arrange(x) %>% mutate(var_acum=cumsum(var_explained))

ggplot(db,aes(x=x,y=var_explained)) + 
  geom_line(size=1, col="#af8dc3") +
  geom_point(size=2, col="#af8dc3") +
  theme_bw() +
  scale_x_continuous(name="Componente Principal",breaks=seq(1,length(var_explained),1))+
  scale_y_continuous(name="Proporción de Varianza Explicada",limits=c(0,1),breaks=seq(0,1,.1))+
  #ylim(0,1.1) +
  theme(#axis.text=element_blank(),
    #axis.ticks=element_blank(),
    text = element_text(size=11)
  )

ggplot(db,aes(x=x,y=var_acum)) + 
  geom_line(size=1, col="#af8dc3") +
  geom_point(size=2, col="#af8dc3") +
  theme_bw() +
  scale_x_continuous(name="Componente Principal",breaks=seq(1,length(var_explained),1))+
  scale_y_continuous(name="Proporción de Varianza Explicada Acumulada",limits=c(0,1),breaks=seq(0,1,.1))+
  #ylim(0,1.1) +
  theme(#axis.text=element_blank(),
    #axis.ticks=element_blank(),
    text = element_text(size=11)
  )

