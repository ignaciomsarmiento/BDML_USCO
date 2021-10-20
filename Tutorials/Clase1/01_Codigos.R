#######################################################################
#  Aprendizaje y Minería de Datos para los Negocios 
#  Author: Ignacio Sarmiento-Barbieri (i.sarmiento at uniandes.edu.co)
#  please do not cite or circulate without permission
#######################################################################

# Carga de Paquetes a utilizar
library("here") #project location
library("tidyverse") #data wrangling 




# Leer los datos (disponibles en https://www.kaggle.com/austinreese/craigslist-carstrucks-data?select=vehicles.csv)
dta_baseR<-read.csv(here("vehicles.csv"))
#dta_tidyverse<-read_csv(here("vehicles.csv"))
#sample<-dta_tidyverse[1:100000,]
#write_csv(sample,here("sample_vehicles.csv"))
dta_sample<-read_csv("https://www.dropbox.com/s/1xr1qvjpehnukec/sample_vehicles.csv?dl=0") #cargar desde dropbox 



# Que es "tidy" data?
  


## Estas dos lineas hacen lo mismo
sample %>% filter(manufacturer=="audi") %>% group_by(region) %>% summarise(odometer_mean = mean(odometer))
summarise(group_by(filter(sample, manufacturer=="audi"), region), odometer_mean = mean(odometer))



sample %>% 
  filter(manufacturer=="audi") %>% 
  group_by(region) %>% 
  summarise(odometer_mean = mean(odometer))


#Recordar: Usar espacio vertical no cuesta nada y ayuda a la legibilidad

