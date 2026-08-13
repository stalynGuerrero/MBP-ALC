#########################################################
# Libro MBP-ALC - Capítulo 7, Ejemplo aplicado (BRB_2024) #
# Densidad (kernel) de la densidad poblacional de insumo,  #
# delta_i, antes del ajuste del modelo                      #
# Autor: Stalyn Guerrero & Andrés Gutiérrez                #
#########################################################

rm(list = ls())
library(tidyverse)
library(patchwork)
pred_area <- readRDS(
  file.path("Data/rutinas/Output/Base_input.rds")
) %>%
  filter(
    Status != "Nula",
    !is.na(cont_pers),
    !is.na(hh_2021_imp),
    !is.na(densidad_pop),
    hh_2021_imp > 0
  )

# -------------------------------------------------------------------------
# 1. Distribución de la densidad poblacional
# -------------------------------------------------------------------------

plot_densidad_insumo <- ggplot(
  pred_area,
  aes(x = densidad_pop)
) +
  geom_density(
    fill = "steelblue", alpha = 0.4,
    color = "steelblue4",
    linewidth = 0.8
  ) +
  geom_rug(
    sides = "b",
    alpha = 0.15,
    linewidth = 0.3
  ) +
  labs(
    x = "Personas por estructura",
    y = "Densidad",
    title = "Distribución de la densidad poblacional"
  ) +
  theme_bw(base_size = 11) +
  theme(
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    plot.title = element_text(face = "bold"),
    axis.title = element_text(size = 11)
  )


# -------------------------------------------------------------------------
# 2. Relación entre personas y estructuras/viviendas
# -------------------------------------------------------------------------

plot_personas_viviendas <- ggplot(
  pred_area,
  aes(
    x = hh_2021_imp,
    y = cont_pers
  )
) +
  geom_point(
    alpha = 0.35,
    size = 1.8
  ) +
  geom_smooth(
    method = "lm",
    formula = y ~ x,
    se = FALSE,
    linewidth = 0.8
  ) +
  labs(
    x = "Estructuras/viviendas",
    y = "Personas censadas",
    title = "Relación entre personas y estructuras/viviendas"
  ) +
  theme_bw(base_size = 11) +
  theme(
    panel.grid.minor = element_blank(),
    panel.grid.major = element_blank(),
    plot.title = element_text(face = "bold"),
    axis.title = element_text(size = 11)
  )


plot_densidad <- plot_personas_viviendas/plot_densidad_insumo

ggsave(
  filename = "images/cap_07/00_densidad_insumo.png",
  plot     = plot_densidad,
  width    = 25, height = 18, units = "cm"
)
