# Integración de Fuentes de Información

La estimación de conteos poblacionales en unidades territoriales pequeñas no puede resolverse adecuadamente mediante el análisis directo de los datos censales. Las limitaciones de cobertura, la variabilidad asociada a dominios con baja densidad poblacional y la disponibilidad creciente de información auxiliar de distinta naturaleza hacen necesario un marco metodológico que integre múltiples fuentes bajo un esquema estadístico coherente.

Este capítulo presenta los principios de modelamiento que fundamentan los modelos bayesianos de estimación subnacional, describe las principales fuentes de información disponibles en América Latina y el Caribe y caracteriza las variables explicativas utilizadas para predecir la distribución espacial de la población.

## Principios de modelamiento

Los modelos estadísticos utilizados para la estimación subnacional de conteos poblacionales deben ser capaces de representar adecuadamente la naturaleza discreta y no negativa de los datos, de incorporar información auxiliar proveniente de fuentes heterogéneas, de producir estimaciones coherentes entre niveles territoriales y de cuantificar explícitamente la incertidumbre de las estimaciones resultantes. El cumplimiento de estos requisitos condiciona tanto la elección de la familia distribucional del modelo como el marco inferencial adoptado.

### Modelos de conteo

Los conteos poblacionales son variables aleatorias discretas no negativas. Esta naturaleza fundamental distingue el problema de estimación subnacional de los problemas de regresión con variables continuas y exige el uso de modelos de probabilidad apropiados para datos de conteo.

La distribución de Poisson constituye el punto de partida canónico para el modelamiento de conteos. Si $Y_i$ denota el conteo observado en el segmento $i$, el modelo de Poisson establece:

$$
Y_i \mid \lambda_i \sim \text{Poisson}(\lambda_i)
$$

donde $\lambda_i > 0$ es el parámetro de intensidad, que representa simultáneamente la media y la varianza de la distribución. La función de masa de probabilidad es:

$$
P(Y_i = y \mid \lambda_i) = \frac{e^{-\lambda_i}\, \lambda_i^y}{y!}, \qquad y = 0, 1, 2, \ldots
$$

La parametrización log-lineal del modelo relaciona el logaritmo de la intensidad con un predictor lineal de covariables:

$$
\log(\lambda_i) = \mathbf{x}_i^{\top} \boldsymbol{\beta} + u_i
$$

donde $\mathbf{x}_i$ es el vector de covariables auxiliares del segmento $i$, $\boldsymbol{\beta}$ es el vector de coeficientes y $u_i$ es un efecto aleatorio que captura la variabilidad no explicada por las covariables.

Un supuesto fundamental del modelo de Poisson es la equidispersión: $\mathbb{E}[Y_i \mid \lambda_i] = \text{Var}(Y_i \mid \lambda_i) = \lambda_i$. En la práctica, los conteos poblacionales suelen exhibir sobredispersión, es decir, una varianza observada mayor a la media. Este fenómeno puede originarse en heterogeneidad no observada entre segmentos, clustering espacial o errores de especificación del predictor.

Para tratar la sobredispersión, el modelo binomial negativo introduce un parámetro adicional $\phi > 0$ que controla la varianza:

$$
Y_i \mid \mu_i, \phi \sim \text{NegBin}(\mu_i, \phi)
$$

con función de masa de probabilidad:

$$
P(Y_i = y \mid \mu_i, \phi) = \binom{y + \phi - 1}{y} \left(\frac{\phi}{\phi + \mu_i}\right)^{\phi} \left(\frac{\mu_i}{\phi + \mu_i}\right)^{y}
$$

En este caso, $\mathbb{E}[Y_i] = \mu_i$ y $\text{Var}(Y_i) = \mu_i + \mu_i^2/\phi$. A medida que $\phi \to \infty$, la distribución binomial negativa converge hacia la Poisson.

Alternativamente, la sobredispersión puede modelarse mediante la inclusión de efectos aleatorios con distribución gamma en el predictor de Poisson. Si $\lambda_i = \mu_i \cdot \gamma_i$ con $\gamma_i \sim \text{Gamma}(\phi, \phi)$, la distribución marginal de $Y_i$ resulta binomial negativa con parámetros $(\mu_i, \phi)$. Esta representación facilita la interpretación de los efectos aleatorios como multiplicadores de la intensidad esperada en cada segmento.

En contextos de modelamiento jerárquico, la elección entre Poisson y binomial negativa debe fundamentarse tanto en consideraciones estadísticas —diagnóstico de sobredispersión— como en la disponibilidad de información auxiliar: una especificación más rica de covariables puede reducir la sobredispersión aparente al explicar parte de la heterogeneidad entre segmentos.

### Requerimientos de estimación subnacional

La estimación de conteos en niveles territoriales pequeños impone requerimientos adicionales que van más allá de la simple elección de una distribución de probabilidad. Estos requerimientos se derivan de la naturaleza jerárquica del problema y de las condiciones operativas en las que se producen los datos.

**Coherencia jerárquica.** Las estimaciones en niveles inferiores deben ser consistentes con los totales conocidos o estimados en niveles superiores. Si $\hat{N}_k^{(3)}$ denota la estimación del municipio $k$ y $\hat{N}_j^{(2)}$ la del departamento $j$, la coherencia exige:

$$
\hat{N}_j^{(2)} = \sum_{k \,:\, k \subset j} \hat{N}_k^{(3)}
$$

Esta restricción de coherencia entre niveles es fundamental para garantizar la consistencia interna del sistema estadístico y constituye un criterio de validación esencial de cualquier modelo de estimación subnacional.

**Estimación en dominios pequeños.** En segmentos censales con baja densidad poblacional, los conteos observados son altamente variables y presentan elevada incertidumbre. En estos dominios, los estimadores directos basados únicamente en la información del segmento son insuficientes y deben complementarse con información auxiliar proveniente de otras fuentes o de dominios relacionados.

**Propagación de incertidumbre.** Las estimaciones subnacionales deben acompañarse de medidas de incertidumbre que reflejen adecuadamente la variabilidad del proceso. En contextos donde los conteos observados son escasos o de baja calidad, la incertidumbre puede ser considerable, y su cuantificación explícita es esencial para el uso responsable de las estimaciones en procesos de planificación y asignación de recursos.

**Estabilidad temporal.** Cuando se dispone de información de periodos censales anteriores, el modelo debe ser capaz de incorporar dicha información de forma coherente, reconociendo que la población cambia en el tiempo y que la relevancia de la información histórica decrece a medida que aumenta el intervalo temporal.

### Justificación del enfoque bayesiano

El enfoque bayesiano ofrece un marco de inferencia particularmente apropiado para la estimación subnacional de conteos poblacionales. Sus ventajas frente a los métodos frecuentistas se derivan directamente de las características del problema.

**Representación explícita de la incertidumbre.** En el paradigma bayesiano, todos los parámetros desconocidos se tratan como variables aleatorias cuya incertidumbre se cuantifica mediante distribuciones de probabilidad. La distribución posterior $p(\boldsymbol{\theta} \mid \mathbf{Y})$ encapsula el estado de conocimiento sobre la población en cada segmento dado el conjunto de datos observados:

$$
p(\boldsymbol{\theta} \mid \mathbf{Y}) \propto p(\mathbf{Y} \mid \boldsymbol{\theta})\, p(\boldsymbol{\theta})
$$

Esta representación permite calcular intervalos de credibilidad, probabilidades de excedencia y cualquier otra cantidad de interés derivada de la distribución posterior.

**Incorporación de información previa.** Las distribuciones a priori permiten incorporar conocimiento demográfico sustantivo sobre la estructura de la población, restricciones de positividad, información de censos anteriores o expertos en el área. A diferencia de los métodos frecuentistas, el marco bayesiano provee un mecanismo formal para integrar esta información de manera coherente con los datos observados.

**Estimación simultánea de múltiples dominios.** Los modelos jerárquicos bayesianos permiten estimar simultáneamente la población en todos los segmentos, compartiendo información entre dominios relacionados. Los parámetros del nivel superior —como los coeficientes de las covariables— se estiman a partir de la información conjunta de todos los segmentos, lo que permite que los dominios con mejor cobertura contribuyan a estabilizar las estimaciones en dominios con datos limitados.

**Coherencia probabilística.** Las estimaciones bayesianas son coherentes por construcción: cualquier función de los parámetros puede estimarse a partir de la distribución posterior, y los intervalos de credibilidad tienen interpretación probabilística directa. Esta propiedad es especialmente valiosa cuando se requiere reportar incertidumbre a distintos niveles de desagregación territorial.

La estimación de la distribución posterior en modelos complejos se realiza mediante métodos de Monte Carlo por cadenas de Markov (MCMC). Entre los algoritmos más utilizados en la práctica se encuentran el muestreo de Gibbs, el algoritmo de Metropolis-Hastings y, más recientemente, el método de Monte Carlo Hamiltoniano (HMC) implementado en Stan. Estos algoritmos permiten obtener muestras de la distribución posterior en modelos con alta dimensionalidad y estructuras jerárquicas complejas.

### Integración de múltiples fuentes

El marco bayesiano provee un mecanismo natural para integrar información proveniente de múltiples fuentes bajo un esquema probabilístico coherente. La integración se realiza a través de la función de verosimilitud, que puede descomponerse en contribuciones de distintas fuentes de información, y a través de las distribuciones a priori, que capturan conocimiento previo sobre los parámetros.

Supóngase que se dispone de tres fuentes de información para el segmento $i$: el conteo censal observado $Y_i^{(C)}$, el preconteo operativo $Y_i^{(P)}$ y un conteo derivado de registros administrativos $Y_i^{(A)}$. Bajo el supuesto de independencia condicional entre fuentes dado el parámetro de población $N_i$, la verosimilitud conjunta puede escribirse como:

$$
p\!\left(Y_i^{(C)}, Y_i^{(P)}, Y_i^{(A)} \mid N_i, \boldsymbol{\theta}\right) = p\!\left(Y_i^{(C)} \mid N_i, \boldsymbol{\theta}^{(C)}\right) \cdot p\!\left(Y_i^{(P)} \mid N_i, \boldsymbol{\theta}^{(P)}\right) \cdot p\!\left(Y_i^{(A)} \mid N_i, \boldsymbol{\theta}^{(A)}\right)
$$

donde $\boldsymbol{\theta}^{(C)}$, $\boldsymbol{\theta}^{(P)}$ y $\boldsymbol{\theta}^{(A)}$ son los parámetros específicos de cada modelo de medición. Esta factorización permite modelar de forma separada las características de cada fuente —su cobertura, sus sesgos y su variabilidad— sin imponer restricciones artificiosas de equivalencia entre ellas.

El supuesto de independencia condicional entre fuentes es una simplificación que puede no ser siempre válida. En la práctica, distintas fuentes pueden compartir errores comunes asociados a factores territoriales no observados. Este problema puede mitigarse parcialmente mediante la inclusión de efectos aleatorios compartidos entre fuentes en el modelo jerárquico.

### Relación con Small Area Estimation

Los modelos bayesianos de estimación poblacional subnacional se inscriben dentro del campo más amplio de la Estimación en Áreas Pequeñas (*Small Area Estimation*, SAE). Este campo metodológico desarrolla métodos estadísticos orientados a producir estimaciones confiables en dominios con tamaño muestral insuficiente para la estimación directa.

Los modelos SAE se clasifican generalmente en dos grandes categorías según el nivel en el que se especifica la estructura del modelo:

**Modelos a nivel de área.** Estos modelos operan sobre estadísticos agregados calculados para cada dominio. El modelo de Fay-Herriot es el referente clásico: se postula que la estimación directa $\hat{\theta}_i$ del parámetro de interés $\theta_i$ en el área $i$ satisface:

$$
\hat{\theta}_i = \theta_i + e_i, \qquad e_i \mid \sigma_i^2 \sim \mathcal{N}(0, \sigma_i^2)
$$

donde $\sigma_i^2$ se supone conocido, y el modelo de enlace conecta $\theta_i$ con las covariables auxiliares:

$$
\theta_i = \mathbf{x}_i^{\top} \boldsymbol{\beta} + u_i, \qquad u_i \sim \mathcal{N}(0, \sigma_u^2)
$$

**Modelos a nivel de unidad.** Estos modelos incorporan información a nivel de observación individual. El modelo de Battese-Harter-Fuller es el referente en este caso, y permite explotar la variabilidad dentro de los dominios para mejorar la estimación.

En el contexto de la estimación de conteos poblacionales censales, los modelos más apropiados son generalmente de nivel de área, dado que la información disponible suele estar agregada a nivel de segmento. La extensión bayesiana del modelo de Fay-Herriot para conteos —utilizando distribuciones de Poisson o binomial negativa en lugar de la distribución normal— constituye la base de los modelos desarrollados en los capítulos siguientes.

Una diferencia importante entre el enfoque SAE clásico y el bayesiano reside en el tratamiento de los hiperparámetros del modelo, como la varianza de los efectos aleatorios $\sigma_u^2$. En el enfoque frecuentista, estos se estiman mediante máxima verosimilitud restringida (REML). En el enfoque bayesiano, se les asigna una distribución a priori y se estiman conjuntamente con los demás parámetros, lo que permite propagar su incertidumbre hacia las estimaciones finales.

## Identificación de fuentes

La calidad de los modelos bayesianos de estimación subnacional depende críticamente de la disponibilidad y pertinencia de las fuentes de información auxiliar incorporadas. En América Latina y el Caribe, el conjunto de fuentes disponibles varía considerablemente entre países, pero puede organizarse en cuatro categorías principales: medición de cobertura censal, preconteos operativos, registros administrativos y fuentes satelitales.

### Medición de cobertura a nivel de segmento

La cobertura censal es el primer elemento que debe caracterizarse antes de iniciar cualquier proceso de estimación subnacional. La cobertura hace referencia a la proporción de la población real que fue efectivamente enumerada durante el operativo censal. Su complemento —la tasa de omisión censal— cuantifica la fracción de la población no observada.

Formalmente, sea $N_i$ la población verdadera del segmento $i$ y $Y_i^{(C)}$ el conteo observado durante el censo. La tasa de cobertura del segmento se define como:

$$
c_i = \frac{Y_i^{(C)}}{N_i}
$$

y la tasa de omisión correspondiente como $\omega_i = 1 - c_i$. Dado que $N_i$ no es directamente observable, la estimación de $c_i$ requiere el uso de métodos indirectos o información auxiliar.

En la práctica, la medición de cobertura a nivel de segmento se realiza a través de tres mecanismos principales. El primero consiste en encuestas postcensales de cobertura, diseñadas específicamente para estimar la tasa de omisión mediante una operación de campo independiente al censo. El segundo utiliza métodos de conciliación demográfica que comparan los conteos censales con proyecciones independientes basadas en estadísticas vitales. El tercero emplea técnicas de captura-recaptura que cruzan el padrón censal con registros administrativos para estimar la población no observada.

La heterogeneidad espacial de la cobertura censal es una característica sistemática en todos los países de la región. La cobertura tiende a ser menor en áreas rurales dispersas, asentamientos informales, zonas de difícil acceso, territorios indígenas y contextos urbanos con alta movilidad residencial. Esta heterogeneidad espacial motiva la necesidad de modelar la tasa de cobertura como una función de características territoriales observables.

Bajo el marco bayesiano, la cobertura del segmento puede modelarse como un parámetro latente con distribución a priori que refleje el conocimiento previo sobre su variabilidad entre segmentos. La incorporación de covariables territoriales como predictores de la cobertura permite que el modelo utilice la información disponible para estimar la omisión diferencial entre dominios.

### Preconteos y segmentación

Los preconteos operativos constituyen una de las fuentes auxiliares más directamente vinculadas a la estimación de la población en segmentos censales. Estas operaciones, realizadas durante la fase de actualización cartográfica previa al levantamiento censal, producen información sobre el número aproximado de viviendas o estructuras habitacionales presentes en cada unidad operativa.

La segmentación censal es el proceso mediante el cual el territorio nacional se divide en unidades operativas de trabajo, denominadas segmentos o áreas de enumeración. Cada segmento es asignado a un censista y está diseñado para ser enumerable en el tiempo operativo disponible. Los criterios de segmentación varían entre países: algunos utilizan como criterio el número esperado de viviendas, otros priorizan continuidad espacial o accesibilidad geográfica.

Sea $P_i$ el preconteo de viviendas registrado en el segmento $i$ durante la actualización cartográfica. La relación entre el preconteo y la población esperada puede expresarse mediante un modelo de regresión log-lineal:

$$
\log(N_i) = \alpha_0 + \alpha_1 \log(P_i) + \eta_i
$$

donde $\alpha_0$ y $\alpha_1$ son parámetros a estimar y $\eta_i$ es un error residual que captura la variabilidad no explicada por el preconteo. El parámetro $\alpha_1$ puede interpretarse como la elasticidad de la población respecto al preconteo: si $\alpha_1 = 1$, la relación entre viviendas y personas es proporcional; si $\alpha_1 > 1$, segmentos con más viviendas tienen mayor tamaño medio de hogar.

El preconteo es especialmente valioso en contextos donde el operativo censal no logró cobertura completa, dado que provee una señal anticipada sobre la magnitud poblacional esperada que es independiente del proceso de enumeración. Su principal limitación es la distancia temporal entre la actualización cartográfica y el momento censal: en contextos con crecimiento urbano acelerado, los preconteos pueden quedar desactualizados rápidamente.

### Registros administrativos (variables proxy)

Los registros administrativos son bases de datos generadas por entidades gubernamentales como resultado de sus funciones institucionales. A diferencia de los censos, no tienen por objetivo la medición estadística de la población, sino la gestión de servicios, beneficios o trámites administrativos. Sin embargo, en la medida en que su cobertura es razonablemente alta y su definición territorial compatible con los segmentos censales, pueden utilizarse como variables proxy de la magnitud poblacional.

Entre los registros administrativos más utilizados en modelos de estimación subnacional en América Latina y el Caribe se encuentran:

**Registros civiles.** Los sistemas de registro de nacimientos, defunciones y matrimonios proporcionan información sobre eventos demográficos ocurridos en el territorio. La densidad de nacimientos o defunciones por unidad territorial es un indicador parcial de la magnitud y composición de la población subyacente.

**Padrones electorales.** Los padrones de electores habilitados para votar proporcionan un conteo de personas adultas registradas con dirección conocida en cada territorio. Su cobertura está condicionada por la participación en el sistema electoral y puede ser incompleta en poblaciones jóvenes, migrantes o con baja interacción institucional.

**Registros de afiliación a sistemas de salud y seguridad social.** Los sistemas de salud pública o los registros de afiliación a la seguridad social contienen información sobre personas que acceden regularmente a servicios institutucionales. Su cobertura depende del grado de formalidad laboral y del acceso efectivo a los servicios en cada territorio.

**Registros de beneficiarios de programas sociales.** Los padrones de beneficiarios de programas de transferencias condicionadas u otros programas sociales focalizados proporcionan información sobre hogares en situación de vulnerabilidad. Aunque su cobertura no es universal, pueden ser especialmente informativos en áreas con alta concentración de población en condición de pobreza.

Sea $A_{i,r}$ el conteo proveniente del registro $r$ para el segmento $i$. Su uso como variable explicativa en el modelo de estimación se justifica por la correlación esperada con la población subyacente $N_i$:

$$
A_{i,r} \approx c_{i,r} \cdot N_i
$$

donde $c_{i,r} \in (0, 1]$ es la tasa de cobertura del registro $r$ en el segmento $i$. La transformación logarítmica $\log(A_{i,r} + 1)$ estabiliza la varianza y facilita la incorporación de estos conteos como predictores en el modelo log-lineal.

### Fuentes satelitales

Las imágenes satelitales y los productos de percepción remota han ampliado considerablemente el conjunto de covariables disponibles para la estimación poblacional subnacional. Su principal ventaja es la cobertura territorial universal, la continuidad temporal y la independencia respecto a los sistemas estadísticos institucionales.

Las fuentes satelitales más utilizadas en estimación poblacional pueden agruparse en las siguientes categorías:

**Luminosidad nocturna.** Los datos de radiance nocturna capturados por sensores satelitales, como el producto VIIRS-DNB de la NOAA, permiten identificar áreas con presencia de iluminación artificial. La intensidad lumínica nocturna está correlacionada con la actividad económica y la densidad de asentamientos humanos permanentes. Sea $L_i$ el valor medio de luminosidad nocturna en el segmento $i$; su transformación logarítmica $\log(L_i + 1)$ es utilizada frecuentemente como predictor de la población.

**Área construida y cobertura urbana.** Los productos de clasificación de uso del suelo derivados de imágenes ópticas como Sentinel-2 o Landsat permiten estimar la proporción de área construida dentro de cada segmento. El producto Global Human Settlement Layer (GHSL) de la Comisión Europea ofrece estimaciones de área construida a resolución de 100 metros con cobertura global.

**Índice de vegetación de diferencia normalizada (NDVI).** El NDVI mide la densidad y vitalidad de la vegetación a partir de la reflectancia en bandas del infrarrojo cercano y el rojo visible. Valores bajos de NDVI en áreas no áridas generalmente indican presencia de infraestructura construida y asentamientos urbanos, mientras que valores altos corresponden a áreas con cobertura vegetal densa.

**Temperatura superficial terrestre (LST).** Las islas de calor urbano, reflejadas en valores elevados de temperatura superficial, constituyen un indicador indirecto de densidad de infraestructura y actividad humana.

**Modelos digitales de elevación.** La topografía del terreno condiciona la distribución espacial de la población. Los modelos de elevación digital como SRTM o ALOS permiten derivar variables como altitud media, pendiente y orientación del terreno, que están correlacionadas con la densidad y distribución de los asentamientos humanos.

La integración de covariables satelitales en el modelo requiere procesar las imágenes hasta el nivel del segmento censal, lo que implica operaciones de reproyección, remuestreo y estadísticas zonales. La resolución espacial de las imágenes debe ser compatible con el tamaño de los segmentos: resoluciones muy gruesas pueden introducir errores de asignación en segmentos pequeños, mientras que resoluciones muy finas pueden aumentar el costo computacional sin beneficio estadístico apreciable.

## Variables explicativas

La calidad predictiva del modelo de estimación subnacional depende directamente de la selección y construcción de las variables explicativas incorporadas como covariables. Estas variables pueden organizarse en tres grandes grupos según su naturaleza conceptual: variables demográficas, variables socioeconómicas y variables espaciales.

### Variables demográficas

Las variables demográficas capturan características de la estructura y dinámica de la población que están directamente relacionadas con la magnitud y distribución de los conteos en cada segmento.

**Estructura por sexo y edad.** La composición demográfica de la población condiciona la demanda de servicios y la organización territorial de los asentamientos. La proporción de población en edades productivas ($15$--$64$ años), la proporción de adultos mayores ($65$ años y más) y la proporción de niños menores de 15 años son indicadores relevantes de la estructura etaria del segmento. Formalmente:

$$
p_{i,[a,b]} = \frac{N_{i,[a,b]}}{N_i}, \qquad \sum_e p_{i,e} = 1
$$

**Razón de masculinidad.** La distribución por sexo puede ser informativa en contextos con migración diferencial o actividades económicas con sesgo de género. La razón de masculinidad $\text{RM}_i = N_{i,M}/N_{i,F} \times 100$ puede utilizarse como predictor complementario.

**Tasa de fecundidad implícita.** En territorios con registros de nacimientos disponibles, la relación entre nacimientos registrados y población femenina en edad reproductiva proporciona una estimación indirecta de la dinámica de crecimiento natural del segmento.

**Tamaño medio del hogar.** El número promedio de personas por vivienda constituye un multiplicador fundamental en la relación entre el preconteo de viviendas y la estimación de personas. En América Latina y el Caribe, el tamaño medio del hogar presenta heterogeneidad territorial significativa, con valores más altos en áreas rurales y en hogares con mayor número de hijos.

### Variables socioeconómicas

Las condiciones socioeconómicas del territorio están correlacionadas con la densidad de población, la calidad de la enumeración censal y la cobertura de los registros administrativos. Su incorporación como covariables permite al modelo capturar parte de la heterogeneidad no observada entre segmentos.

**Índice de necesidades básicas insatisfechas (NBI).** El NBI resume un conjunto de carencias básicas del hogar —acceso a agua potable, saneamiento, educación, hacinamiento, calidad de la vivienda— en un indicador sintético de pobreza estructural. Territorios con altos niveles de NBI suelen presentar mayor omisión censal y menor cobertura de registros administrativos.

**Indicadores de acceso a servicios.** La proporción de hogares con acceso a servicios públicos como electricidad, agua potable, alcantarillado o internet está correlacionada tanto con la densidad poblacional como con la cobertura censal. El acceso a servicios refleja el nivel de integración del territorio a la infraestructura formal del Estado.

**Nivel educativo de la población.** El nivel de instrucción promedio de la población adulta del segmento, derivado de censos anteriores o de registros de matrícula escolar, puede utilizarse como indicador proxy de características socioeconómicas del territorio.

**Actividad económica predominante.** La clasificación del segmento según la actividad económica predominante —agropecuaria, industrial, comercial, servicios— condiciona la estructura demográfica esperada y los patrones de movilidad residencial. Esta clasificación puede derivarse de cartografía censal o de imágenes satelitales.

### Variables espaciales

Las variables espaciales capturan la posición geográfica del segmento y sus relaciones de vecindad con el entorno territorial. Su incorporación permite al modelo explotar la continuidad espacial de la distribución poblacional y modelar explícitamente la dependencia entre segmentos geográficamente cercanos.

**Distancia a centros urbanos.** La distancia euclidiana o por red vial desde el centroide del segmento hasta el centro urbano más cercano es un predictor relevante de la densidad y tipo de asentamiento. Segmentos más próximos a centros urbanos tienden a presentar mayor densidad poblacional, mayor acceso a servicios y mayor cobertura de registros administrativos.

**Accesibilidad y tiempos de desplazamiento.** El tiempo de desplazamiento por carretera hasta el centro urbano o el hospital más cercano, derivado de modelos de redes viales, es un indicador de accesibilidad territorial con mayor valor predictivo que la distancia euclidiana en contextos con topografía compleja o infraestructura vial deficiente.

**Altitud y topografía.** La altitud media del segmento, la pendiente del terreno y la variabilidad topográfica interna condicionan la viabilidad de asentamientos humanos y la densidad de población esperable. Las variables topográficas derivadas de modelos digitales de elevación son especialmente relevantes en países con territorios montañosos.

**Efectos espaciales aleatorios.** Más allá de las covariables observadas, la distribución espacial de la población presenta autocorrelación espacial que puede ser capturada mediante efectos aleatorios estructurados. Los modelos de efectos espaciales, como el modelo condicional autorregresivo (CAR), permiten modelar explícitamente la dependencia entre segmentos vecinos:

$$
u_i \mid \mathbf{u}_{-i} \sim \mathcal{N}\!\left(\frac{\sum_{j \sim i} u_j}{n_i},\, \frac{\sigma_u^2}{n_i}\right)
$$

donde la notación $j \sim i$ indica que el segmento $j$ es vecino del segmento $i$ y $n_i$ es el número de vecinos. Este modelo impone que el efecto aleatorio de cada segmento sea similar al promedio de sus vecinos, reflejando la continuidad espacial de las características no observadas que determinan la densidad poblacional.

La selección final del conjunto de variables explicativas debe fundamentarse en criterios de disponibilidad territorial —las variables deben estar disponibles para todos los segmentos—, pertinencia conceptual, capacidad predictiva demostrada y ausencia de multicolinealidad severa entre predictores. Los capítulos siguientes presentan la especificación formal de los modelos que integran estas variables en un esquema bayesiano jerárquico orientado a la estimación de conteos poblacionales subnacionales.
