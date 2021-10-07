# demo DAOS  --------------------------------------------------------------


# Load the following libraries.

library(tidymodels) #install.packages("tidymodels")
library(modeltime)  #install.packages("modeltime")
library(timetk)     #install.packages("timetk")
library(lubridate)  #install.packages("lubridate")
library(tidyverse)  #install.packages("tidyverse")
library(lubridate)  #install.packages("lubridate")


# get your data


data <- read.csv("C:/Users/David/OneDrive/Documentos/DAOS curses/Datalab SDC4/demo 1/liquibase-covid/code daos/confirmados.csv", header = TRUE)

data <- data %>% 
  mutate(fecha = as.Date(fecha))

# ts.agu <- ts(data[3], 
#              start = c(2020, as.numeric(format(data$fecha[1], "%j"))),
#              frequency = 365)

ts.agu.tbl <- data %>%
  select(1, 3) %>%  # select(fecha, AGUASCALIENTES) 
  set_names(c("date", "confirmados"))

# head(ts.agu.tbl)

# visualize the dataset

# ts.agu.tbl %>% 
#   plot_time_series(date, confirmados, .interactive = F)

# Train / Test
# Split your time series into training and testing sets

splits <- ts.agu.tbl %>%
  time_series_split(assess = "3 months", cumulative = TRUE)


# splits %>%
#   tk_time_series_cv_plan() %>%
#   plot_time_series_cv_plan(date, confirmados, .interactive = FALSE)

# Modeling

## Auto ARIMA

model_fit_arima <- arima_reg() %>%
  set_engine("auto_arima") %>%
  fit(confirmados ~ date, training(splits))

# model_fit_arima

## prophet

# Prophet implementa lo que ellos denominan un modelo de pron?stico 
# de series de tiempo aditivo , y la implementaci?n admite 
# tendencias, estacionalidad y d?as festivos.

model_fit_prophet <- prophet_reg(seasonality_daily = TRUE) %>%
  set_engine("prophet") %>%
  fit(confirmados ~ date, training(splits))

# model_fit_prophet

# Machine Learning Models

recipe_spec <- recipe(confirmados ~ date, training(splits)) %>%
  step_timeseries_signature(date) %>%
  step_rm(contains("am.pm"), contains("hour"), contains("minute"),
          contains("second"), contains("xts")) %>%
  step_fourier(date, period = 365, K = 5) %>%
  step_dummy(all_nominal())

# recipe_spec %>% prep() %>% juice()

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

# workflow_fit_prophet_boost

# Neural Network Time Series Forecasts

model_fit_nnetar <- nnetar_reg() %>%
  set_engine("nnetar") %>% 
  fit(confirmados ~ date, training(splits))

# model_fit_nnetar

# Modeltime Table

model_table <- modeltime_table(
  model_fit_arima, 
  model_fit_prophet,
  workflow_fit_glmnet,
  workflow_fit_rf,
  workflow_fit_prophet_boost,
  model_fit_nnetar
) 

# model_table

# calibration

# La calibraci?n del modelo se utiliza para cuantificar el error 
# y estimar los intervalos de confianza. Realizaremos la calibraci?n 
# del modelo en los datos fuera de la muestra (tambi?n conocido 
# como el Conjunto de prueba) con la funci?n modeltime_calibrate ().
# ".calibration_data". This includes the actual confirmadoss, fitted confirmadoss, and residuals for the testing set.

calibration_table <- model_table %>%
  modeltime_calibrate(testing(splits))

# calibration_table


# Forecast (testing set)

# calibration_table %>%
#   modeltime_forecast(actual_data = ts.agu.tbl) %>%
#   plot_modeltime_forecast(.interactive = T)

# Accuracy (Testing Set)

calibration_table %>%
  modeltime_accuracy() %>%
  table_modeltime_accuracy(.interactive = F)


# calibration_table %>%
#   modeltime_accuracy() %>%
#   rowwise() %>% 
#   mutate(mean = mean(c(mae,mape, mase, smape, rmse, rsq), na.rm=TRUE)) %>% 
#   arrange(mean) %>% 
#   mutate(n_id = as.numeric(as.character(mae)))
#   filter(.model_id)
#   table_modeltime_accuracy(.interactive = F) 


table1 <- calibration_table %>%
  modeltime_accuracy()
table1$mae:table1$rsq
# Reacondicionamiento y pron?stico de avance

calibration_table %>%
  # Remove ARIMA model with low accuracy
  # filter(.model_id != 4) %>%
  
  # Refit and Forecast Forward
  modeltime_refit(ts.agu.tbl) %>%
  modeltime_forecast(h = "1 month", actual_data = ts.agu.tbl) %>%
  plot_modeltime_forecast(.interactive = T)
