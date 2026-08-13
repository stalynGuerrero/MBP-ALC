#########################################################
# Libro MBP-ALC - Capítulo 7, LOO/WAIC con datos reales    #
# Verificación predictiva posterior (PPC) sobre el mismo    #
# reajuste usado para calcular LOO/WAIC (log_lik habilitado)#
# — mismo código que 2024BRB/Rcodes/03_model_bayes_poisson.R #
# líneas 236-252, aplicado a esta corrida en particular.    #
# Independiente de 02_ajustar_modelo_loglik.R: reajusta el  #
# modelo de nuevo (no se conservó el stanfit completo) solo #
# para extraer las muestras de `densidad`, sin tocar los     #
# resultados de LOO/WAIC ya guardados en Output/.            #
# Autor: Stalyn Guerrero & Andrés Gutiérrez                #
#########################################################

rm(list = ls())
library(rstan)
library(bayesplot)
library(patchwork)
library(tidyverse)

options(mc.cores = parallel::detectCores())
rstan::rstan_options(auto_write = TRUE)

list_par <- readRDS("Data/rutinas/07_loo_waic/Output/list_par.rds")

t0 <- Sys.time()
cat("Inicio del ajuste:", format(t0), "\n")

stan_model <- rstan::stan(
  file    = "Data/rutinas/07_loo_waic/Modelo_worldpop_V03_loglik.stan",
  data    = list_par,
  iter    = 2000,
  warmup  = 1500,
  chains  = 4,
  control = list(max_treedepth = 15)
)

t1 <- Sys.time()
cat("Fin del ajuste:", format(t1), " (", round(difftime(t1, t0, units = "mins"), 1), "min )\n")

################################################################################
## Verificación predictiva posterior (mismo procedimiento que el Código
## \@ref(exr:cod-ppc-densidad) / 2024BRB/Rcodes/03_model_bayes_poisson.R)
################################################################################
posterior_samples <- rstan::extract(stan_model, pars = "densidad")
densidad_pred <- posterior_samples$densidad

rowsrandom <- sample(nrow(densidad_pred), 500)
y_pred2    <- densidad_pred[rowsrandom, ]

ppc_dens <- bayesplot::ppc_dens_overlay(
  y    = as.numeric(list_par$Y_obs / list_par$V_obs),
  yrep = y_pred2
)

ppc_pers <- bayesplot::ppc_dens_overlay(
  y    = as.numeric(list_par$Y_obs),
  yrep = t(t(y_pred2) * list_par$V_obs)
)

p1 <- ppc_dens | ppc_pers

ggsave(
  filename = "images/cap_07/05_ppc_loglik.png",
  plot     = p1,
  width    = 20, height = 14, units = "cm"
)

cat("Listo. Figura en images/cap_07/05_ppc_loglik.png\n")
