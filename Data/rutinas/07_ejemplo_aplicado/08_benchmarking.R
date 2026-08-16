#########################################################
# Libro MBP-ALC - Capítulo 9, Calibración y Benchmarking
# Continuación del ejemplo aplicado del Capítulo 7: los cuatro
# métodos del capítulo (directo contra referencia externa por
# unidad, proporcional, ponderado por incertidumbre y aditivo
# por muestra) sobre las mismas unidades anónimas ("Unidad N")
# de 04_agregacion_territorial.rds
# Autor: Stalyn Guerrero & Andrés Gutiérrez
#########################################################

rm(list = ls())
library(tidyverse)

# -------------------------------------------------------------------------
# 1. Base del ejemplo aplicado del Capítulo 7 (misma fuente que
#    07_agregacion_territorial.R) y resumen posterior de Y_tot
# -------------------------------------------------------------------------
# `pob_final_media` ya incorpora la corrección por estado de cobertura
# (regla de dominancia, Código cod-regla-cobertura). La varianza posterior
# por segmento se aproxima por la de `Y_tot` en 05_stan_summary.rds, y
# como cero para los segmentos con cobertura censal completa, cuyo
# conteo censal es exacto y no aporta incertidumbre.

pred_area    <- readRDS("Data/rutinas/Output/Base_input.rds")
stan_summary <- readRDS("Data/rutinas/Output/05_stan_summary.rds")

y_tot_rows      <- grep("^Y_tot\\[", rownames(stan_summary), value = TRUE)
pred_area$N_var <- ifelse(
  pred_area$Status == "Completa", 0, stan_summary[y_tot_rows, "sd"]^2
)

# -------------------------------------------------------------------------
# 2. Agregación anónima por unidad territorial, con los mismos códigos
#    "Unidad N" y el mismo orden (descendente por población) que
#    04_agregacion_territorial.rds
# -------------------------------------------------------------------------

unidades <- pred_area %>%
  group_by(parish_value) %>%
  summarise(N_hat = sum(pob_final_media), w = sum(N_var), .groups = "drop") %>%
  arrange(desc(N_hat)) %>%
  mutate(`Unidad territorial` = paste("Unidad", row_number()), .before = 1)

# Mapa segmento -> unidad territorial, necesario más abajo (Sección 8)
# para descender la calibración desde la unidad hasta el segmento censal
mapa_unidad <- unidades %>% select(parish_value, `Unidad territorial`)

unidades <- unidades %>% select(-parish_value)

# Verificación de continuidad con el Capítulo 7: N_hat debe coincidir
# exactamente con "Total final (media)" de 04_agregacion_territorial.rds
agregacion_cap7 <- readRDS("Data/rutinas/Output/04_agregacion_territorial.rds")
stopifnot(isTRUE(all.equal(
  unidades$N_hat,
  agregacion_cap7$`Total final (media)`[match(unidades$`Unidad territorial`, agregacion_cap7$`Unidad territorial`)]
)))

# -------------------------------------------------------------------------
# 3. Referencia externa dada por unidad (N*_l)
# -------------------------------------------------------------------------
# Se dispone de una referencia externa propia para cada una de las 11
# unidades -- por ejemplo, una proyección demográfica calculada
# independientemente al mismo nivel de agregación.

referencia_externa <- tibble(
  `Unidad territorial` = paste("Unidad", 1:11),
  N_ext = c(
    80636, 59436, 31589, 29764, 25554,
    17418, 13732, 12187, 11217, 10352, 5719
  )
)

unidades <- unidades %>%
  left_join(referencia_externa, by = "Unidad territorial")

N_hat_mas <- sum(unidades$N_hat)
N_star    <- sum(unidades$N_ext)

cat("Total estimado por el modelo (N_hat_+):      ", round(N_hat_mas, 1), "\n")
cat("Total implícito en la referencia externa (N*):", N_star, "\n\n")

# -------------------------------------------------------------------------
# 4. Calibración directa contra la referencia externa por unidad
# -------------------------------------------------------------------------
# Sin pesos ni factor común: cada unidad se compara únicamente con su
# propia referencia.

unidades <- unidades %>%
  mutate(eta_directo = (N_ext - N_hat) / N_hat)

# -------------------------------------------------------------------------
# 5. Benchmarking proporcional, sobre el mismo N* agregado
# -------------------------------------------------------------------------
# Contraste: si solo se conociera el total agregado N* -- sin la
# referencia por unidad -- el benchmarking proporcional distribuiría la
# discrepancia aplicando el mismo factor phi a las 11 unidades.

benchmarking_proporcional <- function(N_hat, N_control) {
  phi <- N_control / sum(N_hat)
  N_hat * phi
}

unidades <- unidades %>%
  mutate(
    N_bench_prop = benchmarking_proporcional(N_hat, N_star),
    eta_prop     = N_star / N_hat_mas - 1
  )

# -------------------------------------------------------------------------
# 6. Benchmarking ponderado por incertidumbre, sobre el mismo N* agregado
# -------------------------------------------------------------------------
# También supone que solo se conoce el total agregado N*, pero lo
# distribuye con pesos proporcionales a la varianza posterior de cada
# unidad, en vez de aplicar el mismo factor a todas.

benchmarking_ponderado <- function(N_hat, N_control, pesos) {
  delta <- N_control - sum(N_hat)
  N_hat + pesos * (delta / sum(pesos))
}

unidades <- unidades %>%
  mutate(
    N_bench_pond = benchmarking_ponderado(N_hat, N_star, w),
    eta_pond     = (N_bench_pond - N_hat) / N_hat
  )

comparacion <- unidades %>%
  arrange(desc(eta_directo))

print(comparacion, n = Inf)

cat("\nSuma N_ext (referencia externa):     ", sum(comparacion$N_ext), "\n")
cat("Suma N_bench_prop (proporcional):    ", sum(comparacion$N_bench_prop), "\n")
cat("Suma N_bench_pond (ponderado):       ", sum(comparacion$N_bench_pond), "\n")
cat("Rango eta_directo:                   ",
    round(min(comparacion$eta_directo), 4), "a",
    round(max(comparacion$eta_directo), 4), "\n")
cat("Rango eta_pond:                      ",
    round(min(comparacion$eta_pond), 4), "a",
    round(max(comparacion$eta_pond), 4), "\n")

# -------------------------------------------------------------------------
# 7. Benchmarking aditivo por muestra (aproximación ilustrativa)
# -------------------------------------------------------------------------
# 06_posterior_draws_core.rds no conserva las T muestras de Y_tot por
# unidad territorial (solo los parámetros estructurales), así que no se
# dispone de las réplicas posteriores reales para propagar el ajuste
# muestra por muestra. Para ilustrar el mecanismo se simulan T = 1000
# réplicas aproximadas por unidad a partir de una normal truncada en cero
# con la media y la desviación estándar ya calculadas -- no reemplaza las
# muestras MCMC genuinas, pero permite ilustrar el procedimiento.

set.seed(2025)
T_sim <- 1000

N_samples <- sapply(seq_len(nrow(comparacion)), function(r) {
  pmax(0, rnorm(T_sim, mean = comparacion$N_hat[r], sd = sqrt(comparacion$w[r])))
})
colnames(N_samples) <- comparacion$`Unidad territorial`

calibrar_muestras_aditivo <- function(N_samples, N_control, pesos) {
  totales_muestra <- rowSums(N_samples)
  delta_t  <- N_control - totales_muestra
  ajuste_t <- outer(delta_t, pesos / sum(pesos))
  N_samples + ajuste_t
}

N_bench_samples <- calibrar_muestras_aditivo(N_samples, N_star, comparacion$w)

ic_bench    <- apply(N_bench_samples, 2, quantile, probs = c(0.025, 0.975))
ic_original <- apply(N_samples, 2, quantile, probs = c(0.025, 0.975))

resultado_aditivo <- tibble(
  `Unidad territorial` = comparacion$`Unidad territorial`,
  N_hat                = comparacion$N_hat,
  N_bench_media         = colMeans(N_bench_samples),
  ic_li                 = ic_bench[1, ],
  ic_ls                 = ic_bench[2, ],
  eta_aditivo            = (colMeans(N_bench_samples) - comparacion$N_hat) / comparacion$N_hat,
  longitud_relativa      = (ic_bench[2, ] - ic_bench[1, ]) / (ic_original[2, ] - ic_original[1, ])
)

print(resultado_aditivo, n = Inf)

cat("\nSuma de medias bench (aditivo):", sum(resultado_aditivo$N_bench_media),
    " (N*:", N_star, ")\n")

# -------------------------------------------------------------------------
# 8. Cascada al nivel de segmento censal
# -------------------------------------------------------------------------
# El benchmarking anterior corrige el total de cada una de las 11
# unidades, pero el modelo se especifica y se estima al nivel de segmento
# censal (Capítulos 2, 5, 6 y 7): publicar solo el total corregido por
# unidad deja sin resolver cómo se distribuye esa corrección entre los
# segmentos que la componen. Se aplica el mismo principio de calibración
# jerárquica descendente: el factor implícito en la calibración directa
# de cada unidad, phi_l = N_ext_l / N_hat_l, se aplica a todos sus
# segmentos por igual, preservando el peso relativo de cada segmento
# dentro de su unidad.

# Intervalo de credibilidad posterior de cada segmento (Y_tot, antes de
# calibrar): los cuantiles reales del ajuste, no una aproximación. Como
# en la varianza (Sección 1), los segmentos con cobertura censal completa
# se tratan como puntuales -- su conteo es exacto, sin incertidumbre --
# en lugar de usar el intervalo del modelo, que no aplica una vez que la
# regla de dominancia adopta el conteo censal.
pred_area$ic_li_segm <- ifelse(
  pred_area$Status == "Completa", pred_area$pob_final_media, stan_summary[y_tot_rows, "2.5%"]
)
pred_area$ic_ls_segm <- ifelse(
  pred_area$Status == "Completa", pred_area$pob_final_media, stan_summary[y_tot_rows, "97.5%"]
)

segmentos_bench <- pred_area %>%
  left_join(mapa_unidad, by = "parish_value") %>%
  left_join(
    comparacion %>% select(`Unidad territorial`, N_hat_unidad = N_hat, N_ext),
    by = "Unidad territorial"
  ) %>%
  mutate(
    phi_unidad     = N_ext / N_hat_unidad,
    pob_bench_segm = pob_final_media * phi_unidad,
    # El intervalo se escala por el mismo factor: al ser una transformación
    # lineal positiva, los cuantiles se escalan exactamente igual
    ic_li_bench_segm = ic_li_segm * phi_unidad,
    ic_ls_bench_segm = ic_ls_segm * phi_unidad
  )

# Verificación: la suma de los segmentos calibrados de cada unidad debe
# coincidir exactamente con la referencia externa de esa unidad, y la
# suma de las 11 unidades con N* (609 segmentos, no se listan todos)
verificacion_segmento <- segmentos_bench %>%
  group_by(`Unidad territorial`) %>%
  summarise(
    n_segmentos              = n(),
    suma_segmentos_calibrados = sum(pob_bench_segm),
    .groups = "drop"
  ) %>%
  left_join(comparacion %>% select(`Unidad territorial`, N_ext), by = "Unidad territorial") %>%
  mutate(`Unidad territorial` = factor(`Unidad territorial`, levels = comparacion$`Unidad territorial`)) %>%
  arrange(`Unidad territorial`) %>%
  mutate(`Unidad territorial` = as.character(`Unidad territorial`))

stopifnot(isTRUE(all.equal(
  verificacion_segmento$suma_segmentos_calibrados,
  verificacion_segmento$N_ext,
  tolerance = 1e-6
)))
stopifnot(isTRUE(all.equal(sum(segmentos_bench$pob_bench_segm), N_star)))

print(verificacion_segmento, n = Inf)
cat("\nSuma de los 609 segmentos calibrados:", sum(segmentos_bench$pob_bench_segm),
    " (N*:", N_star, ")\n")

# Un puñado de segmentos de ejemplo (los tres más grandes y los tres más
# pequeños de la Unidad 1) para ilustrar la cascada a nivel individual,
# con su intervalo de credibilidad antes y después de calibrar
ejemplos_segmento <- segmentos_bench %>%
  filter(`Unidad territorial` == "Unidad 1") %>%
  arrange(desc(pob_final_media)) %>%
  slice(c(1:3, (n() - 2):n())) %>%
  select(
    ED_number_value, pob_final_media, ic_li_segm, ic_ls_segm,
    phi_unidad, pob_bench_segm, ic_li_bench_segm, ic_ls_bench_segm
  )

print(ejemplos_segmento)

# Verificación adicional: agregando la varianza posterior de los
# segmentos calibrados de una unidad (escalada por phi^2) se recupera,
# de forma aproximada, la misma incertidumbre agregada usada en el
# ajuste ponderado y aditivo (Secciones 6-7) para esa unidad
verificacion_varianza <- segmentos_bench %>%
  group_by(`Unidad territorial`) %>%
  summarise(w_segmentos_bench = sum(N_var * phi_unidad^2), .groups = "drop") %>%
  left_join(comparacion %>% select(`Unidad territorial`, w), by = "Unidad territorial")

print(verificacion_varianza, n = Inf)

# -------------------------------------------------------------------------
# 9. Guardar resultados
# -------------------------------------------------------------------------

saveRDS(
  list(
    comparacion           = comparacion,
    resultado_aditivo     = resultado_aditivo,
    verificacion_segmento = verificacion_segmento,
    ejemplos_segmento     = ejemplos_segmento,
    verificacion_varianza = verificacion_varianza,
    N_star                = N_star,
    N_hat_mas             = N_hat_mas
  ),
  file.path("Data/rutinas/Output", "07_benchmarking.rds")
)
