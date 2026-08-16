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
| `04-Imagenes_Satelitales.Rmd` | Preparación de Imágenes Satelitales | Fuentes satelitales, preprocesamiento, extracción de índices espectrales | ❌ solo títulos de sección; excluido del build (comentado en `_bookdown.yml`) |
| `05-InsumosModelamiento.Rmd` | Insumos para Modelamiento | Estandarización de fuentes, evaluación de cobertura, construcción de la variable dependiente y diagnóstico exploratorio de los datos | ✅ |
| `06-Modelo_Conteos.Rmd` | Modelo para Conteos Poblacionales | Modelo Poisson-lognormal jerárquico: verosimilitud, distribuciones previas, distribución posterior, componentes del modelo (efectos fijos, aleatorios, interacciones, sobredispersión y offset) | ✅ |
| `07-Inferencia_Bayesiana.Rmd` | Inferencia Bayesiana e Implementación Computacional | Métodos de simulación (MCMC, HMC/NUTS), implementación en Stan, distribución posterior y estimaciones puntuales | ✅ |
| `07_1_Ejemplo_Aplicado.Rmd` | Aplicación con datos reales | Ajuste real del modelo Poisson-lognormal (datos anonimizados): diagnóstico de convergencia, PPC, LOO/WAIC/Pareto-k y agregación territorial, todos con salidas genuinas | ✅ |
| `08-Diagnostico_Validacion.Rmd` | Diagnóstico y Validación del Modelo | Convergencia MCMC, validación predictiva posterior, selección de modelos (LOO/WAIC), validación externa | ✅ |
| `09-Calibracion_Benchmarking.Rmd` | Calibración y Benchmarking Subnacional | Métodos de benchmarking y coherencia entre niveles geográficos, con ejemplo aplicado real y cascada al segmento censal | ✅ |
| `10-Conclusiones.Rmd` | Conclusiones y Recomendaciones Institucionales | Síntesis metodológica y recomendaciones institucionales | ✅ |
| `11-references.Rmd` | Referencias | Bibliografía completa del libro | ✅ |

---

## Estado y Avances

**Capítulo 4 — Preparación de Imágenes Satelitales (`04-Imagenes_Satelitales.Rmd`)**
- Solo contiene los títulos de sección, sin desarrollar. Excluido del build actual (comentado en `_bookdown.yml`).
- Gran parte de su temática (luminosidad nocturna, área construida/GHSL, NDVI, LST, modelos digitales de elevación, Google Earth Engine) ya está cubierta en la Sección "Fuentes satelitales" del Capítulo 3.

**Capítulo 5 — Insumos para Modelamiento (`05-InsumosModelamiento.Rmd`)**
- Diagnóstico exploratorio, tabla de estadísticos descriptivos y tabla de VIF, histograma y heatmap de correlación en `ggplot2`.
- Sección de outliers con gráfico de dispersión (residuo de Pearson vs. distancia de Mahalanobis).
- Notación de densidad poblacional unificada como $\text{DP}_i$ en todo el libro.
- Pendiente: migrar los datos simulados (`set.seed()`, `rnorm()`, `rpois()`) a datos reales y públicos (INE, DANE, DGEEC u otras fuentes oficiales).

**Capítulo 6 — Modelo para Conteos Poblacionales (`06-Modelo_Conteos.Rmd`)**
- Derivación completa de la función de verosimilitud y de la distribución posterior desde el teorema de Bayes.
- Distribuciones previas no informativas, parametrizadas de forma genérica ($\tau_\beta^2,\tau_U^2,\tau_\sigma$); el libro usa exclusivamente el modelo Poisson-lognormal.
- Notación de densidad y cardinalidad de segmentos ($D$, $\text{DP}_i$, $\delta_i$) diferenciada explícitamente para evitar ambigüedad.
- Completado como especificación teórica; no requiere datos reales.

**Capítulo 7 — Inferencia Bayesiana e Implementación Computacional (`07-Inferencia_Bayesiana.Rmd` + `07_1_Ejemplo_Aplicado.Rmd`)**
- Código Stan completo y documentado bloque por bloque (especificación/ajuste y cantidades generadas).
- Aplicación con datos reales (unidades territoriales anonimizadas, sin identificar el país de origen): diagnóstico de convergencia con salidas genuinas ($\hat R$, ESS, trace plots, autocorrelación — incluyendo un valor de $\hat R$ fuera de umbral reportado honestamente), verificación predictiva posterior real, y LOO/WAIC reales con su diagnóstico Pareto-$k$ (advertencia explícita sobre la fiabilidad limitada de la aproximación en este ajuste).

**Capítulo 8 — Diagnóstico y Validación del Modelo (`08-Diagnostico_Validacion.Rmd`)**
- Completo: $\hat R$ clásico y rank-normalizado, ESS Bulk/Tail, trace plots, divergencias, E-BFMI, PPC, residuos bayesianos, calibración y nitidez (*sharpness*), LOO-CV con diagnóstico Pareto-$k$, WAIC, *ranked probability score*, y validación externa (proyecciones demográficas, registros administrativos independientes, coherencia territorial).

**Capítulo 9 — Calibración y Benchmarking Subnacional (`09-Calibracion_Benchmarking.Rmd`)**
- Completo: coherencia jerárquica interna vs. coherencia externa, los tres métodos de benchmarking (proporcional, ponderado por incertidumbre, aditivo por muestra con intervalos de credibilidad calibrados), un ejemplo aplicado real contra referencias externas por unidad, y la cascada de calibración hasta el segmento censal.

**Capítulo 10 — Conclusiones y Recomendaciones Institucionales (`10-Conclusiones.Rmd`)**
- Completo: hallazgos metodológicos, recomendaciones para institutos nacionales de estadística (incluye la precisión de que el modelamiento es un mecanismo correctivo posterior al operativo censal, activado solo cuando la evaluación de cobertura evidencia problemas), rol de organismos internacionales, y limitaciones del enfoque.

**Infraestructura y calidad del proyecto**
- `docs/.nojekyll` asegura que GitHub Pages sirva la salida de bookdown directamente, sin procesarla con Jekyll.
- `book.bib` auditado: todas las citas usadas en el texto tienen entrada bibliográfica y viceversa (sin entradas huérfanas), y se verificó que cada cita respalde efectivamente la afirmación del párrafo donde se usa.

### Próxima etapa

Migrar los ejemplos de código del Capítulo 5 a datos reales y públicos (agregados/open data de INE, DANE, DGEEC u otras fuentes oficiales), sin comprometer microdatos individuales. Definir el futuro del Capítulo 4 (desarrollarlo, fusionarlo con el Capítulo 3, o retirarlo formalmente del proyecto).

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

### Inferencia Bayesiana e Implementación Computacional (`07-Inferencia_Bayesiana.Rmd`, `07_1_Ejemplo_Aplicado.Rmd`)
**Estado:** [x] Completado

- [x] Métodos de simulación (MCMC, Hamiltonian Monte Carlo, algoritmo NUTS, implementación en Stan, configuración y paralelización)
- [x] Distribución posterior y estimaciones puntuales (media, mediana, intervalos de credibilidad, agregación por niveles)
- [x] Aplicación con datos reales: salidas genuinas de convergencia ($\hat R$/ESS, trace plots, autocorrelación), PPC y LOO/WAIC/Pareto-$k$

### Diagnóstico y Validación del Modelo (`08-Diagnostico_Validacion.Rmd`)
**Estado:** [x] Completado

- [x] Diagnóstico de convergencia MCMC ($\hat R$ clásico y rank-normalizado, ESS Bulk/Tail, trace plots, divergencias, E-BFMI)
- [x] Validación predictiva posterior (PPC, residuos bayesianos, calibración y nitidez)
- [x] Selección y comparación de modelos (LOO-CV con Pareto-$k$, WAIC, *ranked probability score*)
- [x] Validación externa (proyecciones demográficas, registros administrativos independientes, coherencia territorial y demográfica)

### Calibración y Benchmarking Subnacional (`09-Calibracion_Benchmarking.Rmd`)
**Estado:** [x] Completado

- [x] Benchmarking con proyecciones poblacionales (coherencia jerárquica interna vs. coherencia externa)
- [x] Métodos de benchmarking (proporcional, ponderado por incertidumbre, aditivo por muestra con intervalos de credibilidad calibrados)
- [x] Evaluación del impacto del benchmarking — ejemplo aplicado real con referencia externa por unidad y cascada de calibración al segmento censal

### Conclusiones y Recomendaciones Institucionales (`10-Conclusiones.Rmd`)
**Estado:** [x] Completado

- [x] Principales hallazgos metodológicos
- [x] Recomendaciones para organismos nacionales de estadística
- [x] Rol de organismos internacionales en transferencia metodológica
- [x] Limitaciones del enfoque y condiciones para su aplicación
