#########################################################
# Libro MBP-ALC - Capítulo 8, Diagnóstico y Validación
# Trace plot de sigma, sigmaU, beta[1] y beta[2] (bayesplot)
# sobre el ajuste real de Barbados (BRB_2024)
# Autor: Stalyn Guerrero & Andrés Gutiérrez
#########################################################

rm(list = ls())
library(tidyverse)
library(bayesplot)

ruta_base <- "Data/ejemplos_reales/BRB_2024"

draws_core <- readRDS(file.path(ruta_base, "06_posterior_draws_core.rds"))

plot_trace_hmc <- mcmc_trace(
  draws_core,
  pars = c("sigma", "sigmaU", "beta[1]", "beta[2]")
)

ggsave(
  filename = "images/cap_08/01_trace_hmc.png",
  plot     = plot_trace_hmc,
  width    = 20, height = 14, units = "cm"
)
