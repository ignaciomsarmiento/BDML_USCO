#######################################################################
#  Aprendizaje y Minería de Datos para los Negocios 
#  Author: Ignacio Sarmiento-Barbieri (i.sarmiento at uniandes.edu.co)
#  please do not cite or circulate without permission
#######################################################################

# Carga de Paquetes a utilizar
library("here") #project location
library("tidyverse") #data wrangling 

# # -----------------------------------------------------------------------
# Leer los datos
#(Fuente: https://www.kaggle.com/austinreese/craigslist-carstrucks-data?select=vehicles.csv)
# # -----------------------------------------------------------------------
#set.seed(1199)
#dta_baseR<-read.csv(here("vehicles.csv"))
# dta_tidyverse<-read_csv(here("vehicles.csv"))
# dta_tidyverse2<-na.omit(dta_tidyverse)
# dta_sample<-dta_tidyverse[1:40000,]
#write_csv(dta_sample,here("sample_vehicles.csv"))

dta1<-read.csv("sample_vehicles.csv") #baseR
dta_sample<-read_csv("sample_vehicles.csv") #tidyverse
here()
dta_sample2<-read_csv("~/Dropbox/Teaching/2021/Surcolombiana/Tutorials/sample_vehicles.csv")
#para llamar al Help
?read.csv
?read_csv


# # -----------------------------------------------------------------------
# Limpiar datos -----------------------------------------------------------
# # -----------------------------------------------------------------------

#Tidyverse vs BaseR
## Estas dos lineas hacen lo mismo
str(dta_sample) #BaseR
glimpse(dta_sample) #Tidyverse
  



#Filtrar
missing_sample<-dta_sample %>% filter(is.na(manufacturer))
dta_sample<-dta_sample %>% filter(!is.na(manufacturer)) #Tidyverse a través de dplyr
dta1<- dta1[!is.na(dta1$manufacturer),]  #baseR

#borrar
rm(dta_sample2) 
rm(mi_nombre,x,y)


table(dta_sample$manufacturer)

ferrari<- dta_sample %>% filter(manufacturer=="ferrari")

# ordenar
ferrari<- ferrari %>% arrange(price)
ferrari<- ferrari  %>%  arrange(desc(price))


#renombrar
dta_sample<-dta_sample %>% rename(precio=price, modelo=model, condicion=condition) 
glimpse(dta_sample) # ver un glimpse
colnames(dta_sample) #nombre de las columnas

dta_sub<-dta_sample %>% select(precio, modelo, condicion) 
glimpse(dta_sub)


#Fitrar y hacer resumer

dta_sample %>% filter(manufacturer=="audi") %>% group_by(region) %>% summarise(odometer_mean = mean(odometer)) #tidyverse w/pipes

summarise(group_by(filter(dta_sample, manufacturer=="audi"), region), odometer_mean = mean(odometer)) #sin pipes, mas dificil de leer

#Recordar: Usar espacio vertical no cuesta nada y ayuda a la legibilidad
dta_audi<-dta_sample %>% 
            filter(manufacturer=="audi") %>% 
            group_by(region) %>% 
            summarise(odometer_mean = mean(odometer))



dta_sample<-dta_sample %>% 
              select(precio, year) %>%
              mutate(
                logprecio =log(precio), ## Separate with a comma
                comment = paste0("El log precio es:", logprecio)
              )



# # -----------------------------------------------------------------------
# Visualizar --------------------------------------------------------------
# # -----------------------------------------------------------------------

plot(year,price)
plot(dta_sample$year,dta_sample$precio)

plot(dta_sample$year,log(dta_sample$precio))

#media por año
mean_year<- dta_sample %>%
  group_by(year) %>% 
  summarise(price = mean(precio,na.rm=TRUE),
            obs=n())


#que esta pasando en 1993?
y1993<- dta_sample %>% 
          filter(year==1993) %>% 
          arrange(desc(precio))

#Filtremos ese dato raro
dta_sample<-dta_sample %>% filter(precio<999999)


#media por año
mean_year<- dta_sample %>%
  group_by(year) %>% 
  summarise(price = mean(precio,na.rm=TRUE),
            obs=n())

plot(mean_year$year,log(mean_year$price)) #baseR


ggplot(data=mean_year,aes(x=year,y=log(price))) +
  geom_point() +
  geom_smooth(method="lm") +
  theme_classic()



# # -----------------------------------------------------------------------
# Regresion Lineal --------------------------------------------------------
# # -----------------------------------------------------------------------
?lm #se usa para modelos del estilo de clase f(x)=\beta_0 + \beta_1 x1 + ....+\beta_p xp


reg1<-lm(price~year,data=mean_year)
summary(reg1)

mean_year<- mean_year %>% filter(price>0)
reg2<-lm(log(price)~year,data=mean_year)
summary(reg2)

#como usar modelos lineales a traves de lm para 
#PREDECIR!!!!!












