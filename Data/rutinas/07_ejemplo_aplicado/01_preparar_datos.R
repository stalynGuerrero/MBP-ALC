#########################################################
# Libro MBP-ALC - Capítulo 7, Ejemplo aplicado (BRB_2024) #
# Preparación de la predicción por unidad de área:        #
# estado de cobertura (Completa/Nula/Parcial) y estimación #
# final por segmento, siguiendo la regla de la Sección     #
# "Estimaciones a nivel de segmento censal" (Cap. 7)        #
# Autor: Stalyn Guerrero & Andrés Gutiérrez                #
#########################################################

rm(list = ls())
library(tidyverse)

ruta_base <- "Data/ejemplos_reales/BRB_2024"

pred_area <- readRDS(file.path(ruta_base, "03_prediccion_poblation_bayes.rds")) %>%
  mutate(
    Status = case_when(
      per_com == 100   ~ "Completa",
      is.na(cont_pers) ~ "Nula",
      TRUE             ~ "Parcial"
    ),
    pob_final_media = case_when(
      Status == "Completa" ~ cont_pers,
      Status == "Nula"     ~ estimacion_mean,
      Status == "Parcial"  ~ pmax(cont_pers, estimacion_mean)
    ),
    pob_final_mediana = case_when(
      Status == "Completa" ~ cont_pers,
      Status == "Nula"     ~ estimacion_median,
      Status == "Parcial"  ~ pmax(cont_pers, estimacion_median)
    )
  )

saveRDS(pred_area, file.path("Data/rutinas/Output/Base_input.rds"))
