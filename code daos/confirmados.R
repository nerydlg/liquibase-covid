

# library ----------------------------------------------------------------

# cargamos algunas librerias necesarias, las cueles nos van a ayudar 
# a poder transformar los datos y manipularlos adecuadamente para 
# poder manejarlos como series de tiempo

library(tidyverse) 



# load data ---------------------------------------------------------------

# a continuación cargamos los datos, para ello conseguimos la url, de la pagina
# 'https://datos.covid-19.conacyt.mx/#DownZCSV', de donde descargamos la base de 
# datos que corresponde a Casos diarios por Estado + Nacional

# la siguiente url contiene el archivo CSV, con la información correspondiente 

url_covid <- 'https://datos.covid-19.conacyt.mx/Downloads/Files/Casos_Diarios_Estado_Nacional_Confirmados_20211006.csv'

data <- read.csv(url_covid, header = TRUE)

# head(data)
# View(data)
# dim(data)
# str(data)
# names(data)

# filter data -------------------------------------------------------------

data <- data %>% 
  select(-cve_ent, -poblacion) %>% 
  pivot_longer(!nombre, names_to = "fecha", values_to = "confirmados") %>% 
  pivot_wider(names_from = nombre, values_from = confirmados) %>% 
  mutate(fecha = gsub("X", "", fecha)) %>% 
  mutate(fecha = as.Date(fecha, "%d.%m.%Y"))

# codigo para valores perdidos

if (any(is.na(data)) == TRUE) {data = na.omit(data)}  # TRUE = hay al menos un valor NA


# head(data)
# View(data)
# dim(data)
# str(data)
# names(data)


# save the new data frame -------------------------------------------------

# correrlo una vez para guardarlo, despues comentar la función
write.csv(data, 
          file = 'C:/Users/David/OneDrive/Documentos/DAOS curses/Datalab SDC4/demo 1/liquibase-covid/code daos/confirmados.csv', 
          row.names = F)

# time series with ts -----------------------------------------------------

# example de time series de aguascalientes 

aguascalientes <- ts(data[2],     # random data
           start = c(2020, as.numeric(format(data$fecha[1], "%j"))),
           frequency = 365)
plot(aguascalientes)
  

