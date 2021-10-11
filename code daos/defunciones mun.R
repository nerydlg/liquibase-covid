# library ----------------------------------------------------------------

# cargamos algunas librerias necesarias, las cuales nos van a ayudar 
# a poder transformar los datos y manipularlos adecuadamente para 
# poder manejarlos como series de tiempo

library(tidyverse)  #install.packages("tidyverse")

# load data ---------------------------------------------------------------

# a continuación cargamos los datos, para ello conseguimos la url, de la pagina
# 'https://datos.covid-19.conacyt.mx/#DownZCSV', de donde descargamos la base de 
# datos que corresponde a Casos diarios por municipio

#------------- añadir fecha actual automaticamente
# obtenemos la fecha del dia anterior
fecha_yesterday <- Sys.Date()-1; fecha_yesterday
# convertimos ese objeto a uno de tipo "character"
fecha_yesterday <- as.character(fecha_yesterday); fecha_yesterday
# eliminamos los "-", para obtener la fecha sin guiones
fecha_yesterday <- gsub("-", "",fecha_yesterday); fecha_yesterday

# la siguiente url contiene el archivo CSV del 10 de octubre de 2021
# con la información correspondiente , la cual va a ser modificada
url_covid <- 'https://datos.covid-19.conacyt.mx/Downloads/Files/Casos_Diarios_Municipio_Defunciones_20211010.csv'
  

# igualemnte con la función gsub, reemplazamos ahora 
# en la url los ultimos valores por la fecha actuañ
url_covid <- gsub("20211010", fecha_yesterday, url_covid); url_covid

data <- read.csv(url_covid, header = TRUE)

if (any(is.na(data)) == TRUE) {data = tidyr::drop_na(data)}  # TRUE = hay al menos un valor NA

# datos con información de destinos turisticos
# ahora leemos los datos que vamos a cruzar
NCLugares <- 'C:/Users/David/OneDrive/Documentos/DAOS curses/Datalab SDC4/demo 1/liquibase-covid/code daos/Destinos_mexico.csv'
data2 <- read.csv(NCLugares, header = TRUE)

if (any(is.na(data2)) == TRUE) {data2 = tidyr::drop_na(data2)}  # TRUE = hay al menos un valor NA


# leemos la base de defunciones para obtener solamente a la ciudad de mexico
url_covid2 <- 'https://datos.covid-19.conacyt.mx/Downloads/Files/Casos_Diarios_Estado_Nacional_Defunciones_20211006.csv'
url_covid2 <- gsub("20211006", fecha_yesterday, url_covid2); url_covid2

data3 <- read.csv(url_covid2, header = TRUE)


# primeros cruzamos la información del data frame de municipios con
# el data frame de destinos turisticos, mediante la variable "cve_ent"

data4 <- data %>% inner_join(dplyr::select(data2, "cve_ent"), by = "cve_ent")

# posteriormente añadimos la fila con la información que corresponde a la ciudad de mexico

df <- data4 %>% 
  rbind(data3 %>% filter(nombre == "DISTRITO FEDERAL")) 


# filter data -------------------------------------------------------------

df <- df %>% 
  select(-cve_ent, -poblacion) %>% 
  pivot_longer(!nombre, names_to = "fecha", values_to = "confirmados") %>% 
  pivot_wider(names_from = nombre, values_from = confirmados) %>% 
  mutate(fecha = gsub("X", "", fecha)) %>% 
  mutate(fecha = as.Date(fecha, "%d.%m.%Y")) %>% 
  select("Ciudad de Mexico" = "DISTRITO FEDERAL", "Acapulco" = "Acapulco de Juarez",
         "Campeche" = "Campeche", "Cancun" = "Benito Juarez", "Chichen Itza" = "Tinum",
         "Chihuahua" = "Chihuahua", "Cozumel" = "Cozumel", "Cuernavaca" = "Cuernavaca",
         "Guadalajara" = "Guadalajara", "Hermosillo" = "Hermosillo", "Isla Mujeres" = "Isla Mujeres",
         "Ixtapa Zihuatanejo" = "Zihuatanejo de Azueta", "La Paz" = "La Paz", "Los Cabos" = "Los Cabos",
         "Merida" = "Merida", "Monterrey" = "Monterrey", "Morelia" = "Morelia",
         "Nuevo Vallarta" = "Bahia de Banderas", "Oaxaca de Juarez" = "Oaxaca de Juarez",
         "Playa del Carmen" = "Solidaridad", "Puebla" = "Puebla", "Puerto Vallarta" = "Puerto Vallarta",
         "Queretaro" = "Queretaro", "San Luis Potosi" = "San Luis Potosi",
         "San Miguel de Allende" = "San Miguel de Allende", "Taxco" =  "Taxco de Alarcon",
         "Tequila" = "Tequila", "Tlaxcala" = "Tlaxcala", "Tuxtla Gutierrez" = "Tuxtla Gutierrez",
         "Villahermosa" = "Centro", "Zacatecas" = "Zacatecas", "fecha")

# codigo para valores perdidos

if (any(is.na(df)) == TRUE) {df = tidyr::drop_na(df)}  # TRUE = hay al menos un valor NA

# save the new data frame -------------------------------------------------

# correrlo una vez para guardarlo, despues comentar la función
write.csv(df, 
          file = 'C:/Users/David/OneDrive/Documentos/DAOS curses/Datalab SDC4/demo 1/liquibase-covid/code daos/defunciones mun.csv', 
          row.names = F)

# time series with ts -----------------------------------------------------

# example de time series de aguascalientes 

acapulco <- ts(df[2], 
               start = c(2020, as.numeric(format(df$fecha[1], "%j"))),
               frequency = 365)
plot(acapulco)



