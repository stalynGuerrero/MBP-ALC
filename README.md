# Modelos Bayesianos de Población para América Latina y el Caribe

https://stalynguerrero.github.io/MBP-ALC/

## Descripción del Proyecto

Libro completo sobre implementación, validación y aplicación subnacional de modelos bayesianos para estimación de población. Enfoque práctico con fundamentos teóricos, ecuaciones, código computacional y casos de aplicación regional.

**Idioma:** Español  
**Audiencia:** Estadísticos, demógrafos, profesionales de institutos nacionales de estadística  
**Formato final:** PDF con capítulos, ecuaciones, código y apéndices

---

## Estado Actual y Registro de Cambios

**Capítulos activos en el build** (ver `_bookdown.yml`): Prefacio, 01-Introducción, 02-Modelos de Población, 03-Integración de Fuentes, 05-Insumos para Modelamiento, 06-Modelo para Conteos Poblacionales, 07-Inferencia Bayesiana, 11-Referencias.

**Existen pero están comentados** (pendientes de revisar y activar): 04-Imágenes Satelitales, 08-Diagnóstico y Validación, 09-Calibración y Benchmarking, 10-Conclusiones.

### Cambios recientes por capítulo

**Capítulo 5 — Insumos para Modelamiento (`05-InsumosModelamiento.Rmd`)**
- Diagnóstico exploratorio reescrito para no exponer que los datos son simulados (el lector ve un análisis directo sobre "el conjunto de segmentos preparado", sin explicar la generación de los datos).
- Tabla de estadísticos descriptivos y tabla de VIF migradas a `knitr::kable()` + `kableExtra::kable_styling()`, con `format` fijado explícitamente según el output (`latex`/`html`/`pipe`) — evita un bug de doble numeración de tabla y una incompatibilidad con Word.
- Histograma y heatmap de correlación reescritos en `ggplot2` (paleta validada con la skill de dataviz), reemplazando `hist()` base y `corrplot()`.
- Sección de outliers: se agregó un gráfico de dispersión (residuo de Pearson vs. distancia de Mahalanobis) con categorías coloreadas; se eliminó la mención a distancia de Cook (no implementada) y la tabla de outliers (se dejó solo el gráfico, a pedido).
- Eliminadas todas las menciones al modelo binomial negativo (el libro solo usa Poisson-lognormal).
- Notación: la densidad poblacional por área ahora es $\text{DP}_i$ (antes $D_i$), para no chocar con la cardinalidad $D=|\mathcal{S}|$ del capítulo 6. Mismo cambio aplicado en el capítulo 2.
- Nuevo formato "Código X.Y": bloques de código destacados y numerados por capítulo (ver convención más abajo).

**Capítulo 6 — Modelo para Conteos Poblacionales (`06-Modelo_Conteos.Rmd`)**
- Sección "Distribución posterior" reescrita por completo: derivación explícita desde el teorema de Bayes (fracción completa, integral de evidencia sobre $\boldsymbol\theta$ y $\boldsymbol\delta$, proporcionalidad, factorización de la previa, sustitución de formas funcionales), en vez de solo enunciar el resultado. Incluye una lista numerada de 7 pasos para el algoritmo MCMC (no un bloque `algorithm` de LaTeX, que no es un motor de knitr válido).
- Distribuciones previas reparametrizadas de forma genérica y no informativa: $\beta_k\sim\mathcal N(0,\tau_\beta^2)$, $\sigma_U\sim\mathcal N^+(0,\tau_U^2)$, $\sigma\sim\text{Cauchy}^+(0,\tau_\sigma)$, con una nota de que la implementación en Stan usa los valores concretos $\tau_\beta^2=1,\ \tau_U^2=1,\ \tau_\sigma=2{,}5$.
- Terminología: "distribuciones a priori" → "distribuciones previas" en todo el capítulo.
- Eliminada la subsección "Especificación alternativa" (Poisson + efecto gaussiano no estructurado): era matemáticamente idéntica al modelo Poisson-lognormal principal, no una alternativa real.
- Eliminada toda comparación con el modelo binomial negativo.
- Corregidas colisiones de notación: $D$ = cardinalidad de segmentos (no densidad); $\text{DP}_i$ = densidad por área; $\delta_i$ = densidad por estructura — los tres se distinguen explícitamente donde podían confundirse.
- Se agregaron citas bibliográficas nuevas (todas ya existentes en `book.bib`, ninguna inventada): `@BryantGraham2013`, `@Mercer2015`, `@Gelman2013`, `@Carpenter2017`, `@Rao2015`, `@Banerjee2015`, `@Vehtari2017`, `@Watanabe2010`, `@BryantZhang2018`.
- Se agregaron labels y referencias cruzadas entre subsecciones: `#definicion-formal`, `#funcion-verosimilitud`, `#distribuciones-previas`, `#distribucion-posterior`, `#efectos-fijos`, `#efectos-aleatorios`, `#sobredispersion-offset`.
- Sección "Efectos fijos": corregida una afirmación que decía que la previa de $\beta_k$ "regulariza" y "estabiliza frente a colinealidad" — contradecía el enfoque no informativo recién adoptado; ahora atribuye el manejo de la multicolinealidad al análisis de correlación y selección de variables del capítulo 5.
- Sección "Sobredispersión y offset" (antes "..., offset y alternativas distribucionales"): derivación del offset paso a paso y fórmula de varianza marginal explícita con referencia cruzada, sin mención a especificaciones alternativas.

**Capítulo 7 — Inferencia Bayesiana (`07-Inferencia_Bayesiana.Rmd`)**
- Terminología alineada con el capítulo 6: "a priori débilmente informativas" → "previas no informativas", con referencias cruzadas a las secciones correspondientes del capítulo 6.
- Comentario del código Stan actualizado (`// Distribuciones a priori` → `// Distribuciones previas`).
- Los valores numéricos del código Stan (`normal(0,1)`, `cauchy(0,2.5)`) ya coincidían con los $\tau$ del capítulo 6 — sin cambios ahí.
- **Pendiente:** el capítulo solo muestra código ilustrativo (no ejecutado) — no hay salidas reales (resumen posterior, gráfico PPC, LOO/WAIC) porque `rstan`/`bayesplot`/`loo` no están instalados en este entorno. Ver "Próxima etapa" más abajo.

**Infraestructura del proyecto**
- `docs/.nojekyll` agregado y committeado: GitHub Pages intentaba procesar la salida de bookdown con Jekyll y fallaba (`Liquid Exception: Invalid Date` sobre el campo `date:` de `index.Rmd`); con este archivo, Pages sirve `docs/` tal cual, sin pasar por Jekyll.

### Convenciones establecidas (no revertir sin razón)

- **Terminología de previas:** siempre "distribución previa" / "distribuciones previas", nunca "a priori".
- **Sin binomial negativa:** el libro no usa ni menciona el modelo binomial negativo en ninguna sección — el autor no lo utiliza.
- **Bloques de código numerados ("Código X.Y"):** usar `::: {.exercise #cod-<id> name="Título"}` alrededor de un chunk, y referenciar con `` \@ref(exr:cod-<id>) ``. **Nunca** envolver así un chunk que tenga su propio `fig.cap` — LaTeX no permite floats dentro de un tcolorbox; para esos casos, dejar el chunk sin envolver para que genere su propia Figura.
- **Tablas multi-formato:** fijar `format` explícitamente en `knitr::kable()` (`"latex"` / `"html"` / `"pipe"` según `knitr::is_latex_output()` / `is_html_output()`) — omitirlo causa doble numeración con `kableExtra::kable_styling()`. Omitir `kable_styling()` por completo cuando el formato es `"pipe"` (Word): genera HTML crudo que rompe el render de `.docx`.
- **Ecuaciones multilínea:** nunca dejar una línea en blanco dentro de un bloque `$$...$$` (incluyendo `\begin{aligned}...\end{aligned}`) — rompe la compilación de PDF con "allowed only in math mode".
- **GitHub Pages:** `docs/.nojekyll` debe existir siempre para que Pages no procese la salida con Jekyll.

## Próxima Etapa: Datos y Ejemplos Reales

Los ejemplos de código de los capítulos 5 y 6 actualmente usan datos **simulados** (`set.seed()`, `rnorm()`, `rpois()`) para que los chunks sean ejecutables sin depender de microdatos censales reales. La siguiente fase debe migrar estos ejemplos a **datos reales y públicos** (agregados/open data de INE, DANE, DGEEC u otras fuentes oficiales ya mencionadas en este README), manteniendo siempre la restricción de no comprometer microdatos individuales.

Para el capítulo 7 en particular, esto implica instalar `rstan` (o `cmdstanr`) + Rtools, ajustar el modelo Poisson-lognormal real sobre esos datos, y reemplazar el código ilustrativo por chunks ejecutados con salidas genuinas (resumen posterior, $\hat R$/ESS reales, gráfico de verificación predictiva posterior, LOO/WAIC).

---

## Plan Original del Libro (referencia histórica)

> **Nota:** la numeración de capítulos de esta sección corresponde al plan inicial y **no coincide** con la numeración final en `_bookdown.yml`. Los checkboxes de `**Estado:**` y de las secciones de nivel superior (p. ej. `5.1`, `5.2`) de los capítulos abajo mapeados sí se actualizaron para reflejar el trabajo real hecho en esta sesión; los checkboxes de sub-secciones finas (p. ej. `1.1.1`) no se auditaron uno a uno y deben tomarse con cautela.

**Mapa Plan → Archivo real → Estado:**

| Cap. del plan | Archivo actual | Activo en build | Estado real |
|---|---|:---:|---|
| 1. Enfoque General | `01-intro.Rmd` | ✅ | No revisado en esta sesión |
| 2. Integración de Fuentes | `03-Integracion_Fuentes.Rmd` | ✅ | Revisado parcialmente (fix de bug LaTeX, sección de fuentes satelitales verificada) |
| 3. Imágenes Satelitales | `04-Imagenes_Satelitales.Rmd` | ❌ comentado | No iniciado / no revisado |
| 4. Insumos para Modelamiento | `05-InsumosModelamiento.Rmd` | ✅ | **En progreso** — contenido, tablas y gráficos completos; falta migrar a datos reales |
| 5. Modelo para Conteos | `06-Modelo_Conteos.Rmd` | ✅ | **Completado** (especificación teórica); no aplica "datos reales" — es un capítulo de teoría/ecuaciones, sin chunks de datos |
| 6. Inferencia Bayesiana | `07-Inferencia_Bayesiana.Rmd` | ✅ | **En progreso** — texto y código alineados con el cap. 5 del plan; código Stan aún ilustrativo, sin ejecutar (falta instalar `rstan` y correr con datos reales) |
| 7. Diagnóstico y Validación | `08-Diagnostico_Validacion.Rmd` | ❌ comentado | No revisado en esta sesión |
| 8. Calibración y Benchmarking | `09-Calibracion_Benchmarking.Rmd` | ❌ comentado | No revisado en esta sesión |
| 9. Conclusiones | `10-Conclusiones.Rmd` | ❌ comentado | No iniciado / no revisado |

## Estructura del Libro

### Capítulo 1: Enfoque General de los Modelos de Población {-}
**Estado:** [ ] Iniciado [ ] En progreso [ ] Completado

**Secciones:**
- [ ] 1.1 Producción de conteos censales
  - [ ] 1.1.1 Producción subnacional
  - [ ] 1.1.2 Desagregación por sexo y edad
  - [ ] 1.1.3 Uso en marcos muestrales
  - [ ] 1.1.4 Definición de dominios (4 niveles)
- [ ] 1.2 Indicadores de interés (con ecuaciones)
  - [ ] 1.2.1 Conteos poblacionales
  - [ ] 1.2.2 Tasas derivadas
  - [ ] 1.2.3 Estructuras etarias
- [ ] 1.3 Formulación del problema de cobertura, no respuesta y omisión

**Notas de contenido:**
- Incluir diagramas de jerarquía de dominios
- Tablas comparativas de contextos censales (BOL, PRY, COL)
- Ecuaciones: N_{i,s,e}, razones de sexo, índices de vejez


### Capítulo 2: Integración de Fuentes de Información {-}
**Estado:** [ ] Iniciado [ ] En progreso [ ] Completado

**Secciones:**
- [ ] 2.1 Principios de modelamiento
  - [ ] 2.1.1 Modelos de conteo
  - [ ] 2.1.2 Requerimientos de estimación subnacional
  - [ ] 2.1.3 Justificación del enfoque bayesiano
  - [ ] 2.1.4 Integración de múltiples fuentes
  - [ ] 2.1.5 Relación con Small Area Estimation (SAE)
- [ ] 2.2 Identificación de fuentes
  - [ ] 2.2.1 Medición de cobertura a nivel de segmento
  - [ ] 2.2.2 Preconteos y segmentación
  - [ ] 2.2.3 Registros administrativos (variables proxy)
  - [ ] 2.2.4 Fuentes satelitales
- [ ] 2.3 Variables explicativas
  - [ ] 2.3.1 Variables demográficas
  - [ ] 2.3.2 Variables socioeconómicas
  - [ ] 2.3.3 Variables espaciales

**Notas de contenido:**
- Diagrama de flujo: censo → preconteo → registros admin → satélites
- Tabla de disponibilidad de fuentes por país
- Marco teórico SAE en contexto bayesiano


### Capítulo 3: Preparación de Imágenes Satelitales {-}
**Estado:** [ ] Iniciado [ ] En progreso [ ] Completado

**Responsable:** Luis

**Secciones propuestas:**
- [ ] 3.1 Fuentes de datos satelitales (Landsat, Sentinel, MODIS)
- [ ] 3.2 Preprocesamiento y correcciones atmosféricas
- [ ] 3.3 Extracción de características (NDVI, índices espectrales)
- [ ] 3.4 Validación con datos de campo
- [ ] 3.5 Generación de capas para el modelo

**Notas:**
- Coordinar con Luis sobre contenido específico
- Incluir código Python (ejemplo: rasterio, geopandas)
- Casos de uso: densidad poblacional, cambio de uso de suelo


### Capítulo 4: Preparación de Insumos para Modelamiento {-}
**Estado:** [ ] Iniciado [x] En progreso [ ] Completado — *(`05-InsumosModelamiento.Rmd`; falta migrar los ejemplos a datos reales)*

**Secciones:**
- [x] 4.1 Estandarización de fuentes
  - [x] 4.1.1 Homologación de variables
  - [x] 4.1.2 Normalización de variables
- [x] 4.2 Evaluación de cobertura
  - [x] 4.2.1 Tasa de cobertura por segmento
  - [x] 4.2.2 Clasificación de segmentos
- [x] 4.3 Construcción de variable dependiente — *(vía clasificación de cobertura completa/parcial/nula, no como subsección separada "conteos agregados")*
  - [x] 4.3.1 Conteos agregados *(cubierto por la definición general de $Y_i$, no como apartado propio)*
  - [x] 4.3.2 Tasas poblacionales *(secciones "Densidad poblacional" y "Número promedio de personas por hogar")*
  - [ ] 4.3.3 Transformaciones *(ya cubierto en 4.1.2, no repetido aquí)*
  - [x] 4.3.4 Definición de población base
  - [ ] 4.3.5 Escalamiento *(no cubierto como apartado propio; relacionado con "Variable de exposición" / offset $V_i$)*
- [x] 4.4 Diagnóstico exploratorio — *(reescrito esta sesión: tablas `kableExtra` multi-formato, histograma y heatmap en `ggplot2`, sin exponer que los datos son simulados)*
  - [x] 4.4.1 Distribución de conteos
  - [x] 4.4.2 Outliers — *(gráfico de dispersión Pearson/Mahalanobis; sin tabla, a pedido; sin distancia de Cook)*
  - [x] 4.4.3 Relación entre variables — *(VIF en tabla + heatmap de correlación)*

**Notas de contenido:**
- Código R/Python: preparación de datos (dplyr, tidyr, pandas)
- Visualizaciones: histogramas, scatter plots, correlogramas
- Manejo de datos faltantes y valores extremos
- **Pendiente:** reemplazar datos simulados (`set.seed()`, `rnorm()`, `rpois()`) por datos reales/públicos — ver "Próxima Etapa" arriba.



### Capítulo 5: Modelo para Conteos Poblacionales {-}
**Estado:** [ ] Iniciado [ ] En progreso [x] Completado — *(`06-Modelo_Conteos.Rmd`; capítulo de especificación teórica, no requiere datos reales)*

**Secciones:**
- [x] 5.1 Modelo Poisson condicional/bayesiano
  - [x] 5.1.1 Definición formal
  - [x] 5.1.2 Función de verosimilitud — *(derivación completa paso a paso, incluida la log-verosimilitud expandida)*
  - [x] 5.1.3 Distribuciones previas ~~(débilmente informativas)~~ → **no informativas** — *(reparametrizadas con $\tau_\beta^2,\tau_U^2,\tau_\sigma$ genéricos)*
  - [x] 5.1.4 Distribución posterior — *(reescrita esta sesión: derivación completa desde el teorema de Bayes)*
  - [x] 5.1.5 Interpretación de parámetros — *(reescrita con lenguaje accesible y referencias cruzadas)*
- [x] 5.2 Componentes del modelo
  - [x] 5.2.1 Efectos fijos
  - [x] 5.2.2 Efectos aleatorios
  - [x] 5.2.3 Interacciones
  - [x] 5.2.4 Otros (sobredispersión, offset) — *(sin "alternativas distribucionales": no se comparan otras familias, ver convenciones)*

**Notas de contenido:**
- Ecuaciones formales con notación clara
- ~~Justificación de Poisson vs alternativas (Negative Binomial, etc.)~~ — **el libro no usa ni compara con binomial negativa** (decisión explícita del autor)
- Especificación de previas no informativas (normal y Cauchy⁺)
- Interpretación de coeficientes en escala original y log


### Capítulo 6: Inferencia Bayesiana e Implementación Computacional {-}
**Estado:** [ ] Iniciado [x] En progreso [ ] Completado — *(`07-Inferencia_Bayesiana.Rmd`; falta ejecutar con datos y modelo reales)*

**Secciones:**
- [x] 6.1 Métodos de simulación
  - [x] Cadenas de Markov Monte Carlo (MCMC)
  - [x] Hamiltonian Monte Carlo y algoritmo NUTS
  - [x] Implementación en Stan *(código presente, pero aún no ejecutado — ver pendiente abajo)*
  - [x] Configuración de cadenas, muestras e iteraciones
  - [x] Paralelización y eficiencia computacional
- [x] 6.2 Distribución posterior y estimaciones puntuales
  - [x] Media, mediana e intervalos de credibilidad
  - [x] Estimaciones a nivel de segmento censal
  - [x] Agregación a niveles superiores

**Notas de contenido:**
- Código Stan: sintaxis básica, bloques (data, parameters, model)
- Código R: interfaz con rstan, cmdstanr
- Ejemplo completo paso a paso
- Interpretación de cadenas y muestras
- **Pendiente:** instalar `rstan`/`bayesplot`/`loo` + Rtools y ejecutar el modelo sobre datos reales para obtener salidas genuinas (resumen posterior, $\hat R$/ESS, gráfico PPC, LOO/WAIC) — ver "Próxima Etapa" arriba.


### Capítulo 7: Diagnóstico y Validación del Modelo {-}
**Estado:** [ ] Iniciado [ ] En progreso [ ] Completado

**Secciones:**
- [ ] 7.1 Diagnóstico de convergencia MCMC
  - [ ] Estadístico R-hat
  - [ ] Tamaño efectivo de muestra (ESS)
  - [ ] Trace plots y autocorrelación
- [ ] 7.2 Validación predictiva posterior
  - [ ] Posterior predictive checks (PPC)
  - [ ] Distribución de residuos bayesianos
  - [ ] Comparación con conteos observados
- [ ] 7.3 Selección y comparación de modelos
  - [ ] Criterio Leave-One-Out (LOO-CV)
  - [ ] Widely Applicable Information Criterion (WAIC)
  - [ ] Criterio de elección del modelo final
- [ ] 7.4 Validación externa
  - [ ] Consistencia con proyecciones demográficas
  - [ ] Comparación con registros administrativos
  - [ ] Evaluación de coherencia geoespacial

**Notas de contenido:**
- Interpretación de diagnósticos: cuándo aceptar/rechazar un modelo
- Código R: bayesplot, loo, arviz equivalentes
- Visualizaciones diagnósticas
- Tablas de métricas de bondad de ajuste

### Capítulo 8: Calibración y Benchmarking Subnacional {-}
**Estado:** [ ] Iniciado [ ] En progreso [ ] Completado

**Secciones:**
- [ ] 8.1 Benchmarking con proyecciones poblacionales
  - [ ] Necesidad de coherencia entre niveles geográficos
  - [ ] Restricciones de consistencia jerárquica
  - [ ] Relación entre estimaciones locales y totales conocidos
- [ ] 8.2 Métodos de benchmarking
  - [ ] Benchmarking proporcional
  - [ ] Benchmarking por razones de ajuste
  - [ ] Benchmarking aditivo con restricciones de suma
  - [ ] Aplicación práctica a distintos niveles geográficos
- [ ] 8.3 Evaluación del impacto del benchmarking
  - [ ] 8.3.1 Cambio en estimaciones puntuales
  - [ ] 8.3.2 Intervalos de credibilidad post-calibración

**Notas de contenido:**
- Código: algoritmos de calibración (proporcional, aditivo)
- Ejemplos con datos reales de América Latina
- Impacto en medidas de incertidumbre

---

### Capítulo 9: Conclusiones y Recomendaciones Institucionales {-}
**Estado:** [ ] Iniciado [ ] En progreso [ ] Completado

**Secciones:**
- [ ] Principales hallazgos metodológicos
- [ ] Recomendaciones para organismos nacionales de estadística
- [ ] Rol de organismos internacionales en transferencia metodológica
- [ ] Limitaciones del enfoque y condiciones para su aplicación

**Notas de contenido:**
- Síntesis de decisiones metodológicas
- Roadmap de implementación institucional
- Desafíos tecnológicos y de capacidad

---

## Flujo de Trabajo Recomendado

### Fase 1: Escritura Conceptual (Capítulos 1-3)
1. Establecer marcos conceptuales y metodológicos
2. Integrar contexto regional (ALC)
3. Definir notación y convenciones

### Fase 2: Escritura Técnica (Capítulos 4-6)
1. Detallar preparación de datos
2. Especificar modelo bayesiano
3. Implementar código reproducible

### Fase 3: Validación y Aplicación (Capítulos 7-8)
1. Diagnósticos y validación
2. Calibración y coherencia
3. Casos de estudio reales

### Fase 4: Síntesis (Capítulo 9 + Apéndices)
1. Resumen de hallazgos
2. Recomendaciones prácticas
3. Recursos complementarios

---

## Pautas de Escritura

### Estructura de Cada Capítulo
```
# Capítulo X: Título

## Introducción
- Contexto y motivación
- Objetivos del capítulo
- Conexión con capítulos anteriores

## Secciones Principales
- Desarrollo teórico con ecuaciones
- Ejemplos prácticos
- Código reproducible

## Resumen y Conclusiones
- Puntos clave
- Transición al siguiente capítulo

## Referencias (al final del libro)
```

### Elementos Requeridos

**Ecuaciones:**
- Numeradas y referenciables
- Uso de LaTeX/MathML
- Explicación de cada componente

**Código:**
- Lenguajes: R (preferido), Python, Stan
- Bloques con sintaxis highlighting
- Comentarios en español

**Figuras:**
- Diagramas conceptuales
- Gráficos de diagnóstico
- Mapas de casos subnacionales

**Tablas:**
- Resúmenes de fuentes de datos
- Métricas de desempeño
- Comparativas de métodos

---

## Herramientas y Tecnología

### Escritura y Compilación
- **Editor:** Markdown/LaTeX
- **Control de versiones:** Git (opcional)
- **Compilación:** Pandoc → PDF / rmarkdown / bookdown

### Análisis y Código
- **Lenguaje estadístico:** R (tidyverse, ggplot2, rstan)
- **Modelamiento:** Stan (probabilistic programming)
- **Validación:** bayesplot, loo, tidybayes

### Datos
- Usar datos sintéticos o públicos de institutos censales
- Ejemplos: Colombia (DANE), Bolivia (INE), Paraguay (DGEEC)

---

## Cronograma Sugerido

| Fase | Capítulos | Semanas | Hitos |
|------|-----------|---------|-------|
| I | 1-3 | 2-3 | Conceptos claros, estructura |
| II | 4-6 | 4-5 | Código reproducible, ecuaciones |
| III | 7-8 | 3-4 | Validación completa, ejemplos |
| IV | 9 + Apéndices | 2-3 | Revisión final, referencias |

---

## Checklist por Capítulo

Para cada capítulo completado:

- [ ] Contenido teórico escrito y revisado
- [ ] Ecuaciones incluidas y numeradas
- [ ] Código funcional (Stan/R)
- [ ] Ejemplos numéricos con resultados
- [ ] Figuras y tablas generadas
- [ ] Referencias bibliográficas añadidas
- [ ] Conexión con capítulos adyacentes verificada
- [ ] Revisión técnica completada


## Contacto y Notas

- **Enfoque:** Práctico pero riguroso, orientado a aplicación institucional
- **Audiencia principal:** Organismos nacionales de estadística
- **Diferenciadores:** Énfasis en América Latina, métodos bayesianos modernos, reproducibilidad

