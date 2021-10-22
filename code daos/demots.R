
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



# demo DAOS  --------------------------------------------------------------


# Load the following libraries.

library(tidymodels) #install.packages("tidymodels")
library(modeltime)  #install.packages("modeltime")
library(timetk)     #install.packages("timetk")
library(lubridate)  #install.packages("lubridate")
library(tidyverse)  #install.packages("tidyverse")
library(lubridate)  #install.packages("lubridate")


# get your data


#data <- read.csv("C:/Users/David/OneDrive/Documentos/DAOS curses/Datalab SDC4/demo 1/liquibase-covid/code daos/confirmados.csv", header = TRUE)

# data <- data %>% 
#   mutate(fecha = as.Date(fecha))

ts.agu <- ts(data[1], 
             start = c(2020, as.numeric(format(data$fecha[1], "%j"))),
             frequency = 365)

ts.agu.tbl <- data %>%
  select(33, 1) %>%  # select(fecha, AGUASCALIENTES) 
  set_names(c("date", "confirmados"))

head(ts.agu.tbl)

# visualize the dataset

ts.agu.tbl %>% 
  plot_time_series(date, confirmados, .interactive = F)

# Train / Test
# Split your time series into training and testing sets

splits <- ts.agu.tbl %>%
  time_series_split(assess = "3 months", cumulative = TRUE)


splits %>%
  tk_time_series_cv_plan() %>%
  plot_time_series_cv_plan(date, confirmados, .interactive = FALSE)

# Modeling

## Auto ARIMA

model_fit_arima <- arima_reg() %>%
  set_engine("auto_arima") %>%
  fit(confirmados ~ date, training(splits))

model_fit_arima

## prophet

# Prophet implementa lo que ellos denominan un modelo de pron?stico 
# de series de tiempo aditivo , y la implementaci?n admite 
# tendencias, estacionalidad y d?as festivos.

model_fit_prophet <- prophet_reg(seasonality_daily = TRUE) %>%
  set_engine("prophet") %>%
  fit(confirmados ~ date, training(splits))

model_fit_prophet

# Machine Learning Models

recipe_spec <- recipe(confirmados ~ date, training(splits)) %>%
  step_timeseries_signature(date) %>%
  step_rm(contains("am.pm"), contains("hour"), contains("minute"),
          contains("second"), contains("xts")) %>%
  step_fourier(date, period = 365, K = 5) %>%
  step_dummy(all_nominal())

recipe_spec %>% prep() %>% juice()

## Elastic red (modelo de regresion regularizado)

model_spec_glmnet <- linear_reg(penalty = 0.01, mixture = 0.5) %>%
  set_engine("glmnet")

workflow_fit_glmnet <- workflow() %>%
  add_model(model_spec_glmnet) %>%
  add_recipe(recipe_spec %>% step_rm(date)) %>%
  fit(training(splits))

## Ramdom Forest

model_spec_rf <- rand_forest(trees = 500, min_n = 50) %>%
  set_engine("randomForest")

workflow_fit_rf <- workflow() %>%
  add_model(model_spec_rf) %>%
  add_recipe(recipe_spec %>% step_rm(date)) %>%
  fit(training(splits))

# Hybrid ML Models

## Prophet Boost

model_spec_prophet_boost <- prophet_boost(seasonality_yearly = TRUE) %>%
  set_engine("prophet_xgboost") 

workflow_fit_prophet_boost <- workflow() %>%
  add_model(model_spec_prophet_boost) %>%
  add_recipe(recipe_spec) %>%
  fit(training(splits))

workflow_fit_prophet_boost

# Neural Network Time Series Forecasts

model_fit_nnetar <- nnetar_reg() %>%
  set_engine("nnetar") %>% 
  fit(confirmados ~ date, training(splits))

model_fit_nnetar

# Modeltime Table

model_table <- modeltime_table(
  model_fit_arima, 
  model_fit_prophet,
  workflow_fit_glmnet,
  workflow_fit_rf,
  workflow_fit_prophet_boost,
  model_fit_nnetar
) 

model_table

# calibration

# La calibraci?n del modelo se utiliza para cuantificar el error 
# y estimar los intervalos de confianza. Realizaremos la calibraci?n 
# del modelo en los datos fuera de la muestra (tambi?n conocido 
# como el Conjunto de prueba) con la funci?n modeltime_calibrate ().
# ".calibration_data". This includes the actual confirmadoss, fitted confirmadoss, and residuals for the testing set.

calibration_table <- model_table %>%
  modeltime_calibrate(testing(splits))

calibration_table


# Forecast (testing set)

calibration_table %>%
  modeltime_forecast(actual_data = ts.agu.tbl) %>%
  plot_modeltime_forecast(.interactive = T)

# Accuracy (Testing Set)

calibration_table %>%
  modeltime_accuracy() %>%
  table_modeltime_accuracy(.interactive = F)

# Reacondicionamiento y pron?stico de avance

calibration_table %>%
  # Remove ARIMA model with low accuracy
  # filter(.model_id != 4) %>%
  
  # Refit and Forecast Forward
  modeltime_refit(ts.agu.tbl) %>%
  modeltime_forecast(h = "1 month", actual_data = ts.agu.tbl) %>%
  plot_modeltime_forecast(.interactive = T)

calibration_table %>% 
  modeltime_residuals() %>% 
  plot_modeltime_residuals()

calibration_table %>% 
  modeltime_residuals() %>% 
  plot_acf_diagnostics()

calibration_table %>% 
  group_by(.model_id) %>% 
  plot_seasonal_diagnostics()

calibration_table %>%
  modeltime_forecast(actual_data = ts.agu.tbl) %>% 

calibration_table %>% 
  conf_mat(truth = ts.agu.tbl)

calibration_table2 <- model_table %>%
  modeltime_calibrate(testing(splits), id = TRUE)
modeltime::modeltime_calibrate(model_table, testing(splits), id = '.model_id')
modeltime_accuracy(calibration_table)

model_table %>%
  modeltime_calibrate(testing(splits)) %>% 
  modeltime_accuracy( metric_set = metric_set(accuracy(quiet = F)))


ts.agu.tbl %>% 
  plot_acf_diagnostics(date, confirmados,               # ACF & PACF
                       .lags = "50 days",          # 7-Days of hourly lags
                       .interactive = FALSE)

ts.agu.tbl %>% 
  plot_acf_diagnostics(date, confirmados,               # ACF & PACF
                       #.lags = "30 days",          # 7-Days of hourly lags
                       .interactive = FALSE)


ts.agu.tbl %>% 
  plot_seasonal_diagnostics(date, confirmados)


  