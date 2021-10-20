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
set.seed(1199)
#dta_baseR<-read.csv(here("vehicles.csv"))
# dta_tidyverse<-read_csv(here("vehicles.csv"))
# dta_tidyverse2<-na.omit(dta_tidyverse)
# dta_sample<-dta_tidyverse[1:100000,]
#write_csv(dta_sample,here("sample_vehicles.csv"))
dta_sample<-read_csv("sample_vehicles.csv") 


# # -----------------------------------------------------------------------
# Limpiar datos -----------------------------------------------------------
# # -----------------------------------------------------------------------

#Tidyverse vs BaseR
## Estas dos lineas hacen lo mismo
str(dta_sample)
glimpse(dta_sample)
  

#Filtrar
dta_sample %>% 
  filter(is.na(price))


# ordenar
dta_sample %>% 
  arrange(year)

dta_sample %>% 
  arrange(desc(year))

#renombrar
dta_sample %>%
  rename(precio=price, modelo=model, condicion=condition) 

dta_sample %>%
  select(precio=price, modelo=model, condicion=condition) 



#Fitrar y hacer resumer

dta_sample %>% filter(manufacturer=="audi") %>% group_by(region) %>% summarise(odometer_mean = mean(odometer))
summarise(group_by(filter(sample, manufacturer=="audi"), region), odometer_mean = mean(odometer))

#Recordar: Usar espacio vertical no cuesta nada y ayuda a la legibilidad
dta_sample %>% 
  filter(manufacturer=="audi") %>% 
  group_by(region) %>% 
  summarise(odometer_mean = mean(odometer))

dta_sample %>% 
  select(precio, year) %>%
  mutate(
    logprecio =log(precio), ## Separate with a comma
    comment = paste0("El log precio es:", logprecio)
  )



# # -----------------------------------------------------------------------
# Visualizar --------------------------------------------------------------
# # -----------------------------------------------------------------------

plot(year,price)
plot(dta_sample$year,dta_sample$price)

plot(dta_sample$year,log(dta_sample$price))

mean_year<- dta_sample%>%
  group_by(year) %>% 
  summarise(price = mean(price,na.rm=TRUE),
            obs=n())

plot(mean_year$year,log(mean_year$price))

ggplot(data=mean_year,aes(x=year,y=log(price))) +
  geom_line() +
  geom_smooth(method="lm")+
  theme_bw()



# # -----------------------------------------------------------------------
# Regresion Lineal --------------------------------------------------------
# # -----------------------------------------------------------------------

reg1<-lm(price~odometer+factor(region),data=dta_sample)
summary(reg1)

reg2<-lm(price~odometer+factor(year)+factor(region),data=dta_sample)












