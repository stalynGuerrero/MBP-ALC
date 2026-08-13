#########################################################
# Libro MBP-ALC - Capítulo 7, Ejemplo aplicado (BRB_2024) #
# Total censal vs. total final (ya corregido por cobertura) #
# agregado a nivel nacional                                 #
# Autor: Stalyn Guerrero & Andrés Gutiérrez                #
#########################################################

rm(list = ls())
library(tidyverse)

pred_area <- readRDS("Data/rutinas/Output/Base_input.rds")

totales_nacionales <- pred_area %>%
  summarise(
    `N.º de unidades`               = n(),
    `N.º con cobertura completa`    = sum(Status == "Completa"),
    `Total censal`                  = sum(cont_pers, na.rm = TRUE),
    `Total final (media)`           = sum(pob_final_media),
    `Total final (mediana)`         = sum(pob_final_mediana)
  )

saveRDS(totales_nacionales, "Data/rutinas/Output/03_totales_nacionales.rds")
