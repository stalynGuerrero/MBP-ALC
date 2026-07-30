# Integración de Fuentes de Información {#cap-integracion}

La estimación de conteos poblacionales en unidades territoriales pequeñas requiere combinar información proveniente de diversas fuentes que describen, de manera complementaria, la distribución espacial de la población. Cuando el operativo censal presenta omisiones de cobertura, segmentos no observados o limitaciones para representar adecuadamente la heterogeneidad territorial, los datos censales por sí solos resultan insuficientes para reconstruir la distribución completa de la población.

Los avances recientes en disponibilidad de imágenes satelitales, productos derivados de sensores remotos, registros geoespaciales, modelos digitales del terreno, infraestructura, redes viales y otras fuentes de información auxiliar han ampliado significativamente la capacidad para caracterizar el territorio y explicar los patrones de asentamiento humano. Integrar estas fuentes dentro de un marco estadístico coherente permite aprovechar la información contenida en cada una de ellas para mejorar la predicción de los conteos poblacionales.

Este capítulo presenta los fundamentos conceptuales de la integración de fuentes de información en el contexto de los modelos bayesianos de población. Se describen las principales fuentes de información disponibles para América Latina y el Caribe, sus características, cobertura, resolución, calidad y principales limitaciones. Asimismo, se presentan los criterios para la construcción, transformación y selección de variables auxiliares derivadas de estas fuentes, así como los principios para su integración dentro de un marco estadístico coherente. Estas variables constituyen la base de los modelos utilizados para predecir los conteos poblacionales en unidades territoriales de interés y complementar la información proveniente de los censos de población.


## Principios de modelamiento

Los modelos estadísticos empleados para la estimación de conteos poblacionales relacionan los conteos observados con un conjunto de covariables auxiliares, con el fin de explicar las diferencias en magnitud poblacional entre unidades de análisis y predecir los conteos en aquellas donde la información censal es incompleta o no está disponible.

El desarrollo de estos modelos debe satisfacer cuatro principios fundamentales: respetar la naturaleza discreta y no negativa de los conteos poblacionales mediante distribuciones de probabilidad apropiadas para este tipo de variable respuesta; incorporar de forma coherente información auxiliar proveniente de fuentes heterogéneas en resolución y calidad; producir estimaciones consistentes con los totales poblacionales disponibles y coherentes entre niveles de agregación territorial; y cuantificar la incertidumbre de las predicciones de forma que respalde su uso en procesos de toma de decisiones.

Estos principios constituyen la base para la selección de la familia distribucional, la especificación de la estructura del predictor y la adopción del marco inferencial bayesiano que se desarrolla en los capítulos siguientes.

### Modelos de conteo {#modelos-de-conteo}

Los conteos poblacionales son variables aleatorias discretas no negativas. Esta naturaleza fundamental distingue el problema de estimación subnacional de los problemas de regresión con variables continuas y exige el uso de modelos de probabilidad apropiados para datos de conteo.

La distribución de Poisson constituye el punto de partida canónico para el modelamiento de conteos. Si $Y_i$ denota el conteo observado en el segmento $i$, el modelo de Poisson establece:

$$
Y_i \mid \lambda_i \sim \text{Poisson}(\lambda_i)
$$

donde $\lambda_i > 0$ es el parámetro de intensidad, que representa simultáneamente la media y la varianza de la distribución. La función de probabilidad es:

$$
P(Y_i = y \mid \lambda_i) = \frac{e^{-\lambda_i}\, \lambda_i^y}{y!}, \qquad y = 0, 1, 2, \ldots
$$

La parametrización log-lineal del modelo relaciona el logaritmo de la intensidad con un predictor lineal de covariables:

$$
\log(\lambda_i) = \mathbf{x}_i^{\top} \boldsymbol{\beta} + \mathbf{z}_i^{\top} \boldsymbol{\gamma}
$$

donde $\mathbf{x}_i$ es el vector de covariables auxiliares del segmento $i$ con coeficientes de efectos fijos $\boldsymbol{\beta}$, y $\mathbf{z}_i^{\top}\boldsymbol{\gamma}$ es el efecto aleatorio territorial que captura la variabilidad no explicada por las covariables, con $\gamma_j \sim \mathcal{N}(0, \sigma_U^2)$ para cada unidad territorial $j$. Esta notación —$\boldsymbol{\beta}$, $\mathbf{z}_i^{\top}\boldsymbol{\gamma}$, $\sigma_U$— es la que se emplea en la especificación completa del modelo de conteos poblacionales del Capítulo \@ref(cap-conteos).

Un supuesto fundamental del modelo de Poisson es la equidispersión: $\mathbb{E}[Y_i \mid \lambda_i] = \text{Var}(Y_i \mid \lambda_i) = \lambda_i$. En la práctica, los conteos poblacionales suelen exhibir sobredispersión, es decir, una varianza observada mayor a la media. Este fenómeno puede originarse en heterogeneidad no observada entre segmentos, clustering espacial o errores de especificación del predictor.

Para tratar la sobredispersión sin abandonar la familia Poisson, se introduce un multiplicador aleatorio en la intensidad: $\lambda_i = \mu_i \cdot \exp(\varepsilon_i)$ con $\varepsilon_i \sim \mathcal{N}(0, \sigma^2)$. La distribución marginal de $Y_i$ ya no tiene forma cerrada, pero $\exp(\varepsilon_i)$ conserva una interpretación directa como factor multiplicativo que amplifica o reduce la intensidad esperada en cada segmento, capturando la variabilidad extra-Poisson no explicada por las covariables ni por el efecto aleatorio territorial. Esta es la especificación —denominada Poisson-lognormal— adoptada en el modelo de conteos poblacionales, donde $\mu_i$ se especifica precisamente como $\mathbf{x}_i^{\top}\boldsymbol{\beta} + \mathbf{z}_i^{\top}\boldsymbol{\gamma}$ y $\varepsilon_i$ se convierte en la densidad latente log-normal.

En contextos de modelamiento jerárquico, la necesidad de este componente adicional debe fundamentarse en el diagnóstico de sobredispersión: una especificación más rica de covariables puede reducir la sobredispersión aparente al explicar parte de la heterogeneidad entre segmentos, y solo el remanente no explicado justifica la inclusión del término log-normal.

### Requerimientos de estimación subnacional

La estimación de conteos en niveles territoriales pequeños impone requerimientos adicionales que van más allá de la simple elección de una distribución de probabilidad. Estos requerimientos se derivan de la naturaleza jerárquica del problema y de las condiciones operativas en las que se producen los datos.

**Coherencia jerárquica.** Las estimaciones en niveles inferiores deben ser consistentes con los totales conocidos o estimados en niveles superiores. Si $\hat{N}_k^{(3)}$ denota la estimación del municipio $k$ y $\hat{N}_j^{(2)}$ la del departamento $j$, la coherencia exige:

$$
\hat{N}_j^{(2)} = \sum_{k \,:\, k \subset j} \hat{N}_k^{(3)}
$$

Esta restricción de coherencia entre niveles es fundamental para garantizar la consistencia interna del sistema estadístico y constituye un criterio de validación esencial de cualquier modelo de estimación subnacional.

**Estimación en unidades con cobertura incompleta.** La estimación de conteos poblacionales solo es necesaria en aquellas unidades territoriales donde el operativo censal no logró observar la totalidad de la población o donde los conteos disponibles presentan deficiencias de cobertura o calidad. En estos casos, la información observada resulta insuficiente para determinar directamente el número de habitantes, por lo que es necesario complementar los datos censales mediante información auxiliar proveniente de múltiples fuentes. El modelo estadístico combina ambas fuentes de información para predecir los conteos poblacionales faltantes y reconstruir una distribución poblacional consistente con la información disponible.

**Propagación de incertidumbre.** Toda predicción de conteos poblacionales debe acompañarse de una medida de incertidumbre que refleje la información disponible y la variabilidad asociada al proceso de estimación. La incertidumbre depende, entre otros factores, de la cantidad y calidad de la información observada, de la capacidad explicativa de las covariables y de la incertidumbre inherente al modelo estadístico. Su cuantificación es indispensable para evaluar la confiabilidad de las predicciones y apoyar su utilización en la producción de estadísticas oficiales y en la toma de decisiones.

### Justificación del enfoque bayesiano

La estimación de conteos poblacionales en unidades territoriales con cobertura censal incompleta requiere un marco inferencial capaz de integrar información proveniente de múltiples fuentes, representar explícitamente la incertidumbre asociada a las predicciones y modelar la heterogeneidad inherente a la distribución de la población. El enfoque bayesiano proporciona una formulación natural para abordar estos desafíos, al combinar la evidencia observada con información previa dentro de un modelo probabilístico coherente. Esta formulación permite incorporar estructuras jerárquicas, compartir información entre unidades territoriales relacionadas y obtener distribuciones posteriores para todos los parámetros y cantidades de interés, facilitando tanto la predicción de conteos poblacionales como la cuantificación de la incertidumbre asociada a dichas predicciones. Estas características convierten al enfoque bayesiano en un marco particularmente adecuado para el desarrollo de los modelos de población presentados en este libro.

**Representación explícita de la incertidumbre.** En el paradigma bayesiano, todos los parámetros desconocidos se tratan como variables aleatorias cuya incertidumbre se cuantifica mediante distribuciones de probabilidad. En el modelo de conteos poblacionales desarrollado en este libro, el vector de parámetros estructurales es $\boldsymbol{\theta} = \{\boldsymbol{\beta}, \boldsymbol{\gamma}, \sigma, \sigma_U\}$: $\boldsymbol{\beta}$ son los coeficientes de efectos fijos asociados a las covariables auxiliares, $\boldsymbol{\gamma}$ son los efectos aleatorios territoriales, $\sigma$ es la escala de la densidad poblacional latente y $\sigma_U$ es el hiperparámetro que controla la variabilidad de $\boldsymbol{\gamma}$ entre unidades territoriales. La distribución posterior $p(\boldsymbol{\theta} \mid \mathbf{Y})$ encapsula el estado de conocimiento sobre estos parámetros —y, a través de ellos, sobre la población en cada segmento— dado el vector de conteos observados $\mathbf{Y}$:

$$
p(\boldsymbol{\theta} \mid \mathbf{Y}) \propto p(\mathbf{Y} \mid \boldsymbol{\theta})\, p(\boldsymbol{\theta})
$$

Esta representación permite calcular intervalos de credibilidad, probabilidades de excedencia y cualquier otra cantidad de interés derivada de la distribución posterior.

**Incorporación de información previa.** El enfoque bayesiano permite incorporar conocimiento previo mediante distribuciones a priori asignadas a los parámetros del modelo. Estas distribuciones pueden representar restricciones derivadas del problema de estudio o reflejar información disponible antes de observar los datos. La combinación de esta información con la evidencia aportada por los datos da lugar a la distribución posterior, que constituye la base de la inferencia bayesiana.


**Modelamiento jerárquico.** Los modelos bayesianos permiten organizar los distintos componentes del problema mediante estructuras jerárquicas, facilitando la integración de información proveniente de múltiples fuentes y el intercambio de información entre unidades territoriales. Esta característica produce estimaciones más estables en aquellas unidades con información limitada, sin perder la capacidad de representar la heterogeneidad observada entre territorios.

En modelos jerárquicos de alta complejidad, la distribución posterior rara vez admite una expresión analítica, por lo que su aproximación requiere métodos numéricos de simulación. En este libro, la inferencia bayesiana se realiza mediante técnicas de Monte Carlo por cadenas de Markov (MCMC) [@Tierney1994], utilizando el algoritmo Hamiltonian Monte Carlo (HMC) y el muestreador No-U-Turn (NUTS) implementados en Stan [@Duane1987; @Neal2011; @Betancourt2017; @Hoffman2014; @Carpenter2017]. Los fundamentos de estos algoritmos y su aplicación al modelo propuesto se presentan en el Capítulo \@ref(cap-conteos).


### Integración de múltiples fuentes {#integracion-multiples-fuentes}

Uno de los principales retos en la modelación de población consiste en aprovechar la información disponible en fuentes de naturaleza heterogénea. Además de los conteos provenientes del censo, actualmente existe una amplia variedad de fuentes auxiliares que describen características demográficas, ambientales, físicas y socioeconómicas del territorio, como registros administrativos, imágenes satelitales, productos de observación de la Tierra, cartografía temática e infraestructura geoespacial [@CEPAL2023]. Aunque estas fuentes no constituyen mediciones directas de la población, contienen información que puede utilizarse para explicar su distribución y mejorar la capacidad predictiva de los modelos.

El enfoque bayesiano proporciona un marco probabilístico coherente para integrar esta información dentro de un único modelo [@BryantZhang2018]. En la metodología desarrollada en este libro, la integración se realiza principalmente mediante la incorporación de variables auxiliares derivadas de las distintas fuentes en el vector de covariables $\mathbf{x}_i = (x_{i1}, x_{i2}, \ldots, x_{ip})^{\top}$ del predictor log-lineal $\log(\lambda_i) = \mathbf{x}_i^{\top}\boldsymbol{\beta} + \mathbf{z}_i^{\top}\boldsymbol{\gamma}$ presentado en la Sección \@ref(modelos-de-conteo). Cada componente de $\mathbf{x}_i$ puede provenir de una fuente distinta, y de esta forma la información contenida en múltiples fuentes contribuye conjuntamente a explicar la intensidad poblacional y a mejorar las predicciones en las unidades donde la cobertura censal es incompleta.

La integración de fuentes requiere un proceso previo de armonización para garantizar que las variables auxiliares sean comparables entre sí y consistentes con la unidad territorial de análisis. Este proceso comprende la transformación de escalas espaciales, la agregación o desagregación de información, el tratamiento de valores faltantes, la estandarización de definiciones y la evaluación de la calidad de cada fuente. Estos aspectos se desarrollan en las secciones siguientes del capítulo.

En la literatura también existen modelos que integran múltiples mediciones directas de la población mediante funciones de verosimilitud específicas para cada fuente de información [@BryantGraham2013; @Wheldon2013]. Aunque este enfoque resulta apropiado cuando se dispone de varias observaciones comparables del mismo fenómeno, en este libro se adopta una estrategia diferente: utilizar una única variable respuesta —el conteo poblacional observado— y complementar su información mediante covariables derivadas de múltiples fuentes auxiliares, en la línea de los modelos de área de la Estimación en Áreas Pequeñas [@Rao2015; @Mercer2015]. Esta formulación permite aprovechar la riqueza de la información disponible sin requerir que todas las fuentes midan directamente la población bajo un mismo esquema de observación.


### Relación con *Small Area Estimation* (SAE)

Los modelos presentados en este libro guardan una estrecha relación conceptual con la metodología de Estimación en Áreas Pequeñas (*Small Area Estimation*, SAE), en cuanto ambos buscan producir estimaciones confiables para unidades territoriales donde la información disponible es insuficiente para responder directamente al problema de interés [@Rao2015]. En ambos enfoques, las variables auxiliares desempeñan un papel fundamental al complementar la información observada mediante modelos estadísticos que permiten mejorar la precisión de las estimaciones.

No obstante, el problema abordado en este libro difiere del planteamiento clásico de SAE. En los modelos tradicionales, el objetivo consiste en estimar parámetros poblacionales —como medias, proporciones o totales— a partir de encuestas probabilísticas cuyos tamaños muestrales son insuficientes en determinados dominios de estudio. En consecuencia, el modelo se construye sobre estimadores directos o sobre observaciones individuales provenientes del diseño muestral, incorporando explícitamente el error de muestreo como parte de la especificación estadística.

En contraste, los modelos bayesianos de población desarrollados en este libro utilizan como variable respuesta el conteo poblacional observado durante el operativo censal y recurren a fuentes auxiliares para predecir la población únicamente en aquellas unidades territoriales donde la cobertura censal es incompleta o la información disponible resulta insuficiente. En este contexto, la incertidumbre proviene principalmente del modelo de predicción y de la calidad de las fuentes de información utilizadas, más que del error de muestreo asociado a un diseño probabilístico.

Desde el punto de vista metodológico, ambos enfoques comparten el uso de modelos jerárquicos, efectos aleatorios y variables auxiliares para combinar información de diferentes orígenes. Sin embargo, difieren en la naturaleza de la variable de interés, en el mecanismo que genera la incertidumbre y en la formulación del modelo estadístico. Mientras que la metodología SAE clásica se desarrolla principalmente para parámetros derivados de encuestas, el enfoque presentado en este libro se orienta a la reconstrucción y predicción de conteos poblacionales mediante modelos bayesianos de conteo que integran información proveniente de múltiples fuentes.


## Identificación de fuentes {#identificacion-fuentes}

La calidad de los modelos bayesianos de estimación subnacional depende críticamente de la disponibilidad y pertinencia de las fuentes de información auxiliar incorporadas. En América Latina y el Caribe, el conjunto de fuentes disponibles varía considerablemente entre países, pero puede organizarse en cuatro categorías principales: medición de cobertura censal, preconteos operativos, registros administrativos y fuentes satelitales.

### Medición de cobertura a nivel de segmento {#medicion-cobertura}

La cobertura censal constituye el primer aspecto que debe evaluarse antes de emprender cualquier proceso de estimación poblacional subnacional. La cobertura representa la proporción de la población real que fue efectivamente enumerada durante el operativo censal, mientras que su complemento, la tasa de omisión censal, cuantifica la fracción de la población que no fue observada.

Sea $N_i$ la población verdadera del segmento $i$ y $Y_i^{(C)}$ el conteo registrado durante el censo. La tasa de cobertura del segmento se define como

$$
c_i=\frac{Y_i^{(C)}}{N_i},
$$

mientras que la tasa de omisión correspondiente es

$$
\omega_i=1-c_i.
$$

Dado que la población verdadera $N_i$ no es directamente observable, la cobertura no puede calcularse de manera exacta y debe estimarse a partir de información independiente del operativo censal.

En la práctica, la evaluación de la cobertura se basa principalmente en tres tipos de fuentes. La primera corresponde a las encuestas postcensales de cobertura, diseñadas específicamente para medir la omisión mediante un operativo de campo independiente. La segunda comprende los métodos de conciliación demográfica, que contrastan los resultados censales con estimaciones derivadas de estadísticas vitales y proyecciones de población. La tercera utiliza técnicas de captura-recaptura que combinan la información del censo con registros administrativos para estimar la población no observada.

La cobertura censal presenta una marcada heterogeneidad territorial. En general, los menores niveles de cobertura se concentran en áreas rurales dispersas, asentamientos informales, territorios indígenas, zonas de difícil acceso y sectores urbanos con elevada movilidad residencial. Estas diferencias reflejan las condiciones operativas del levantamiento censal y constituyen uno de los principales factores que justifican la incorporación de información auxiliar en los modelos de estimación poblacional.

En la metodología propuesta, la cobertura de cada segmento se aproxima mediante un estimador

$$
\hat{c}_i=\frac{Y_i^{(C)}}{\widehat{N}_i},
$$

donde $\widehat{N}_i$ representa una referencia externa obtenida a partir de una encuesta postcensal, una conciliación demográfica, un procedimiento de captura-recaptura o un preconteo operativo ajustado —este último se retoma en la Sección \@ref(preconteos-segmentacion)—. **Nota de notación.** A partir de aquí, el acento ancho $\widehat{N}_i$ (comando LaTeX `\widehat`) se reserva exclusivamente para referencias poblacionales externas al modelo, como la empleada en este estimador de cobertura. El acento angosto $\hat{N}$ (`\hat`), utilizado más arriba en esta misma sección para la coherencia jerárquica y retomado en los Capítulos \@ref(cap-conteos), \@ref(cap-diagnostico) y \@ref(cap-calibracion), denota en cambio la propia estimación agregada del modelo bayesiano —la cantidad que en el Capítulo \@ref(cap-calibracion) se calibra frente a un total de control externo—. Ambas cantidades son conceptualmente distintas —una es insumo para evaluar cobertura, la otra es un resultado del modelo— y no deben confundirse pese a la similitud visual del símbolo. Este estimador se utiliza para clasificar los segmentos según su nivel de cobertura y definir el tratamiento que recibirán en las etapas posteriores del modelamiento: los segmentos con cobertura completa ($\hat{c}_i=1$) utilizan directamente el conteo censal; los segmentos con cobertura parcial ($0<\hat{c}_i<1$) combinan el conteo observado con la predicción del modelo para la población omitida; y los segmentos con cobertura nula ($\hat{c}_i=0$) se estiman íntegramente mediante las covariables auxiliares y la estructura jerárquica del modelo. Esta clasificación se formaliza en la Sección \@ref(evaluacion-cobertura) del Capítulo \@ref(cap-insumos).

Es importante señalar que la metodología no busca estimar ni corregir explícitamente la omisión censal dentro del modelo bayesiano. La evaluación de la cobertura constituye una etapa previa cuyo propósito es determinar la calidad de la información disponible y establecer cómo participa cada segmento en el proceso de estimación. 


### Preconteos y segmentación {#preconteos-segmentacion}

Los preconteos operativos constituyen una de las fuentes auxiliares más directamente vinculadas a la estimación de la población en segmentos censales. Estas operaciones, realizadas durante la fase de actualización cartográfica previa al levantamiento censal, producen información sobre el número aproximado de viviendas o estructuras habitacionales presentes en cada unidad operativa.

La segmentación censal es el proceso mediante el cual el territorio nacional se divide en unidades operativas de trabajo, denominadas segmentos o áreas de enumeración. Cada segmento es asignado a un censista y está diseñado para ser enumerable en el tiempo operativo disponible. Los criterios de segmentación varían entre países: algunos utilizan como criterio el número esperado de viviendas, otros priorizan continuidad espacial o accesibilidad geográfica.

Sea $V_i$ el preconteo de viviendas o estructuras habitacionales registrado en el segmento $i$ durante la actualización cartográfica. El preconteo cumple un papel operativo central en la planeación del propio operativo censal: permite dimensionar la carga de trabajo de cada censista, estimar el número de enumeradores y el tiempo requerido para cubrir el territorio, anticipar necesidades presupuestarias y logísticas, y detectar segmentos cuyo crecimiento habitacional exige una resegmentación antes del levantamiento. La segmentación, a su vez, garantiza que esta planeación cubra la totalidad del territorio nacional sin traslapes ni vacíos entre unidades operativas.

El preconteo es especialmente valioso en contextos donde el operativo censal no logró cobertura completa, dado que provee una señal anticipada sobre la magnitud poblacional esperada que es independiente del proceso de enumeración —la misma propiedad que permite emplearlo como referencia externa en el estimador de cobertura de la Sección \@ref(medicion-cobertura)—. Su principal limitación es la distancia temporal entre la actualización cartográfica y el momento censal: en contextos con crecimiento urbano acelerado, los preconteos pueden quedar desactualizados rápidamente.

### Registros administrativos {#registros-administrativos}

Los registros administrativos son bases de datos generadas por entidades gubernamentales como resultado de sus funciones institucionales. A diferencia de los censos, no tienen por objetivo la medición estadística de la población, sino la gestión de servicios, beneficios o trámites administrativos. Sin embargo, en la medida en que su cobertura es razonablemente alta y su definición territorial compatible con los segmentos censales, pueden utilizarse como variables proxy de la magnitud poblacional [@Rao2015].

Entre los registros administrativos más utilizados en modelos de estimación subnacional en América Latina y el Caribe se encuentran:

**Registros de afiliación a sistemas de salud y seguridad social.** Los sistemas de salud pública o los registros de afiliación a la seguridad social contienen información sobre personas que acceden regularmente a servicios institucionales. Su cobertura depende del grado de formalidad laboral y del acceso efectivo a los servicios en cada territorio.

**Registros o consumo de servicios públicos.** Los registros de conexiones o consumo de electricidad, agua potable o gas domiciliario, administrados por las empresas prestadoras de servicios, proporcionan un conteo de usuarios activos o viviendas conectadas por unidad territorial. Su cobertura está condicionada por el grado de formalización de la vivienda y por la extensión de las redes de distribución, por lo que puede subestimar la población en asentamientos informales o en zonas rurales dispersas sin conexión a la red.

**Registros de beneficiarios de programas sociales.** Los padrones de beneficiarios de programas de transferencias condicionadas u otros programas sociales focalizados proporcionan información sobre hogares en situación de vulnerabilidad. Aunque su cobertura no es universal, pueden ser especialmente informativos en áreas con alta concentración de población en condición de pobreza.


### Fuentes satelitales {#fuentes-satelitales}

Las imágenes satelitales y los productos de percepción remota han ampliado considerablemente el conjunto de covariables disponibles para la estimación poblacional subnacional. Su principal ventaja es la cobertura territorial universal, la continuidad temporal y la independencia respecto a los sistemas estadísticos institucionales.

Las fuentes satelitales más utilizadas en estimación poblacional pueden agruparse en las siguientes categorías:

**Luminosidad nocturna.** Los datos de radiancia nocturna capturados por sensores satelitales, como el producto VIIRS-DNB de la NOAA, permiten identificar áreas con presencia de iluminación artificial. La intensidad lumínica nocturna está correlacionada con la actividad económica y la densidad de asentamientos humanos permanentes.

**Área construida y cobertura urbana.** Los productos de clasificación de uso del suelo derivados de imágenes ópticas como Sentinel-2 o Landsat permiten estimar la proporción de área construida dentro de cada segmento. El producto Global Human Settlement Layer (GHSL) de la Comisión Europea ofrece estimaciones de área construida a resolución de 100 metros con cobertura global.

**Índice de vegetación de diferencia normalizada (NDVI).** El NDVI mide la densidad y vitalidad de la vegetación a partir de la reflectancia en bandas del infrarrojo cercano y el rojo visible. Valores bajos de NDVI en áreas no áridas generalmente indican presencia de infraestructura construida y asentamientos urbanos, mientras que valores altos corresponden a áreas con cobertura vegetal densa.

**Temperatura superficial terrestre (LST).** Las islas de calor urbano, reflejadas en valores elevados de temperatura superficial, constituyen un indicador indirecto de densidad de infraestructura y actividad humana.

**Modelos digitales de elevación.** La topografía del terreno condiciona la distribución espacial de la población. Los modelos de elevación digital como SRTM o ALOS permiten derivar variables como altitud media, pendiente y orientación del terreno, que están correlacionadas con la densidad y distribución de los asentamientos humanos.

La integración de covariables satelitales en el modelo requiere procesar las imágenes hasta el nivel del segmento censal, lo que implica operaciones de reproyección, remuestreo y estadísticas zonales. La resolución espacial de las imágenes debe ser compatible con el tamaño de los segmentos: resoluciones muy gruesas pueden introducir errores de asignación en segmentos pequeños, mientras que resoluciones muy finas pueden aumentar el costo computacional sin beneficio estadístico apreciable.

En la práctica, esta información satelital se extrae y se procesa a través de plataformas de computación geoespacial en la nube, como Google Earth Engine [@Gorelick2017], que alojan los catálogos de VIIRS-DNB, Sentinel-2, Landsat, GHSL y los modelos digitales de elevación descritos arriba, y permiten calcular directamente las estadísticas zonales por segmento sin necesidad de descargar las imágenes completas.

## Variables explicativas

Mientras la Sección \@ref(identificacion-fuentes) identificó el origen institucional u operativo de cada fuente auxiliar, esta sección describe el paso siguiente del proceso: cómo esas fuentes se transforman en las covariables efectivamente incorporadas al predictor $\mathbf{x}_i$ del modelo. La calidad predictiva del modelo de estimación subnacional depende directamente de esta selección y construcción. Las covariables resultantes pueden organizarse en dos grandes grupos según su naturaleza conceptual: variables socioeconómicas y variables espaciales. Indicadores demográficos como la estructura por sexo y edad, la razón de masculinidad o el tamaño medio del hogar quedan excluidos de este conjunto: al derivarse de la propia tabulación censal por sexo y edad, no están disponibles de forma independiente en los segmentos con cobertura incompleta —que son precisamente aquellos donde se necesita una variable explicativa— y por tanto no cumplen el requisito de disponibilidad territorial exigido a toda covariable auxiliar.

### Variables socioeconómicas

Las condiciones socioeconómicas del territorio están correlacionadas con la densidad de población, la calidad de la enumeración censal y la cobertura de los registros administrativos. Su incorporación como covariables permite al modelo capturar parte de la heterogeneidad no observada entre segmentos.


**Indicadores de acceso a servicios.** A partir de los registros de conexión y consumo de servicios públicos descritos en la Sección \@ref(registros-administrativos), se construye la proporción de viviendas del segmento conectadas a la red de electricidad, agua potable, alcantarillado o internet. Esta proporción está correlacionada tanto con la densidad poblacional como con la cobertura censal, y refleja el nivel de integración del territorio a la infraestructura formal del Estado.

**Nivel educativo de la población.** El nivel de instrucción promedio de la población adulta del segmento, derivado de censos anteriores o de registros de matrícula escolar, puede utilizarse como indicador proxy de características socioeconómicas del territorio.

**Actividad económica predominante.** La clasificación del segmento según la actividad económica predominante —agropecuaria, industrial, comercial, servicios— condiciona la estructura demográfica esperada y los patrones de movilidad residencial. Esta clasificación puede derivarse de cartografía censal o de imágenes satelitales.

### Variables espaciales {#variables-espaciales}

Las variables espaciales capturan la posición geográfica del segmento y sus relaciones de vecindad con el entorno territorial. Su incorporación permite al modelo aprovechar, a través de covariables observadas, la continuidad espacial de la distribución poblacional —sin que ello implique una estructura de dependencia espacial modelada explícitamente entre segmentos vecinos.

**Distancia a centros urbanos.** La distancia euclidiana o por red vial desde el centroide del segmento hasta el centro urbano más cercano es un predictor relevante de la densidad y tipo de asentamiento. Segmentos más próximos a centros urbanos tienden a presentar mayor densidad poblacional, mayor acceso a servicios y mayor cobertura de registros administrativos.

**Accesibilidad y tiempos de desplazamiento.** El tiempo de desplazamiento por carretera hasta el centro urbano o el hospital más cercano, derivado de modelos de redes viales, es un indicador de accesibilidad territorial con mayor valor predictivo que la distancia euclidiana en contextos con topografía compleja o infraestructura vial deficiente.

**Altitud y topografía.** A partir de los modelos digitales de elevación descritos en la Sección \@ref(fuentes-satelitales), se calculan a nivel de segmento la altitud media, la pendiente del terreno y la variabilidad topográfica interna, que condicionan la viabilidad de asentamientos humanos y la densidad de población esperable. Estas variables son especialmente relevantes en países con territorios montañosos.

El efecto aleatorio territorial $\boldsymbol{\gamma}$ del Capítulo \@ref(cap-conteos) —de especificación intercambiable (jerárquica) a nivel de unidad territorial superior, sin estructura de adyacencia entre segmentos vecinos— no debe interpretarse como un mecanismo de modelamiento de la omisión censal: su función es capturar heterogeneidad residual en la densidad poblacional una vez incluidas las covariables observadas, no compensar la subenumeración diferencial descrita en la Sección \@ref(medicion-cobertura), que no se modela ni se corrige, sino que únicamente se utiliza para clasificar los segmentos según su nivel de cobertura.

La selección final del conjunto de variables explicativas debe fundamentarse en criterios de disponibilidad territorial —las variables deben estar disponibles para todos los segmentos—, pertinencia conceptual, capacidad predictiva demostrada y ausencia de multicolinealidad severa entre predictores. Los capítulos siguientes presentan la especificación formal de los modelos que integran estas variables en un esquema bayesiano jerárquico orientado a la estimación de conteos poblacionales subnacionales.
