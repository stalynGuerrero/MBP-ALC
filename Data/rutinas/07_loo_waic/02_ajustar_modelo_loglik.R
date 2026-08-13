#########################################################
# Libro MBP-ALC - Capítulo 7, LOO/WAIC con datos reales    #
# Ajusta el modelo Poisson-lognormal de Barbados (BRB_2024)#
# con el programa Stan modificado (log_lik agregado) y     #
# calcula los criterios LOO-CV y WAIC del Código            #
# \@ref(exr:cod-loo-waic). No modifica ni el .stan ni los   #
# .rds originales del proyecto: todas las salidas se        #
# guardan en Data/rutinas/07_loo_waic/Output/.               #
#                                                            #
# Pensado para ejecutarse en segundo plano (tarda varios     #
# minutos): Rscript Data/rutinas/07_loo_waic/02_ajustar_modelo_loglik.R
# Autor: Stalyn Guerrero & Andrés Gutiérrez                #
#########################################################

rm(list = ls())
library(rstan)
library(loo)
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
## Resumen posterior completo (equivalente a 05_stan_summary.rds)
################################################################################
stan_summary <- summary(stan_model)$summary
saveRDS(stan_summary, "Data/rutinas/07_loo_waic/Output/05_stan_summary_loglik.rds")

draws_core <- rstan::extract(
  stan_model,
  pars = c("beta", "gamma", "sigma", "sigmaU", "lp__"),
  permuted = FALSE
)
saveRDS(draws_core, "Data/rutinas/07_loo_waic/Output/06_posterior_draws_core_loglik.rds")

################################################################################
## LOO-CV y WAIC (Código \@ref(exr:cod-loo-waic))
################################################################################
log_lik_mat <- loo::extract_log_lik(stan_model, parameter_name = "log_lik")

waic_result <- loo::waic(log_lik_mat)
loo_result  <- loo::loo(log_lik_mat)

saveRDS(waic_result, "Data/rutinas/07_loo_waic/Output/waic_result.rds")
saveRDS(loo_result,  "Data/rutinas/07_loo_waic/Output/loo_result.rds")

print(waic_result)
print(loo_result)

cat("Listo. Resultados en Data/rutinas/07_loo_waic/Output/\n")
