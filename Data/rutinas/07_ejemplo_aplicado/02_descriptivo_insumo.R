#########################################################
# Libro MBP-ALC - Capítulo 7, Ejemplo aplicado (BRB_2024) #
# Tabla descriptiva de la base de entrada, antes del       #
# ajuste del modelo                                        #
# Autor: Stalyn Guerrero & Andrés Gutiérrez                #
#########################################################

rm(list = ls())
library(tidyverse)

ruta_base <- "Data/rutinas/Output/Base_input.rds"

pred_area <- readRDS(ruta_base)

resumen_descriptivo <- pred_area %>%
  summarise(
    `N.º de unidades censales`                = n(),
    `N.º de unidades territoriales agregadas` = n_distinct(parish_value),
    `Cobertura censal completa (%)`           = 100 * mean(per_com == 100, na.rm = TRUE),
    `Mediana conteo censal`                   = median(cont_pers, na.rm = TRUE),
    `Mediana estructuras/viviendas`           = median(hh_2021_imp, na.rm = TRUE),
    `Densidad media (personas/estructura)`    = mean(densidad_pop, na.rm = TRUE)
  ) %>%
  pivot_longer(
    cols = everything(),
    names_to = "Descriptivo",
    values_to = "Resultado"
  )


saveRDS(resumen_descriptivo, file.path("Data/rutinas/Output/01_resumen_descriptivo.rds"))
