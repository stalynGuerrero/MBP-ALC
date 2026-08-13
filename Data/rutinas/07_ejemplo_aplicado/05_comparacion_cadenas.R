#########################################################
# Libro MBP-ALC - Capítulo 7, Ejemplo aplicado
# Comparación de diagnósticos de convergencia
#########################################################
rm(list = ls())

library(tidyverse)

ruta_base <- "Data/ejemplos_reales/BRB_2024"
ruta_2cad <- "Data/ejemplos_reales/JAM_2025"

# -------------------------------------------------------------------------
# Resultados de los ajustes
# -------------------------------------------------------------------------

stan_summary <- readRDS(
  file.path(ruta_base, "05_stan_summary.rds")
)

draws_core <- readRDS(
  file.path(ruta_base, "06_posterior_draws_core.rds")
)

ss_2cad <- readRDS(
  file.path(ruta_2cad, "05_stan_summary.rds")
)

dc_2cad <- readRDS(
  file.path(ruta_2cad, "06_posterior_draws_core.rds")
)

# -------------------------------------------------------------------------
# Función para resumir diagnóstico
# -------------------------------------------------------------------------

resumir_diagnostico <- function(summary, draws, ajuste) {
  
  tibble(
    Ajuste = ajuste,
    `N.º de cadenas` =
      dim(draws)[2],
    `N.º de parámetros/cantidades` =
      nrow(summary),
    `N.º con Rhat > 1,01` =
      sum(summary[, "Rhat"] > 1.01, na.rm = TRUE),
    `Proporción con Rhat > 1,01 (%)` =
      100 * mean(summary[, "Rhat"] > 1.01, na.rm = TRUE),
    `Rhat máximo` =
      max(summary[, "Rhat"], na.rm = TRUE),
    `ESS mediano` =
      median(summary[, "n_eff"], na.rm = TRUE)
  )
}

# -------------------------------------------------------------------------
# Tabla comparativa
# -------------------------------------------------------------------------

comparacion_cadenas <- bind_rows(
  resumir_diagnostico(
    stan_summary,
    draws_core,
    "Este ajuste (4 cadenas)"
  ),
  resumir_diagnostico(
    ss_2cad,
    dc_2cad,
    "Ajuste con 2 cadenas"
  )
)

# -------------------------------------------------------------------------
# Tabla larga
# -------------------------------------------------------------------------
tabla_larga_cadenas <- comparacion_cadenas %>%
  pivot_longer(
    cols = -Ajuste,
    names_to = "Indicador",
    values_to = "Valor"
  ) %>%
  pivot_wider(
    names_from = Ajuste,
    values_from = Valor
  ) %>%
  mutate(
    `Este ajuste (4 cadenas)` = case_when(
      Indicador == "Proporción con Rhat > 1,01 (%)" ~
        sprintf("%.1f", `Este ajuste (4 cadenas)`),
      
      Indicador == "Rhat máximo" ~
        sprintf("%.3f", `Este ajuste (4 cadenas)`),
      
      Indicador == "ESS mediano" ~
        format(
          round(`Este ajuste (4 cadenas)`, 1),
          big.mark = ".",
          decimal.mark = ","
        ),
      
      TRUE ~
        format(
          round(`Este ajuste (4 cadenas)`),
          big.mark = ".",
          decimal.mark = ","
        )
    ),
    
    `Ajuste con 2 cadenas` = case_when(
      Indicador == "Proporción con Rhat > 1,01 (%)" ~
        sprintf("%.1f", `Ajuste con 2 cadenas`),
      
      Indicador == "Rhat máximo" ~
        format(
          round(`Ajuste con 2 cadenas`),
          big.mark = ".",
          decimal.mark = ","
        ),
      
      Indicador == "ESS mediano" ~
        sprintf("%.2f", `Ajuste con 2 cadenas`),
      
      TRUE ~
        format(
          round(`Ajuste con 2 cadenas`),
          big.mark = ".",
          decimal.mark = ","
        )
    )
  )

tabla_larga_cadenas <- tabla_larga_cadenas %>%
  rename(
    `4 cadenas` = `Este ajuste (4 cadenas)`,
    `2 cadenas` = `Ajuste con 2 cadenas`
  )

saveRDS(tabla_larga_cadenas,
        file.path("Data/rutinas/Output/02_resumen_cadena.rds"))
