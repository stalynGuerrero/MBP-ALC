#########################################################
# Libro MBP-ALC - Capítulo 7, LOO/WAIC con datos reales    #
# Arma la tabla resumen y el resumen de diagnósticos        #
# Pareto-k para mostrar en 07_1_Ejemplo_Aplicado.Rmd a       #
# partir de los resultados ya calculados por                #
# 02_ajustar_modelo_loglik.R (no recalcula nada, solo       #
# da formato de tabla).                                     #
# Autor: Stalyn Guerrero & Andrés Gutiérrez                #
#########################################################

rm(list = ls())
library(tidyverse)
library(loo)

waic_result <- readRDS("Data/rutinas/07_loo_waic/Output/waic_result.rds")
loo_result  <- readRDS("Data/rutinas/07_loo_waic/Output/loo_result.rds")

################################################################################
## Tabla comparativa WAIC / LOO-CV
################################################################################
tabla_loo_waic <- tibble(
  Criterio  = c("WAIC", "LOO-CV"),
  elpd      = c(waic_result$estimates["elpd_waic", "Estimate"],
                loo_result$estimates["elpd_loo", "Estimate"]),
  elpd_se   = c(waic_result$estimates["elpd_waic", "SE"],
                loo_result$estimates["elpd_loo", "SE"]),
  p_efectivo    = c(waic_result$estimates["p_waic", "Estimate"],
                     loo_result$estimates["p_loo", "Estimate"]),
  p_efectivo_se = c(waic_result$estimates["p_waic", "SE"],
                     loo_result$estimates["p_loo", "SE"]),
  Criterio_valor    = c(waic_result$estimates["waic", "Estimate"],
                         loo_result$estimates["looic", "Estimate"]),
  Criterio_valor_se = c(waic_result$estimates["waic", "SE"],
                         loo_result$estimates["looic", "SE"])
)
names(tabla_loo_waic) <- c("Criterio", "elpd", "SE(elpd)", "p_efectivo",
                            "SE(p_efectivo)", "Criterio (waic/looic)", "SE")

################################################################################
## Resumen de diagnósticos Pareto-k (PSIS-LOO)
################################################################################
pareto_k  <- loo::pareto_k_values(loo_result)
n_obs     <- length(pareto_k)

pareto_k_tabla <- tibble(
  Categoria = c("Bueno (k <= 0,7)", "Malo (0,7 < k <= 1)", "Muy malo (k > 1)"),
  `N.º de observaciones` = c(sum(pareto_k <= 0.7),
                              sum(pareto_k > 0.7 & pareto_k <= 1),
                              sum(pareto_k > 1)),
  `Porcentaje` = round(100 * c(mean(pareto_k <= 0.7),
                                mean(pareto_k > 0.7 & pareto_k <= 1),
                                mean(pareto_k > 1)), 1)
)

pct_pwaic_alto <- round(100 * mean(waic_result$pointwise[, "p_waic"] > 0.4), 1)

resultado_loo_waic <- list(
  tabla          = tabla_loo_waic,
  pareto_k_tabla = pareto_k_tabla,
  n_obs          = n_obs,
  pct_pwaic_alto = pct_pwaic_alto
)

saveRDS(resultado_loo_waic, "Data/rutinas/07_loo_waic/Output/resultado_loo_waic.rds")
