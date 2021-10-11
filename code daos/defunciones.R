

# librarys ----------------------------------------------------------------

# cargamos algunas librerias necesarias, las cuales nos van a ayudar 
# a poder transformar los datos y manipularlos adecuadamente para 
# poder manejarlos como series de tiempo

library(tidyverse) #install.packages("tidyverse")



# load data ---------------------------------------------------------------

# a continuación cargamos los datos, para ello conseguimos la url, de la pagina
# 'https://datos.covid-19.conacyt.mx/#DownZCSV', de donde descargamos la base de 
# datos que corresponde a defunciones diarios por Estado + Nacional

# 'https://datos.covid-19.conacyt.mx/Downloads/Files/Casos_Diarios_Estado_Nacional_Confirmados_20211009.csv'
# 'https://datos.covid-19.conacyt.mx/Downloads/Files/Casos_Diarios_Estado_Nacional_Confirmados_20211006.csv'
#------------- añadir fecha actual automaticamente
# obtenemos la fecha del dia anterior
fecha_yesterday <- Sys.Date()-1; fecha_yesterday
# convertimos ese objeto a uno de tipo "character"
fecha_yesterday <- as.character(fecha_yesterday); fecha_yesterday
# eliminamos los "-", para obtener la fecha corrida
fecha_yesterday <- gsub("-", "",fecha_yesterday); fecha_yesterday

# la siguiente url contiene el archivo CSV del 06 de octubre de 2021
# con la información correspondiente , la cual va a ser modificada
url_covid <- 'https://datos.covid-19.conacyt.mx/Downloads/Files/Casos_Diarios_Estado_Nacional_Defunciones_20211006.csv'

# igualemnte con la función gsub, reemplazamos ahora 
# en la url los ultimos valores por la fecha actuañ
url_covid <- gsub("20211006", fecha_yesterday, url_covid); url_covid


data <- read.csv(url_covid, header = TRUE)

# head(data)
# View(data)
# dim(data)
# str(data)
# names(data)

# filter data -------------------------------------------------------------

data <- data %>% 
  select(-cve_ent, -poblacion) %>% 
  pivot_longer(!nombre, names_to = "fecha", values_to = "defunciones") %>% 
  pivot_wider(names_from = nombre, values_from = defunciones) %>% 
  mutate(fecha = gsub("X", "", fecha)) %>% 
  mutate(fecha = as.Date(fecha, "%d.%m.%Y")) %>% 
  select(c(2:33),1)

# codigo para valores perdidos

if (any(is.na(data)) == TRUE) {data = tidyr::drop_na(data)}  # TRUE = hay al menos un valor NA


# head(data)
# View(data)
# dim(data)
# str(data)
# names(data)


# save the new data frame -------------------------------------------------

write.csv(data, 
          file = 'C:/Users/David/OneDrive/Documentos/DAOS curses/Datalab SDC4/demo 1/liquibase-covid/code daos/defunciones.csv', 
          row.names = F)

# time series with ts -----------------------------------------------------

# example de time series de aguascalientes 

aguascalientes <- ts(data[2],     
                     start = c(2020, as.numeric(format(data$fecha[1], "%j"))),
                     frequency = 365)
plot(aguascalientes)
