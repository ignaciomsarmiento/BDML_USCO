#######################################################################
#  Aprendizaje y Minería de Datos para los Negocios 
#  Author: Ignacio Sarmiento-Barbieri (i.sarmiento at uniandes.edu.co)
#  please do not cite or circulate without permission
#######################################################################

# Carga de Paquetes a utilizar
library("here") #project location
library("tidyverse") #for data wrangling
library("ISLR") #Introduction to statistical learning
??ISLR #no funciona
help(package="ISLR") #funciona
#install.packages("ISLR",dependencies = TRUE)

# # -----------------------------------------------------------------------
# PCA -------------------------------------------------------------------
# # -----------------------------------------------------------------------
set.seed(101010) #sets a seed 
?USArrests
data(USArrests)
View(USArrests)



# PCA componentes principales ---------------------------------------------
#dSd = lambda
# S=Cov(X)

?scale #para escalar las variables
summary(USArrests)

?apply
apply(USArrests,2,var) #itera sobre la dimension 2 y calcula la varianza
diag(var(USArrests)) #calcula la matriz de varianzas y con diab() le extraigo la diagonal principal
diag(cov(USArrests)) #similar

#re-escalados los datos
USArrests<- USArrests %>% mutate(Murder=scale(Murder),
                                 Rape=scale(Rape),
                                 Assault=scale(Assault),
                                 UrbanPop=scale(UrbanPop))
apply(USArrests,2,mean)
diag(cov(USArrests)) #similar

#calculo la matriz de covarianza
S<-cov(USArrests)
dim(S)

#Calculo de los autovalores y autovectores
eigen(USArrests)  #ojo aca la matriz no es cuadrada
dim(USArrests)


eig<-eigen(S)
eig_values<-eig$values
eig_vectors<-eig$vectors

#proporcion de varianza explicada
eig$values/sum(eig$values)



#De forma automatica
?prcomp
pca_result<-prcomp(USArrests,center=TRUE,scale=TRUE)
pca_result

eig_vectors

ev <- pca_result$sdev^2 #recordemos que los eigenvalues son la varianza
ev
eig_values



#stats::screeplot(pca_result)

#calculate total variance explained by each principal component
var_explained = pca_result$sdev^2 / sum(pca_result$sdev^2)
length(var_explained)
#create scree plot
library(ggplot2)


db<-tibble(componentes=c(1:4), var=var_explained)
db<- db %>% arrange(componentes) %>% mutate(var_acum=cumsum(var_explained))

ggplot(db,aes(x=componentes,y=var_explained)) + 
  geom_line(size=1, col="#af8dc3") +
  geom_point(size=2, col="#af8dc3") +
  theme_classic() +
  scale_x_continuous(name="Componente Principal",breaks=seq(1,length(var_explained),1))+
  scale_y_continuous(name="Proporción de Varianza Explicada",limits=c(0,1),breaks=seq(0,1,.1))+
  #ylim(0,1.1) +
  theme(#axis.text=element_blank(),
    #axis.ticks=element_blank(),
    text = element_text(size=11)
  )

ggplot(db,aes(x=componentes,y=var_acum)) + 
  geom_line(size=1, col="#af8dc3") +
  geom_point(size=2, col="#af8dc3") +
  theme_classic() +
  scale_x_continuous(name="Componente Principal",breaks=seq(1,length(var_explained),1))+
  scale_y_continuous(name="Proporción de Varianza Explicada Acumulada",limits=c(0,1),breaks=seq(0,1,.1))+
  #ylim(0,1.1) +
  theme(#axis.text=element_blank(),
    #axis.ticks=element_blank(),
    text = element_text(size=11)
  )


pca_result$center
pca_result$scale

apply(USArrests,2,mean)
sqrt(diag(cov(USArrests)))

pca_result


biplot(pca_result, scale = 0)

delta1<-as.numeric(-1*pca_result$rotation[,1])
X<-as.matrix(USArrests)
delta2<-as.numeric(-1*pca_result$rotation[,2])

db_cities<-tibble(city=rownames(USArrests),f1=X%*%delta1, f2=X%*%delta2)



# # -----------------------------------------------------------------------
# Clusters ----------------------------------------------------------------
# # -----------------------------------------------------------------------
set.seed(2)

x<- matrix(rnorm(50*2),ncol=2)
x[1:25,1]<-x[1:25,1]+3
x[1:25,2]<-x[1:25,2]-4


plot(x[,1],x[,2])

#k=2
kmeans_results<-kmeans(x,2,nstart=20)
plot(x,col=(kmeans_results$cluster+1))



#k=3
set.seed(4)
kmeans_results<-kmeans(x,3,nstart=20)
kmeans_results$cluster
plot(x,col=(kmeans_results$cluster+1))



#Comparar los nstart
set.seed(4)
kmeans_results_start1<-kmeans(x,3,nstart=1)
kmeans_results_start1$tot.withinss

kmeans_results_start20<-kmeans(x,3,nstart=20)
kmeans_results_start20$tot.withinss

kmeans_results_start50<-kmeans(x,3,nstart=50)
kmeans_results_start50$tot.withinss



#NCI60
data("NCI60")
dim(NCI60$data) #n<<<<<k

data<-NCI60$data
labs<-NCI60$labs
table(labs)

pr.out<-prcomp(data,scale=TRUE)
pr.out

#crea colores
Cols <- function(vec) {
  cols <- rainbow(length(unique(vec)))
  return(cols[as.numeric(as.factor(vec))]) 
}

plot(pr.out$x[, 1:2], col = Cols(labs), pch = 19, xlab = "Z1", ylab = "Z2")
plot(pr.out$x[, 1:3], col = Cols(labs), pch = 19, xlab = "Z1", ylab = "Z3")

?choose
choose(6830,2)

summary(pr.out)

(44/6830)*100

plot(pr.out)
