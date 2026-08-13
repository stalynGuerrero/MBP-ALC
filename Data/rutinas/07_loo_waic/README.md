# Rutinas — LOO/WAIC con datos reales (BRB_2024)

El Código `exr:cod-loo-waic` (Sección `cap-inferencia`, capítulo 7) no puede
reproducirse con datos reales porque ninguno de los programas Stan de
producción documentados en `Data/ejemplos_reales/README.md` —incluido
`Data/ejemplos_reales/BRB_2024/Modelo_worldpop_V03.stan`— calcula `log_lik`
en `generated quantities`.

Esta carpeta reajusta el modelo de Barbados **sin modificar nada del
original** (ni el `.stan`, ni los `.rds` de `Data/ejemplos_reales/BRB_2024/`,
ni el proyecto fuente `2024BRB/`), agregando `log_lik` en una copia del
programa Stan, para poder calcular LOO-CV y WAIC con `loo`.

## Insumos

Los datos crudos (censo agregado por ED, covariables satelitales, marco de
conexión ED–parroquia) se leen en modo solo lectura desde el proyecto de
origen `V:/DAT/SAECEPAL/PopulationModels/2024BRB/` — **un nivel arriba de
MBP-ALC**, no versionado en este repo — replicando exactamente la selección
de variables y la construcción de `list_par` de
`2024BRB/Rcodes/03_model_bayes_poisson.R` (líneas 35-179). No se copia
microdata de persona/vivienda a este repo: solo el objeto `list_par`
(covariables agregadas por ED, mismo tipo de insumo que ya usa el ajuste de
producción) queda guardado en `Output/`.

## Scripts (ejecutar en orden, working directory = raíz de `MBP-ALC/`)

| Script | Qué hace | Genera |
|---|---|---|
| `01_preparar_datos_modelo.R` | Reconstruye `data_model`/`list_par` desde el proyecto fuente | `Output/list_par.rds` |
| `02_ajustar_modelo_loglik.R` | Ajusta `Modelo_worldpop_V03_loglik.stan` (4 cadenas, `iter=2000`, `warmup=1500`, igual que la producción original) y calcula LOO/WAIC | `Output/05_stan_summary_loglik.rds`, `Output/06_posterior_draws_core_loglik.rds`, `Output/loo_result.rds`, `Output/waic_result.rds` |

`02_ajustar_modelo_loglik.R` tarda varios minutos (ajuste MCMC real); está
pensado para lanzarse en segundo plano, p. ej.:

```
Rscript Data/rutinas/07_loo_waic/02_ajustar_modelo_loglik.R > Data/rutinas/07_loo_waic/fit.log 2>&1
```

## Verificación de fidelidad al ajuste original

`01_preparar_datos_modelo.R` reproduce `D_obs=588`, `D_tot=609`, `P=18`,
`Q=11` — coincide con `beta[1..18]`, `gamma[1..11]` documentado para
`06_posterior_draws_core.rds` de BRB en `Data/ejemplos_reales/README.md`,
confirmando que los insumos reconstruidos corresponden al mismo ajuste.

## No se modifica el original

- `Data/ejemplos_reales/BRB_2024/Modelo_worldpop_V03.stan` — intacto.
- `Data/ejemplos_reales/BRB_2024/*.rds` — intactos.
- `../2024BRB/` (proyecto fuente) — solo lectura, no se escribe nada ahí.

El único archivo Stan usado para este ajuste es la copia
`Modelo_worldpop_V03_loglik.stan` en esta misma carpeta.
