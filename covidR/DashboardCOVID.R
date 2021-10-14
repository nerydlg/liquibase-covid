library(shinydashboard)
library(tidyverse)
library(lubridate)
library(forecast)
#library(smooth)

# Funcion Formatear Decimal
FormatDecimal <- function(x, k) {
  return(format(round(as.numeric(x), k), nsmall=k))
}
# Funcion para determinar la tendencia del pronostico
#direction<-function(x){
#  if(all(diff(x)>0)) return('Alcista')
#  if(all(diff(x)<0)) return('Bajista')
#  return('Sin Cambios')
#}

# Funcion para determinar la tendencia del pronostico
direction2<-function(x){
  n <- length(x)
  suma_nums = 0
  suma_valores = 0
  datos_multi = 0 
  nums_alcuadrado = 0
  
  for(i in 1:n){
    suma_nums <- suma_nums + i
    suma_valores <- suma_valores + x[i]
    datos_multi <- datos_multi + (i * x[i])
    nums_alcuadrado <- nums_alcuadrado + (i * i)
  } 
  
  numerador = (n * datos_multi) - (suma_nums * suma_valores)
  denominador = (n * nums_alcuadrado) - (suma_nums **2)
  c = numerador / denominador
  if (c > 0){ valorfinal <- "Alcista"}
  if (c < 0){ valorfinal <- "Bajista"}
  if (c == 0) {valorfinal <- "Sin Tendencia"}
  
  return(valorfinal)
}

# Carga datos
arch <- "FallecidosNacional.csv" # Fallecidos Nacional
arch2 <- "NCNacional.csv"        # Confirmados Nacional
arch3 <- "PoblacionEdos.csv"     # Poblacion de los Estados
arch4 <- "LigaTurEdos.csv"       # Palabra para acceder a Visitmexico.com
arch5 <- "SemaforoEdos.csv"      # Color semaforo por Estado
arch6 <- "NCLugares.csv"        # Confirmados Lugares
arch7 <- "FallecidosLugares.csv"        # Fallecidos Lugares
arch8 <- "SemaforoLugares.csv"        # Color Semaforo Lugares
datos <- read.csv(arch, header=TRUE, sep=",") # Fallecidos
datos2 <- read.csv(arch2, header=TRUE, sep=",") # Confirmados
datos3 <- read.csv(arch3, header=TRUE, sep=",") # Poblacion de los Estados
datos4 <- read.csv(arch4, header=TRUE, sep=",") # Palabra para acceder a Visitmexico.com
datos5 <- read.csv(arch5, header=TRUE, sep=",") # Color semaforo por Estado
datos6 <- read.csv(arch6, header=TRUE, sep=",") # Confirmados Lugares
datos7 <- read.csv(arch7, header=TRUE, sep=",") # Fallecidos Lugares
datos8 <- read.csv(arch8, header=TRUE, sep=",") # Color Semaforo Lugares
semedos <- t(datos5) # Genera la traspuesta de los semaforos de Estados
semlugs <- t(datos8) # Genera la traspuesta de los semaforos de Lugares

# Definimos fecha inicial y final de los datos
fechaini = "01/04/2020"
fechafin = "31/09/2021"
# Definimos año y mes de proyeccion proximos 30 dias
anioproy = 2021
mesproy = 10

# Convertimos a serie de datos iniciando en Abril de 2020
i = 33
# Elegimos Nacional
datoscovid=ts(datos2[i], start = c(2020, 92), freq = 365)

#resumen <-summary(covid2.ts)
#resumen
nomedo = names(datos2[i])
#titgraf <- paste("Casos Confirmados NacionalNuevos Casos de: ", nomedo)
titgraf <- "Casos Confirmados Nacional"

# Genera Tabla de Letalidad por Estados
nomestados <- vector(mode="character", length=33) # Vector nombre Estados
dconfirmados <- vector(mode="numeric", length=33) # Vector confirmados por Estado
dfallecidos <- vector(mode="numeric", length=33) # Vector fallecidos por Estado
dletalidad <- vector(mode="numeric", length=33) # Vector letalidad por Estado
semaforoedos <- vector(mode="character", length=33) # Vector semaforo por Estado

for(i in 1:33){
  nomedo = names(datos2[i]) # Obtiene nombre Estado
  nomestados[i] <- nomedo # Carga Estado a Vector
  semaforoedos[i] <- semedos[i] # Carga Semaforo por Estado
  
  totfallecidos = sum(datos[i]) # Calcula total de fallecidos del Edo
  totconfirmados = sum(datos2[i]) # Calcula total confirmados
  dconfirmados[i] <- totconfirmados
  dfallecidos[i] <- totfallecidos
  tasaletal <- (totfallecidos / totconfirmados)*100 # Calcula tasa de letalidad
  #dletalidad[i] <- FormatDecimal(tasaletal, 2)
  dletalidad[i] <- round(tasaletal, digits = 2)
  
}
# Genera tabla de datos de letalidad
datosletalidad <- data.frame(nomestados,dconfirmados,dfallecidos,dletalidad,semaforoedos)
names(datosletalidad) <- c('Estado', 'Confirmados', 'Fallecidos', 'Tasa de Letalidad', 'Semaforo Actual')

# Genera Tabla de Letalidad por Lugar
nomlugares <- vector(mode="character", length=31) # Vector nombre Lugares
dconfirmadoslugar <- vector(mode="numeric", length=31) # Vector confirmados por Lugar
dfallecidoslugar <- vector(mode="numeric", length=31) # Vector fallecidos por Lugar
dletalidadlugar <- vector(mode="numeric", length=31) # Vector letalidad por Lugar
semaforolugares <- vector(mode="character", length=31) # Vector semaforo de Lugares

for(i in 1:31){
  nomlugar = names(datos7[i]) # Obtiene nombres de lugares
  nomlugares[i] <- nomlugar # Carga Estado a Vector
  semaforolugares[i] <- semlugs[i] # Carga Semaforo de lugares
  
  totfallecidos = sum(datos7[i]) # Calcula total de fallecidos del lugar
  totconfirmados = sum(datos6[i]) # Calcula total confirmados del lugar
  dconfirmadoslugar[i] <- totconfirmados
  dfallecidoslugar[i] <- totfallecidos
  tasaletal <- (totfallecidos / totconfirmados)*100 # Calcula tasa de letalidad
  #dletalidad[i] <- FormatDecimal(tasaletal, 2)
  dletalidadlugar[i] <- round(tasaletal, digits = 2)
}
# Genera tabla de datos de letalidad de Lugares
datosletalidadlugar <- data.frame(nomlugares,dconfirmadoslugar,dfallecidoslugar,dletalidadlugar,semaforolugares)
names(datosletalidadlugar) <- c('Lugar', 'Confirmados', 'Fallecidos', 'Tasa de Letalidad', 'Semaforo Actual')

# Inicia codigo de Shiny
ui <- dashboardPage(
  dashboardHeader(title = "TurisMex COVID"),
  dashboardSidebar( sidebarMenu(
    menuItem("Informacion General", tabName = "dashboard", icon = icon("dashboard")),
    menuItem("Pronóstico por Estado", tabName = "pronestado", icon = icon("virus")),
    menuItem("Pronóstico por Lugar", tabName = "pronlugar", icon = icon("virus")),
    menuItem("Letalidad por Estado", tabName = "tletalidad", icon = icon("skull-crossbones")),
    menuItem("Letalidad por Lugar", tabName = "tletalidadlugar", icon = icon("skull-crossbones")),
    menuItem("Autores", tabName = "textoautores", icon = icon("user-friends"))
  )),
  dashboardBody(
    tabItems(
      # First tab content
      tabItem(tabName = "dashboard",
              #fluidRow(
                #box(
                  plotOutput("plot1", height = 280), #Grafica Casos Confirmados Nacional
                  plotOutput("plot2", height = 280)  #Grafica Fallecidos Nacional
                    #)
                
                #box(
                #  title = "Controls",
                #  sliderInput("slider", "Number of observations:", 1, 100, 50)
                #)
             #)
      ),
      
      # Second tab content
      tabItem(tabName = "pronestado",
              h4("Pronóstico por Estado"),
              fluidRow(
                
                box(
                  title = "Opciones", status = "primary", solidHeader = TRUE,
                  selectInput("var", "Estado:",
                              choices = c("Nacional" = "33",
                                          "Aguascalientes" = "1",
                                          "Baja California" = "2",
                                          "Baja California Sur" = "3",
                                          "Campeche" = "4",
                                          "Chiapas" = "5",
                                          "Chihuahua" = "6",
                                          "Distrito Federal" = "7",
                                          "Coahuila" = "8",
                                          "Colima" = "9",
                                          "Durango" = "10",
                                          "Guanajuato" = "11",
                                          "Guerrero" = "12",
                                          "Hidalgo" = "13",
                                          "Jalisco" = "14",
                                          "Edo. de México" = "15",
                                          "Michoacan" = "16",
                                          "Morelos" = "17",
                                          "Nayarit" = "18",
                                          "Nuevo Leon" = "19",
                                          "Oaxaca" = "20",
                                          "Puebla" = "21",
                                          "Queretaro" = "22",
                                          "Quintana Roo" = "23",
                                          "San Luis Potosi" = "24",
                                          "Sinaloa" = "25",
                                          "Sonora" = "26",
                                          "Tabasco" = "27",
                                          "Tamaulipas" = "28",
                                          "Tlaxcala" = "29",
                                          "Veracruz" = "30",
                                          "Yucatan" = "31",
                                          "Zacatecas" = "32")),
                  
                  # Input 2: Selector tipo de pronostico
                  selectInput("pron", "Tipo de Pronóstico:",
                              choices = c("Red Neuronal" = "1",
                                          "Regresion" = "2",
                                          "ARIMA" = "3",
                                          #"TBATS" = "4",
                                          "Temporalidad" = "5"
                              )),
                  
                  # Input 3: Selector tipo de datos
                  selectInput("tdat", "Tipo de Casos:",
                              choices = c("Confirmados" = "1",
                                          "Fallecidos" = "2"
                                          
                              )),
                  width = 3), #box
                #),
                box(title = "Histórico", width = 9, status = "primary", solidHeader = TRUE,
                  plotOutput("mpgPlot", height = 250)),
                box(title = "Siguientes días", width = 12, status = "primary", solidHeader = TRUE,
                    plotOutput("sigPlot", height = 250)),
              ) # Fluidrow
              
      ), #Tabitem
      
      # Third tab content
      tabItem(tabName = "pronlugar",
              h4("Pronóstico por Lugar"),
              fluidRow(
                  box(
                  title = "Opciones", status = "primary", solidHeader = TRUE,
                  selectInput("var2", "Lugar:",
                              choices = c("Ciudad de Mexico" = "1",
                                          "Acapulco" = "2",
                                          "Campeche" = "3",
                                          "Cancun" = "4",
                                          "Chichen Itza" = "5",
                                          "Chihuahua" = "6",
                                          "Cozumel" = "7",
                                          "Cuernavaca" = "8",
                                          "Guadalajara" = "9",
                                          "Hermosillo" = "10",
                                          "Isla Mujeres" = "11",
                                          "Ixtapa Zihuatanejo" = "12",
                                          "La Paz" = "13",
                                          "Los Cabos" = "14",
                                          "Merida" = "15",
                                          "Monterrey" = "16",
                                          "Morelia" = "17",
                                          "Nuevo Vallarta" = "18",
                                          "Oaxaca de Juarez" = "19",
                                          "Playa del Carmen" = "20",
                                          "Puebla" = "21",
                                          "Puerto Vallarta" = "22",
                                          "Queretaro" = "23",
                                          "San Luis Potosi" = "24",
                                          "San Miguel de Allende" = "25",
                                          "Taxco" = "26",
                                          "Tequila" = "27",
                                          "Tlaxcala" = "28",
                                          "Tuxtla Gutierrez" = "29",
                                          "Villahermosa" = "30",
                                          "Zacatecas" = "31"
                                          
                              )),
                  
                  # Input 2: Selector tipo de pronostico
                  selectInput("pron2", "Tipo de Pronostico:",
                              choices = c("Red Neuronal" = "1",
                                          "Regresion" = "2",
                                          "ARIMA" = "3",
                                         # "TBATS" = "4",
                                          "Temporalidad" = "5"
                              )),
                  
                  # Input 3: Selector tipo de datos
                  selectInput("tdat2", "Tipo de Casos:",
                              choices = c("Confirmados" = "1",
                                          "Fallecidos" = "2"
                                          
                              )),
                  width = 3), #box
                #),
                box(title = "Histórico", width = 9, status = "primary", solidHeader = TRUE,
                    plotOutput("mpg2Plot", height = 250)),
                box(title = "Siguientes días", width = 12, status = "primary", solidHeader = TRUE,
                    plotOutput("sig2Plot", height = 250)),
              ) # Fluidrow
              
      ), #Tabitem
      
      # Cuarto tab
      tabItem(tabName = "tletalidad",
              h3("Letalidad por Estado"),
              dataTableOutput('tablaletalidad')
      ),
      
      # Quinto tab
      tabItem(tabName = "tletalidadlugar",
              h3("Letalidad por Lugar"),
              dataTableOutput('tablaletalidadlugar')
      ),
      
      # Sexto tab
      tabItem(tabName = "textoautores",
              h2("Autores"),
              img(src=paste0("https://1.bp.blogspot.com/-Q-C42bXQK50/YTFCnn8RKTI/AAAAAAAAAAU/AAIzhR9-rJUymMzD--BM5lMBnQFdlbZ3wCLcBGAsYHQ/s123/datalab.png")),
              h3("Angel Gonzalez Espinosa, email: aglezcripto@gmail.com"),
              h3("David Alejandro Ozuna Santiago, email: david117daos@gmail.com"),
              #h3("Juan Antonio Ríos Mercado, email: sec98b4e@gmail.com"),
              h3("Nery Asaid Delgado Estrada, email: ne.delgado@hotmail.com"),
              h3("Paula Andrea Abad, email: paulabad76@gmail.com"),
              a(href="https://turismexc.blogspot.com/2021/09/predicciones-de-casos-positivos-y.html","Descripcion del Proyecto TurisMex")
      )
    )
  )
)

server <- function(input, output) {
 
  output$plot1 <- renderPlot({
    datoscovid=ts(datos2[33], start = c(2020, 92), freq = 365)
    sumacasos = sum(datos2[33])
    
    titgraf <- paste("Casos Confirmados Nacional del ", fechaini, " al ", fechafin, ": ", formatC(sumacasos, big.mark=","))
    plot(datoscovid, main=titgraf, ylab="Casos", xlab="tiempo", col="red")
  })
  
  output$plot2 <- renderPlot({
    datoscovid=ts(datos[33], start = c(2020, 92), freq = 365)
    sumacasos = sum(datos[33])
    titgraf <- paste("Fallecidos Nacional del ", fechaini, "al ", fechafin, ": ", formatC(sumacasos, big.mark=","))
    plot(datoscovid, main=titgraf, ylab="Fallecidos", xlab="tiempo", col="red")
  })
  
  output$tablaletalidad <- renderDataTable(datosletalidad)
  
  output$tablaletalidadlugar <- renderDataTable(datosletalidadlugar)
  
  # Dibujamos Grafica proximos dias
  output$sigPlot <- renderPlot({
    cad2 <- c("Red Neuronal","Regresion","ARIMA","TBATS", "Temporalidad")
    j <- as.integer(input$pron)
    cad <- cad2[j]
    
    # Elegimos Estado
    i <- as.integer(input$var)
    nomedo = names(datos2[i])
    
    # Convertimos a serie de datos iniciando en Abril de 2020
    k <- as.integer(input$tdat)
    cad3 <- c("Confirmados","Fallecidos")
    cadtipo <- cad3[k]
    
    # Elegimos Serie de tiempo de Confirmados o de Fallecidos
    if (k == 1) { # Confirmados
      datoscovid=ts(datos2[i], start = c(2020, 92), freq = 365)
      #sumacasos = sum(datos2[i])
    }
    else {
      datoscovid=ts(datos[i], start = c(2020, 92), freq = 365)
      #sumacasos = sum(datos[i])
    }
    
    #titgraf <- paste("Pronostico ", cadtipo, " para los proximos 30 dias de: ", nomedo)
    titgraf <- paste("Pronostico ", cadtipo, " para los proximos 30 dias")
    covid2.ts=datoscovid
    
    # Dibujamos Pronostico proximos dias
    
    if (j == 2) { # Regresion
      regresion2 <- tslm(covid2.ts ~ trend + season)
      m8 <- forecast(regresion2, h=30)
      valpron_reg <- as.numeric(m8$mean)
      tendencia <- direction2(valpron_reg)
      titgraf <- paste(titgraf, " Tendencia ", tendencia)
      plot(valpron_reg, main=titgraf, ylab="Casos", xlab="dia proximo", type="l", col="red")
     
      #datosproyectados=ts(valpron_reg, start = c(anioproy, mesproy), freq = 365)
      #fit <- decompose(datosproyectados, type='multiplicative')
      # No funciono la funcion decompose con los datos proyectados
      #mediamovil<-sma(ts(valpron_reg),order=3)
      #autoplot(datosproyectados, series="Proyección")
    } else if (j == 3) { # ARIMA
      modelo_arima2 <- auto.arima(covid2.ts)
      m6 <- forecast(modelo_arima2, h=30)
      valpron_arima <- as.numeric(m6$mean)
      tendencia <- direction2(valpron_arima)
      titgraf <- paste(titgraf, " Tendencia ", tendencia)
      plot(valpron_arima, main=titgraf, ylab="Casos", xlab="dia proximo", type="l", col="red")
    }
    else if (j == 1) { # Red Neuronal
      red_neuronal2 <- nnetar(covid2.ts)
      m7 <- forecast(red_neuronal2, h=30)
      valpron_redn <- as.numeric(m7$mean)
      tendencia <- direction2(valpron_redn)
      titgraf <- paste(titgraf, " Tendencia ", tendencia)
      plot(valpron_redn, main=titgraf, ylab="Casos", xlab="dia proximo", type="l", col="red")
    }
    else if (j == 4) { # TBATS
      TBATS <- forecast(tbats(covid2.ts, biasadj=TRUE), h=30)
      valpron_tbats <- as.numeric(TBATS$mean)
      tendencia <- direction2(valpron_tbats)
      titgraf <- paste(titgraf, " Tendencia ", tendencia)
      plot(valpron_tbats, main=titgraf, ylab="Casos", xlab="dia proximo", type="l", col="red")
    }
    
  })
  
  # Dibujamos Grafica proximos dias
  output$sig2Plot <- renderPlot({
    cad2 <- c("Red Neuronal","Regresion","ARIMA","TBATS", "Temporalidad")
    j <- as.integer(input$pron2)
    cad <- cad2[j]
    
    # Elegimos Estado
    i <- as.integer(input$var2)
    nomlugar = names(datos6[i])
    
    # Convertimos a serie de datos iniciando en Abril de 2020
    k <- as.integer(input$tdat2)
    cad3 <- c("Confirmados","Fallecidos")
    cadtipo <- cad3[k]
    
    # Elegimos Serie de tiempo de Confirmados o de Fallecidos
    if (k == 1) { # Confirmados
      datoscovid=ts(datos6[i], start = c(2020, 92), freq = 365)
      #sumacasos = sum(datos2[i])
    }
    else {
      datoscovid=ts(datos7[i], start = c(2020, 92), freq = 365)
      #sumacasos = sum(datos[i])
    }
    
    titgraf <- paste("Pronostico ", cadtipo, " para los proximos 30 dias")
    covid2.ts=datoscovid
    
    # Dibujamos Pronostico proximos dias
    
    if (j == 2) { # Regresion
      regresion2 <- tslm(covid2.ts ~ trend + season)
      m8 <- forecast(regresion2, h=30)
      valpron_reg <- as.numeric(m8$mean)
      tendencia <- direction2(valpron_reg)
      titgraf <- paste(titgraf, " Tendencia ", tendencia)
      plot(valpron_reg, main=titgraf, ylab="Casos", xlab="dia proximo", type="l", col="blue")
    } else if (j == 3) { # ARIMA
      modelo_arima2 <- auto.arima(covid2.ts)
      m6 <- forecast(modelo_arima2, h=30)
      valpron_arima <- as.numeric(m6$mean)
      tendencia <- direction2(valpron_arima)
      titgraf <- paste(titgraf, " Tendencia ", tendencia)
      plot(valpron_arima, main=titgraf, ylab="Casos", xlab="dia proximo", type="l", col="blue")
    }
    else if (j == 1) { # Red Neuronal
      red_neuronal2 <- nnetar(covid2.ts)
      m7 <- forecast(red_neuronal2, h=30)
      valpron_redn <- as.numeric(m7$mean)
      tendencia <- direction2(valpron_redn)
      titgraf <- paste(titgraf, " Tendencia ", tendencia)
      plot(valpron_redn, main=titgraf, ylab="Casos", xlab="dia proximo", type="l", col="blue")
    }
    else if (j == 4) { # TBATS
      TBATS <- forecast(tbats(covid2.ts, biasadj=TRUE), h=30)
      valpron_tbats <- as.numeric(TBATS$mean)
      tendencia <- direction2(valpron_tbats)
      titgraf <- paste(titgraf, " Tendencia ", tendencia)
      plot(valpron_tbats, main=titgraf, ylab="Casos", xlab="dia proximo", type="l", col="blue")
    }
    
  })
  
  # Generamos grafica por estado segun modelo
  output$mpgPlot <- renderPlot({
    
    cad2 <- c("Red Neuronal","Regresion","ARIMA","TBATS", "Temporalidad")
    j <- as.integer(input$pron)
    cad <- cad2[j]
    
    # Elegimos Estado
    i <- as.integer(input$var)
    nomedo = names(datos2[i])
    
    # Convertimos a serie de datos iniciando en Abril de 2020
    k <- as.integer(input$tdat)
    cad3 <- c("Confirmados","Fallecidos")
    cadtipo <- cad3[k]
    
    # Elegimos Serie de tiempo de Confirmados o de Fallecidos
    if (k == 1) { # Confirmados
      datoscovid=ts(datos2[i], start = c(2020, 92), freq = 365)
      sumacasos = sum(datos2[i])
    }
    else {
      datoscovid=ts(datos[i], start = c(2020, 92), freq = 365)
      sumacasos = sum(datos[i])
    }
    
    totfallecidos = sum(datos[i])
    totconfirmados = sum(datos2[i])
    tasaletal <- (totfallecidos / totconfirmados)*100
    
    titgraf <- paste("Casos totales:", formatC(sumacasos, big.mark=","), "Tasa Letalidad:", FormatDecimal(tasaletal, 2))
    coloredo <- datos5[i]
    colorleyenda <- "black"
    if (coloredo=="Amarillo"){
      colorleyenda = "yellow3"
    }
    if (coloredo=="Rojo"){
      colorleyenda = "red"
    }
    if (coloredo=="Verde"){
      colorleyenda = "green"
    }
    if (coloredo=="Naranja"){
      colorleyenda = "orange"
    }
    if (i != 33) {
     titgraf <- paste("Casos totales:", formatC(sumacasos, big.mark=","), "Tasa Letalidad:", FormatDecimal(tasaletal, 2), "Semaforo Actual: ", coloredo)
    }
    covid2.ts=datoscovid
    
    # Dibujamos grafica segun modelo
    
    if (j == 2) { # Regresion
      regresion2 <- tslm(covid2.ts ~ trend + season)
      m8 <- forecast(regresion2, h=30)
      g <- autoplot(m8)+labs(title=titgraf,x="Tiempo",y=cadtipo,colour="#00a0dc")
      g + theme(
        plot.title = element_text(color=colorleyenda, size=14, face="bold.italic"),
        axis.title.x = element_text(color="blue", size=14, face="bold"),
        axis.title.y = element_text(color="#993333", size=14, face="bold")
      )
      
    } else if (j == 3) { # ARIMA
      modelo_arima2 <- auto.arima(covid2.ts)
      m6 <- forecast(modelo_arima2, h=30)
      g <- autoplot(m6)+labs(title=titgraf,x="Tiempo",y=cadtipo,colour="#00a0dc")
      g + theme(
        plot.title = element_text(color=colorleyenda, size=14, face="bold.italic"),
        axis.title.x = element_text(color="blue", size=14, face="bold"),
        axis.title.y = element_text(color="#993333", size=14, face="bold")
      )
    }
    else if (j == 1) { # Red Neuronal
      red_neuronal2 <- nnetar(covid2.ts)
      m7 <- forecast(red_neuronal2, h=30)
      g <- autoplot(m7)+labs(title=titgraf,x="Tiempo",y=cadtipo,colour="#00a0dc")
      g + theme(
        plot.title = element_text(color=colorleyenda, size=14, face="bold.italic"),
        axis.title.x = element_text(color="blue", size=14, face="bold"),
        axis.title.y = element_text(color="#993333", size=14, face="bold")
      )
    }
    else if (j == 4) { # TBATS
      TBATS <- forecast(tbats(covid2.ts, biasadj=TRUE), h=30)
      g <- autoplot(TBATS)+labs(title=titgraf,x="Tiempo",y=cadtipo,colour="#00a0dc")
      g + theme(
        plot.title = element_text(color=colorleyenda, size=14, face="bold.italic"),
        axis.title.x = element_text(color="blue", size=14, face="bold"),
        axis.title.y = element_text(color="#993333", size=14, face="bold")
      )
    }
    else if (j == 5) { # Temporalidad
      titgraf <- paste("Temporalidad ", cadtipo, " de: ", nomedo, "Casos totales:", formatC(sumacasos, big.mark=","))
      g <- ggseasonplot(covid2.ts, main = titgraf, xlab = "Fechas", ylab = "Cantidad")
      g + theme(
        plot.title = element_text(color=colorleyenda, size=14, face="bold.italic"),
        axis.title.x = element_text(color="blue", size=14, face="bold"),
        axis.title.y = element_text(color="#993333", size=14, face="bold")
      )
      
    }
  })
  
  # Generamos grafica por lugar segun modelo
  output$mpg2Plot <- renderPlot({
    
    cad2 <- c("Red Neuronal","Regresion","ARIMA","TBATS","Temporalidad")
    j <- as.integer(input$pron2)
    cad <- cad2[j]
    
    # Elegimos Lugar
    i <- as.integer(input$var2)
    nomlugar = names(datos6[i])
    
    # Convertimos a serie de datos iniciando en Abril de 2020
    k <- as.integer(input$tdat2)
    cad3 <- c("Confirmados","Fallecidos")
    cadtipo <- cad3[k]
    
    # Elegimos Serie de tiempo de Confirmados o de Fallecidos
    if (k == 1) { # Confirmados
      datoscovid=ts(datos6[i], start = c(2020, 92), freq = 365)
      sumacasos = sum(datos6[i])
    }
    else {
      datoscovid=ts(datos7[i], start = c(2020, 92), freq = 365)
      sumacasos = sum(datos7[i])
    }
    
    totfallecidos = sum(datos[i])
    totconfirmados = sum(datos2[i])
    tasaletal <- (totfallecidos / totconfirmados)*100
    covid2.ts=datoscovid
    
    coloredo <- datos8[i]
    colorleyenda <- "black"
    if (coloredo=="Amarillo"){
      colorleyenda = "yellow3"
    }
    if (coloredo=="Rojo"){
      colorleyenda = "red"
    }
    if (coloredo=="Verde"){
      colorleyenda = "green"
    }
    if (coloredo=="Naranja"){
      colorleyenda = "orange"
    }
    titgraf <- paste("Casos totales:", formatC(sumacasos, big.mark=","), "Tasa Letalidad:", FormatDecimal(tasaletal, 2), "Semaforo Actual: ", coloredo)
    # Dibujamos grafica segun modelo
    
    if (j == 2) { # Regresion
      regresion2 <- tslm(covid2.ts ~ trend + season)
      m8 <- forecast(regresion2, h=30)
      g <- autoplot(m8)+labs(title=titgraf,x="Tiempo",y=cadtipo,colour="#00a0dc")
      g + theme(
        plot.title = element_text(color=colorleyenda, size=14, face="bold.italic"),
        axis.title.x = element_text(color="blue", size=14, face="bold"),
        axis.title.y = element_text(color="#993333", size=14, face="bold")
      )
    } else if (j == 3) { # ARIMA
      modelo_arima2 <- auto.arima(covid2.ts)
      m6 <- forecast(modelo_arima2, h=30)
      g <- autoplot(m6)+labs(title=titgraf,x="Tiempo",y=cadtipo,colour="#00a0dc")
      g + theme(
        plot.title = element_text(color=colorleyenda, size=14, face="bold.italic"),
        axis.title.x = element_text(color="blue", size=14, face="bold"),
        axis.title.y = element_text(color="#993333", size=14, face="bold")
      )
    }
    else if (j == 1) { # Red Neuronal
      red_neuronal2 <- nnetar(covid2.ts)
      m7 <- forecast(red_neuronal2, h=30)
      g <- autoplot(m7)+labs(title=titgraf,x="Tiempo",y=cadtipo,colour="#00a0dc")
      g + theme(
        plot.title = element_text(color=colorleyenda, size=14, face="bold.italic"),
        axis.title.x = element_text(color="blue", size=14, face="bold"),
        axis.title.y = element_text(color="#993333", size=14, face="bold")
      )
    }
    else if (j == 4) { # TBATS
      TBATS <- forecast(tbats(covid2.ts, biasadj=TRUE), h=30)
      g <- autoplot(TBATS)+labs(title=titgraf,x="Tiempo",y=cadtipo,colour="#00a0dc")
      g + theme(
        plot.title = element_text(color=colorleyenda, size=14, face="bold.italic"),
        axis.title.x = element_text(color="blue", size=14, face="bold"),
        axis.title.y = element_text(color="#993333", size=14, face="bold")
      )
    }
    else if (j == 5) { # Temporalidad
      titgraf <- paste("Temporalidad ", cadtipo, " de: ", nomlugar, "Casos totales:", formatC(sumacasos, big.mark=","))
      g <- ggseasonplot(covid2.ts, main = titgraf, xlab = "Fechas", ylab = "Cantidad")
      g + theme(
        plot.title = element_text(color=colorleyenda, size=14, face="bold.italic"),
        axis.title.x = element_text(color="blue", size=14, face="bold"),
        axis.title.y = element_text(color="#993333", size=14, face="bold")
      )  
    }
  })
  
  
}

shinyApp(ui, server)