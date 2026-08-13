#########################################################
# Libro MBP-ALC - Capítulo 7, Ejemplo aplicado (BRB_2024) #
# Agregación de la estimación final a la unidad territorial #
# de nivel superior, bajo códigos anónimos ("Unidad N")     #
# Autor: Stalyn Guerrero & Andrés Gutiérrez                #
#########################################################

rm(list = ls())
library(tidyverse)

pred_area <- readRDS("Data/rutinas/Output/Base_input.rds")

estimaciones_agregadas <- pred_area %>%
  group_by(parish_value) %>%
  summarise(
    `N.º de unidades`     = n(),
    `Total censal`        = sum(cont_pers, na.rm = TRUE),
    `Total final (media)` = sum(pob_final_media),
    `Densidad media`      = mean(densidad_pop, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(desc(`Total final (media)`)) %>%
  mutate(`Unidad territorial` = paste("Unidad", row_number()), .before = 1) %>%
  select(-parish_value)

saveRDS(estimaciones_agregadas, "Data/rutinas/Output/04_agregacion_territorial.rds")
