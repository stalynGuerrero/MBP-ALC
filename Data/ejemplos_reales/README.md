# Datos de ejemplo — resultados reales de proyectos de país

Esta carpeta contiene **bases de resultados agregados** (no microdata) provenientes de
proyectos reales de estimación bayesiana de población ejecutados para CEPAL/UNFPA,
seleccionados como insumo para ejemplos reproducibles del libro.

## Criterio de selección (ver `CLAUDE.md` — "Country/Data Context")

- Solo se incluyeron países cuyos resultados **ya están publicados oficialmente**
  (confirmado por el autor): **Barbados (2024)**, **República Dominicana (2025)**,
  **Dominica (2025)** y **Jamaica (2025)**.
- Solo se copiaron tablas **agregadas por unidad de área** (ED / segmento / parroquia),
  nunca registros de persona o vivienda. Los archivos con microdata censal a nivel de
  persona (p. ej. `CRI2022/Modelo_Unidad/Data/*censo_vivienda_personas*.rds`, 1.77M filas)
  fueron explícitamente **excluidos** y no deben copiarse a este proyecto.
- No se copiaron las matrices de draws posteriores crudos (`0X_df_pred_bayes.rds` /
  `0X_df_dens_pred_bayes.rds` en los proyectos de origen), que pesan 60–235 MB y son
  intermedios de cómputo, no resultados finales. Solo se trajeron las tablas de
  resumen posterior (mediana/media/sd) ya colapsadas por área.
- Origen de los archivos (no versionado aquí, solo referencia):
  `../2024BRB/`, `../DOM2025/`, `../DMA2025/` y `../JAM2025/` dentro de
  `PopulationModels/` (un nivel arriba de `MBP-ALC/`).
- Para DMA y JAM, cada país tuvo **varias corridas/versiones** del modelo a lo largo
  del proyecto; en ambos casos se seleccionó la **más reciente por fecha de
  modificación del archivo**, verificada contra el script R que la generó y contra
  la fecha del entregable Excel final. Ver detalle en cada sección.

## BRB_2024/ — Barbados

Nivel de agregación: **ED (enumeration district)**, agrupado dentro de parroquia.

| Archivo | Filas × Cols | Contenido |
|---|---|---|
| `03_prediccion_poblation_bayes.rds` | 609 × 11 | Estimación final de población por ED: `ED_number_value`, `parish_value`, `parish_label`, `cont_pers` (conteo censal), `hh_2021`, `hh_2021_imp`, `per_com`, `per_com_ajus`, `estimacion_median`, `estimacion_mean`, `densidad_pop` |
| `04_theta_group_age.rds` | 42 × 5 | Parámetros $\theta$ (proporción) por grupo etario y sexo: `Sex`, `group_age`, `orden`, `theta`, `theta_sd` — útil como ejemplo de tabla de salida para la notación $\boldsymbol{\theta}$ de Cap. 6 |
| `04_theta_group_age_mediana.rds` | 42 × 5 | Igual que el anterior, usando la mediana posterior como resumen puntual |
| `BRB.xlsx` | — | Entregable final en Excel (formato de reporte a contraparte) |
| `05_stan_summary.rds` | 3623 × 10 | Salida de `summary(stan_model)$summary` (rstan) para **todos** los parámetros del ajuste original (`beta`, `gamma`, `sigma`, `sigmaU`, `densidad`, `lambda`, `Y_tot`, `lp__`, …): `mean`, `se_mean`, `sd`, cuantiles, `n_eff`, `Rhat`. Permite reconstruir el histograma de Rhat (`02_rhat_pers`) y tablas de diagnóstico sin cargar el `stanfit` completo |
| `06_posterior_draws_core.rds` | array 1000×4×32 | Draws posteriores **por cadena** (`rstan::extract(fit, permuted=FALSE)`) solo para los parámetros estructurales de baja dimensión: `beta[1..18]`, `gamma[1..11]`, `sigma`, `sigmaU`, `lp__`. Suficiente para reproducir *trace plots* y diagnósticos de convergencia con `bayesplot::mcmc_trace()` / `mcmc_rhat()` (verificado) |
| `Modelo_worldpop_V03.stan` | — | Código Stan **real y efectivamente ajustado** para producir el `stanfit` de origen (confirmado en `2024BRB/Rcodes/03_model_bayes_poisson.R:183`). Usa la notación `D_obs`/`D_tot` ya adoptada en el libro (Cap. 2/5/6) |

**Nota — objeto `stanfit` completo NO copiado:** el ajuste original,
`../2024BRB/Data/modelo/fip_pob_bayes_lognormal.rds` (187 MB, incluye draws
completos de `densidad`/`lambda`/`Y_tot` para las 588-609 EDs), **no se trajo al
repo** porque excede el límite de tamaño de archivo de GitHub (push falla >100 MB)
y este repo sí tiene remoto en GitHub (`stalynGuerrero/MBP-ALC`). En su lugar se
extrajeron `05_stan_summary.rds` y `06_posterior_draws_core.rds`, que cubren los
diagnósticos de convergencia (Rhat, ESS, trace) sin el peso de las cantidades
generadas por área. Si se necesita reproducir el chequeo predictivo posterior por
área (`01_densidad_pers`), usar `03_prediccion_poblation_bayes.rds` (medias/medianas
por ED) como aproximación, o volver a extraer del `stanfit` original bajo demanda.

## DOM_2025/ — República Dominicana

Nivel de agregación: **segmento censal** (`cod_segmen`), anidado en
región/provincia/municipio/distrito/sección/área.

| Archivo | Filas × Cols | Contenido |
|---|---|---|
| `03_prediccion_poblation_bayes.rds` | 31,538 × 16 | Estimación por segmento sin benchmarking: códigos administrativos (`cod_region` … `cod_segmen`), `estado_segm`, `tot_viv_pers_presentes`, `tot_viv_pers_ausente`, `tot_pob`, `estimacion_median_pers_ausente`, `estimacion_mean_pers_ausente`, `densidad_pop`, `estimacion_median`, `estimacion_mean` |
| `03_prediccion_poblation_bayes_bench.rds` | 31,538 × 11 | Misma unidad de análisis, después de **benchmarking**: `poblacion`, `poblacion_sd` — ejemplo natural para Cap. 9 (Calibración y Benchmarking) |
| `03_prediccion_poblation.xlsx` | — | Entregable final en Excel |

## DMA_2025/ — Dominica

Nivel de agregación: **ED**, agrupado en parroquia (`PAR`).
Corrida seleccionada: **V2** (la más reciente de tres versiones V0/V1/V2 corridas
entre 2025-06-26 y 2025-09-05; confirmada en `DMA2025/Rcodes/03_Modelo_poisson.R`
como la que usa `Modelo_ECLAC_V02_fin.stan` y guarda en `Poisson_lognormal_V2/`).

| Archivo | Filas × Cols | Contenido |
|---|---|---|
| `03_prediccion_poblation_final.xlsx` | 321 × 7 | Entregable final a la contraparte (`PARISH`, `PARISH_ID`, `Status`, `ED_ID`, `Google Buildings`, `DWellings ECLAC/UNFPA`, `Poblation estimation ECLAC/UNFPA`) — copiado desde `"V1 Results - ECLAC_UNFPA 20250911.xlsx"`, el más reciente de los dos deliverables encontrados |
| `05_stan_summary.rds` | 2102 × 10 | `summary(stan_model)$summary` completo del ajuste V2 (mean, sd, cuantiles, `n_eff`, `Rhat`) |
| `06_posterior_draws_core.rds` | array 500×4×29 | Draws por cadena de `beta[1..15]`, `gamma[1..11]`, `sigma`, `sigmaU`, `lp__` (4 cadenas, 500 iteraciones post-calentamiento c/u) — verificado con `bayesplot::mcmc_trace()`/`mcmc_rhat()` |
| `Modelo_ECLAC_V02_fin.stan` | — | Código Stan real ajustado. Mismo modelo Poisson-lognormal jerárquico que Barbados, pero con priors `sigma ~ inv_gamma(0.001,0.001)` / `sigmaU ~ inv_gamma(0.001,0.001)` en lugar del half-Cauchy/half-normal ya documentado como convención del libro — útil para contrastar variantes de prior en Cap. 6 |

**Nota:** el `stanfit` original (`../DMA2025/Data/modelo/Poisson_lognormal_V2/fit_pob_bayes_lognormal_V00.rds`,
111 MB) no se copió, por la misma razón de tamaño que en Barbados; se aplicó la
misma extracción liviana.

## JAM_2025/ — Jamaica

Nivel de agregación: **ED**, agrupado en parroquia (`PRSH_ID`).
Corrida seleccionada: **PBA / V09 / V5** — de tres líneas de corridas encontradas
(`2860284` y `Version_prop_2022`, ambas de ene–mar 2025; y `PBA`, de may 2025), se
usó la más reciente: el `stanfit` `fit_pob_bayes_lognormal_V09.rds` (2025-05-05) y
el resultado benchmarkeado `03_prediccion_poblation_bayes_bench_ratio.rds`
(2025-05-21), consistentes en fecha con el deliverable Excel más reciente
(`"V5 Results - Andres - STATIN Feedback - 21_05_2025.xlsx"`, STATIN = instituto
nacional de estadística de Jamaica).

| Archivo | Filas × Cols | Contenido |
|---|---|---|
| `03_prediccion_poblation_final.xlsx` | hoja "V5 Results": 6609 × 6 | Entregable final (`PARISH`, `PRSH_ID`, `ED_ID`, `Google Building`, `Dwellings ECLAC`, `Population Estimation - ECLAC`); incluye además hojas de series históricas por parroquia (`Dwellings V05`, `Pop V04`) |
| `03_prediccion_poblation_bayes.rds` | 6609 × 9 | Predicción por ED sin benchmarking: `ED_ID`, `PARISH`, `PRSH_ID`, `P_TOTAL`, `DWELLS_2022`, `Building_Count`, `estimacion_median`, `estimacion_mean`, `densidad_pop` |
| `03_prediccion_poblation_bayes_bench_ratio.rds` | 6609 × 10 | Misma unidad, después de benchmarking por razón (`estimacion_ratio`, `estimacion_bench`) — par natural con el archivo anterior para Cap. 9 |
| `05_stan_summary.rds` | 38056 × 10 | `summary(stan_model)$summary` completo (modelo con más EDs que Barbados/Dominica: `beta[32]`, `gamma[14]`, más `densidad`/`lambda`/`Y_tot` por las 6609 EDs) |
| `06_posterior_draws_core.rds` | array 1000×2×49 | Draws por cadena de `beta[1..32]`, `gamma[1..14]`, `sigma`, `sigmaU`, `lp__` (**2 cadenas**, 1000 iteraciones post-calentamiento c/u — este ajuste usó solo 2 cadenas, a diferencia de las 4 de BRB/DMA; útil para mostrar en el libro que 2 cadenas dificultan más el diagnóstico de Rhat) — verificado con `bayesplot` |
| `Modelo_ECLAC_V02_fin.stan` | — | Mismo código que Dominica (idéntico salvo comentarios) |

**Nota:** los `stanfit` originales de Jamaica son mucho más pesados que los de los
otros tres países (`fit_pob_bayes_lognormal_V09.rds`: **4.8 GB**; la corrida anterior
`.../Poisson_lognormal_2860284/fit_pob_bayes_lognormal_V08_osmb_2860284.rds`: 3.9 GB,
no usada por ser más antigua). Ninguno se copió; se cargaron una vez en memoria
solo para extraer `05_stan_summary.rds` y `06_posterior_draws_core.rds`.

## Uso sugerido por capítulo

- **Cap. 5 (Insumos para Modelamiento):** estructura de un dataset de entrada agregado
  por área (ED/segmento) con conteos censales y covariables derivadas.
- **Cap. 6 (Modelo para Conteos Poblacionales) / Cap. 7 (Inferencia Bayesiana):**
  `04_theta_group_age.rds` de Barbados como ejemplo de salida para $\boldsymbol{\theta}$;
  `03_prediccion_poblation_bayes.rds` como ejemplo de predicción posterior resumida
  (mediana/media) por unidad de área.
- **Cap. 9 (Calibración y Benchmarking Subnacional):** par
  `03_prediccion_poblation_bayes.rds` vs. `03_prediccion_poblation_bayes_bench.rds`
  de República Dominicana para ilustrar el efecto del benchmarking.
- **Cap. 7 (Inferencia Bayesiana) / Cap. 8 (Diagnóstico y Validación):**
  `Modelo_worldpop_V03.stan` (BRB) / `Modelo_ECLAC_V02_fin.stan` (DMA/JAM) como código
  real de referencia; `05_stan_summary.rds` + `06_posterior_draws_core.rds` de los
  cuatro países para generar (con `bayesplot`) trace plots, gráfico de Rhat y tablas
  de ESS con datos genuinos de ajustes reales — reemplazando los ejemplos
  ilustrativos actuales del capítulo. El caso de Jamaica (solo 2 cadenas, vs. 4 en
  los demás) es un buen contraejemplo para discutir número mínimo de cadenas.
- **Contraste de priors:** BRB usa `sigma ~ cauchy(0,2.5)` / `sigmaU ~ normal(0,1)`
  (la convención ya documentada del libro); DMA y JAM usan
  `sigma, sigmaU ~ inv_gamma(0.001,0.001)` — mismo modelo, dos elecciones de prior
  distintas en la práctica real, útil para ilustrar sensibilidad al prior en Cap. 6/7.

## Pendiente / no hecho en esta tarea

No se modificó ningún `.Rmd` ni se compiló el libro — solo se organizaron los datos.
Las imágenes de diagnóstico (trace plots, Rhat, densidad, pirámides) **no se copiaron**;
la instrucción fue traer los `.rds` y regenerar las figuras que se necesiten directamente
en los chunks del libro a partir de `05_stan_summary.rds` / `06_posterior_draws_core.rds`
y de las tablas de predicción de los cuatro países, cuando llegue el momento de escribir
esos capítulos. Falta también decidir si conviene reducir aún más las tablas de DOM/JAM
(p. ej. una sola provincia/parroquia) para que los ejemplos sean más manejables en el texto.
