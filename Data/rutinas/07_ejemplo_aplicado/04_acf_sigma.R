#########################################################
# Libro MBP-ALC - Capítulo 7, Ejemplo aplicado (BRB_2024) #
# Autocorrelación posterior de sigma y sigmaU (bayesplot)  #
# Autor: Stalyn Guerrero & Andrés Gutiérrez                #
#########################################################

rm(list = ls())
library(tidyverse)
library(bayesplot)

ruta_base <- "Data/ejemplos_reales/BRB_2024"

draws_core <- readRDS(file.path(ruta_base, "06_posterior_draws_core.rds"))

plot_acf_sigma <- mcmc_acf(draws_core, pars = c("sigma", "sigmaU"), lags = 20)

ggsave(
  filename = "images/cap_07/04_acf_sigma.png",
  plot     = plot_acf_sigma,
  width    = 20, height = 14, units = "cm"
)
