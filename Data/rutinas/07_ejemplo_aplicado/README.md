# Rutinas — Capítulo 7, sección "Aplicación con datos reales"

Cada script genera, a partir de los `.rds` reales de `Data/ejemplos_reales/BRB_2024`
(y `JAM_2025` para la comparación de cadenas), **un único resultado** (una tabla o
una figura) usado en `07_1_Ejemplo_Aplicado.Rmd`. El `.Rmd` no computa ni ordena
nada: solo lee el `.rds`/`.png` ya generado y lo formatea (`kable`/`include_graphics`).

Ejecutar en orden, con el working directory en la raíz del proyecto (`MBP-ALC/`):

| Script | Genera | Usado en el chunk |
|---|---|---|
| `01_preparar_datos.R` | `BRB_2024/07_prediccion_status.rds` | insumo de los scripts 02, 03, 06, 07 |
| `02_descriptivo_insumo.R` | `BRB_2024/08_resumen_descriptivo.rds` | `ejemplo-descriptivo` |
| `03_densidad_insumo.R` | `images/cap_07/00_densidad_insumo_brb.png` | `ejemplo-densidad-insumo` |
| `04_acf_sigma.R` | `images/cap_07/04_acf_sigma_brb.png` | `ejemplo-acf` |
| `05_comparacion_cadenas.R` | `BRB_2024/09_comparacion_cadenas.rds` | `ejemplo-comparacion-cadenas` |
| `06_totales_nacionales.R` | `BRB_2024/10_totales_nacionales.rds` | `ejemplo-totales` |
| `07_agregacion_territorial.R` | `BRB_2024/11_agregacion_territorial.rds` | `ejemplo-agregacion` |

`01_preparar_datos.R` debe correrse primero: 02, 03, 06 y 07 dependen de su salida
(`07_prediccion_status.rds`).
