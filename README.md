# Modelos Bayesianos de Población para América Latina y el Caribe

https://stalynguerrero.github.io/MBP-ALC/

## Descripción del Proyecto

Libro completo sobre implementación, validación y aplicación subnacional de modelos bayesianos para estimación de población. Enfoque práctico con fundamentos teóricos, ecuaciones, código computacional y casos de aplicación regional.

**Idioma:** Español
**Audiencia:** Estadísticos, demógrafos, profesionales de institutos nacionales de estadística
**Formato final:** PDF con capítulos, ecuaciones, código y apéndices

---

## Contenido del Libro

| Archivo | Título | Contenido | En el build |
|---|---|---|:---:|
| `index.Rmd` | Prefacio | Presentación del libro y objetivos | ✅ |
| `01-intro.Rmd` | Introducción | Motivación y contexto general de la estimación de población en ALC | ✅ |
| `02-Modelos_poblacion.Rmd` | Enfoque General de los Modelos de Población | Producción de conteos censales, indicadores de interés (conteos, tasas derivadas, estructuras etarias) y formulación del problema de subcobertura, no respuesta y omisión censal | ✅ |
| `03-Integracion_Fuentes.Rmd` | Integración de Fuentes de Información | Principios de modelamiento, identificación de fuentes (preconteos, registros administrativos, imágenes satelitales) y construcción de variables explicativas | ✅ |
| `04-Imagenes_Satelitales.Rmd` | Preparación de Imágenes Satelitales | Fuentes satelitales, preprocesamiento, extracción de índices espectrales | ❌ pendiente de escribir |
| `05-InsumosModelamiento.Rmd` | Insumos para Modelamiento | Estandarización de fuentes, evaluación de cobertura, construcción de la variable dependiente y diagnóstico exploratorio de los datos | ✅ |
| `06-Modelo_Conteos.Rmd` | Modelo para Conteos Poblacionales | Modelo Poisson-lognormal jerárquico: verosimilitud, distribuciones previas, distribución posterior, componentes del modelo (efectos fijos, aleatorios, interacciones, sobredispersión y offset) | ✅ |
| `07-Inferencia_Bayesiana.Rmd` | Inferencia Bayesiana e Implementación Computacional | Métodos de simulación (MCMC, HMC/NUTS), implementación en Stan, distribución posterior y estimaciones puntuales | ✅ |
| `08-Diagnostico_Validacion.Rmd` | Diagnóstico y Validación del Modelo | Convergencia MCMC, validación predictiva posterior, selección de modelos (LOO/WAIC), validación externa | ❌ pendiente de escribir |
| `09-Calibracion_Benchmarking.Rmd` | Calibración y Benchmarking Subnacional | Métodos de benchmarking y coherencia entre niveles geográficos | ❌ pendiente de escribir |
| `10-Conclusiones.Rmd` | Conclusiones y Recomendaciones Institucionales | Síntesis metodológica y recomendaciones institucionales | ❌ pendiente de escribir |
| `11-references.Rmd` | Referencias | Bibliografía completa del libro | ✅ |

---

## Estado y Avances

**Capítulo 4 — Insumos para Modelamiento (`05-InsumosModelamiento.Rmd`)**
- Diagnóstico exploratorio, tabla de estadísticos descriptivos y tabla de VIF, histograma y heatmap de correlación en `ggplot2`.
- Sección de outliers con gráfico de dispersión (residuo de Pearson vs. distancia de Mahalanobis).
- Notación de densidad poblacional unificada como $\text{DP}_i$ en todo el libro.
- Pendiente: migrar los datos simulados (`set.seed()`, `rnorm()`, `rpois()`) a datos reales y públicos (INE, DANE, DGEEC u otras fuentes oficiales).

**Capítulo 5 — Modelo para Conteos Poblacionales (`06-Modelo_Conteos.Rmd`)**
- Derivación completa de la función de verosimilitud y de la distribución posterior desde el teorema de Bayes.
- Distribuciones previas no informativas, parametrizadas de forma genérica ($\tau_\beta^2,\tau_U^2,\tau_\sigma$); el libro usa exclusivamente el modelo Poisson-lognormal.
- Notación de densidad y cardinalidad de segmentos ($D$, $\text{DP}_i$, $\delta_i$) diferenciada explícitamente para evitar ambigüedad.
- Completado como especificación teórica; no requiere datos reales.

**Capítulo 6 — Inferencia Bayesiana (`07-Inferencia_Bayesiana.Rmd`)**
- Terminología y previas alineadas con el capítulo 5.
- Código Stan presente pero aún ilustrativo (no ejecutado).
- Pendiente: instalar `rstan`/`bayesplot`/`loo` + Rtools y ajustar el modelo sobre datos reales para obtener salidas genuinas (resumen posterior, $\hat R$/ESS, gráfico de verificación predictiva posterior, LOO/WAIC).

**Infraestructura del proyecto**
- `docs/.nojekyll` asegura que GitHub Pages sirva la salida de bookdown directamente, sin procesarla con Jekyll.

### Próxima etapa

Migrar los ejemplos de código de los capítulos 4 y 5 a datos reales y públicos (agregados/open data de INE, DANE, DGEEC u otras fuentes oficiales), sin comprometer microdatos individuales. Para el capítulo 6 esto además implica instalar `rstan` (o `cmdstanr`) + Rtools y ejecutar el modelo Poisson-lognormal real sobre esos datos.

---

## Checklist por Capítulo

### Enfoque General de los Modelos de Población (`02-Modelos_poblacion.Rmd`)
**Estado:** [x] Completado

- [x] Producción de conteos censales (producción subnacional, desagregación por sexo y edad, uso en marcos muestrales, definición de dominios en 4 niveles: nacional, intermedio, local, segmento censal)
- [x] Indicadores de interés — conteos poblacionales ($N_{i,s,e}$), tasas derivadas (densidad $\text{DP}_i$, razón de masculinidad, tasa de dependencia, índice de envejecimiento), estructuras etarias
- [x] Formulación del problema de subcobertura, no respuesta y omisión censal ($Y=N-O+D+C$)

### Integración de Fuentes de Información (`03-Integracion_Fuentes.Rmd`)
**Estado:** [x] Completado

- [x] Principios de modelamiento (modelos de conteo, requerimientos de estimación subnacional, justificación del enfoque bayesiano, integración de múltiples fuentes, relación con Small Area Estimation)
- [x] Identificación de fuentes (medición de cobertura por segmento, preconteos y segmentación, registros administrativos, fuentes satelitales)
- [x] Variables explicativas — socioeconómicas y espaciales *(las variables demográficas se excluyen deliberadamente: no están disponibles de forma independiente en segmentos con cobertura incompleta)*

### Preparación de Imágenes Satelitales (`04-Imagenes_Satelitales.Rmd`)
**Estado:** [ ] No iniciado

**Responsable:** Luis

- [ ] Fuentes de datos satelitales (Landsat, Sentinel, MODIS)
- [ ] Preprocesamiento y correcciones atmosféricas
- [ ] Extracción de características (NDVI, índices espectrales)
- [ ] Validación con datos de campo
- [ ] Generación de capas para el modelo

### Insumos para Modelamiento (`05-InsumosModelamiento.Rmd`)
**Estado:** [x] En progreso — falta migrar los ejemplos a datos reales

- [x] Estandarización de fuentes (homologación y normalización de variables)
- [x] Evaluación de cobertura (tasa de cobertura por segmento, clasificación de segmentos)
- [x] Construcción de la variable dependiente (conteos agregados, tasas poblacionales, población base)
- [x] Diagnóstico exploratorio (distribución de conteos, outliers, relación entre variables)

### Modelo para Conteos Poblacionales (`06-Modelo_Conteos.Rmd`)
**Estado:** [x] Completado — especificación teórica, no requiere datos reales

- [x] Modelo Poisson condicional/bayesiano (definición formal, función de verosimilitud, distribuciones previas no informativas, distribución posterior, interpretación de parámetros)
- [x] Componentes del modelo (efectos fijos, efectos aleatorios, interacciones, sobredispersión y offset)

### Inferencia Bayesiana e Implementación Computacional (`07-Inferencia_Bayesiana.Rmd`)
**Estado:** [x] En progreso — falta ejecutar con datos y modelo reales

- [x] Métodos de simulación (MCMC, Hamiltonian Monte Carlo, algoritmo NUTS, implementación en Stan, configuración y paralelización)
- [x] Distribución posterior y estimaciones puntuales (media, mediana, intervalos de credibilidad, agregación por niveles)
- [ ] Ejecución real del modelo con salidas genuinas (posterior, $\hat R$/ESS, PPC, LOO/WAIC)

### Diagnóstico y Validación del Modelo (`08-Diagnostico_Validacion.Rmd`)
**Estado:** [ ] No iniciado

- [ ] Diagnóstico de convergencia MCMC (R-hat, ESS, trace plots)
- [ ] Validación predictiva posterior (PPC, residuos bayesianos)
- [ ] Selección y comparación de modelos (LOO-CV, WAIC)
- [ ] Validación externa (proyecciones demográficas, registros administrativos, coherencia geoespacial)

### Calibración y Benchmarking Subnacional (`09-Calibracion_Benchmarking.Rmd`)
**Estado:** [ ] No iniciado

- [ ] Benchmarking con proyecciones poblacionales
- [ ] Métodos de benchmarking (proporcional, por razones de ajuste, aditivo)
- [ ] Evaluación del impacto del benchmarking

### Conclusiones y Recomendaciones Institucionales (`10-Conclusiones.Rmd`)
**Estado:** [ ] No iniciado

- [ ] Principales hallazgos metodológicos
- [ ] Recomendaciones para organismos nacionales de estadística
- [ ] Rol de organismos internacionales en transferencia metodológica
- [ ] Limitaciones del enfoque y condiciones para su aplicación
