# Modelo para Conteos Poblacionales

Los capítulos precedentes han establecido el marco conceptual de la estimación subnacional, identificado las fuentes de información disponibles, descrito los procedimientos de preparación de imágenes satelitales y detallado el proceso de construcción de los insumos analíticos. Sobre esta base, el presente capítulo introduce la especificación formal del modelo estadístico que integra dichos elementos bajo un esquema probabilístico coherente, orientado a estimar los conteos de población en segmentos censales con cobertura parcial o incompleta.

La formulación adoptada debe satisfacer los requerimientos establecidos en capítulos anteriores: representar adecuadamente la naturaleza discreta y no negativa de los conteos, incorporar información auxiliar de fuentes heterogéneas, producir estimaciones en dominios sin cobertura directa y cuantificar explícitamente la incertidumbre de los resultados. Frente a estos requerimientos, un modelo de Poisson simple resulta insuficiente cuando los datos exhiben sobredispersión o cuando se dispone de información de referencia sobre el número de estructuras habitacionales en cada segmento. La extensión log-normal del modelo de Poisson, articulada con una estructura jerárquica de efectos aleatorios, responde a estas limitaciones de manera estadísticamente coherente.

El modelo propuesto opera en dos niveles. En el primer nivel, la densidad poblacional —definida como el número de personas por estructura habitacional— se representa mediante una distribución log-normal cuyo parámetro de localización es función lineal de covariables auxiliares y efectos aleatorios territoriales. En el segundo nivel, los conteos de población observados se modelan como realizaciones de una distribución de Poisson cuyo parámetro de intensidad resulta del producto entre la densidad estimada y el número de estructuras en cada segmento. Esta arquitectura de dos etapas constituye el modelo Poisson-lognormal y provee un mecanismo natural de control de la sobredispersión mientras mantiene la interpretabilidad de los parámetros.

La estructura del capítulo se organiza en dos secciones principales. La primera presenta la especificación probabilística completa del modelo: definición formal, función de verosimilitud, distribuciones a priori, distribución posterior e interpretación de parámetros. La segunda describe en detalle los componentes del modelo: efectos fijos, efectos aleatorios, mecanismos de interacción y elementos adicionales como el offset, la sobredispersión y las alternativas distribucionales consideradas en el diseño.

## Modelo Poisson-lognormal

### Definición formal

La especificación del modelo parte de dos cantidades fundamentales definidas para cada segmento censal $i$ perteneciente al conjunto $\mathcal{S} = \{1, 2, \ldots, D\}$ de todos los segmentos del país. La primera es el conteo de población observado $Y_i$, disponible únicamente para los segmentos que alcanzaron cobertura efectiva durante el operativo censal. La segunda es el número de estructuras habitacionales $V_i$, derivado del preconteo operativo o de fuentes satelitales de área construida, y disponible para todos los segmentos del país.

**Nota de notación.** La cardinalidad $D = |\mathcal{S}|$ corresponde al mismo conjunto de segmentos denotado $\{1, \ldots, I\}$ en los Capítulos 2 y 4; se adopta aquí la notación $D$ ($D_{obs}$, $D_{tot}$) por su correspondencia directa con la implementación computacional en Stan (Sección \@ref(stan-implementacion) del capítulo siguiente). El número de estructuras habitacionales $V_i$ es la misma cantidad denotada $P_i$ (preconteo de viviendas) en el Capítulo 2. Finalmente, ni $D$ ni sus variantes indexadas deben confundirse con la densidad poblacional por área $D_i = N_i/A_i$ definida en el Capítulo 1: la densidad de personas por estructura habitacional propia de este capítulo se denota $\delta_i$.

Sea $\mathcal{S}_{obs} \subset \mathcal{S}$ el subconjunto de segmentos con información censal observada, de cardinalidad $D_{obs} = |\mathcal{S}_{obs}|$. El modelo distingue explícitamente entre estos dos conjuntos: los parámetros se estiman a partir de $\mathcal{S}_{obs}$ y se utilizan posteriormente para generar predicciones sobre la totalidad de $\mathcal{S}$, incluyendo los segmentos no observados en el operativo censal.

El elemento central del modelo es la densidad poblacional $\delta_i$, definida como el número esperado de personas por estructura habitacional en el segmento $i$:

$$
\delta_i = \frac{N_i}{V_i}
$$

donde $N_i$ denota la población verdadera del segmento, tal como se definió en el capítulo de conceptos generales. Esta cantidad no es directamente observable sino que debe inferirse a partir de la información disponible. La densidad $\delta_i$ representa una medida de intensidad específica de ocupación habitacional que permite comparar segmentos con distinto número de estructuras bajo una escala común y facilita la incorporación del número de viviendas como referencia natural del proceso de conteo.

El modelo Poisson-lognormal se formula mediante dos componentes probabilísticos anidados. En el primer nivel, la densidad latente $\delta_i$ sigue una distribución log-normal con parámetro de localización $\mu_i$ y parámetro de escala $\sigma$:

$$
\delta_i \mid \mu_i, \sigma \;\sim\; \text{LogNormal}(\mu_i,\, \sigma), \qquad i \in \mathcal{S}_{obs}
$$

La distribución log-normal garantiza que $\delta_i > 0$ por construcción, lo cual es consistente con la interpretación de $\delta_i$ como densidad de personas por estructura. El parámetro $\mu_i$ captura la localización de la distribución en escala logarítmica y es modelado como función lineal de las covariables disponibles para el segmento. El parámetro $\sigma > 0$ controla la dispersión de las densidades alrededor de dicha localización.

En el segundo nivel, los conteos de población se modelan como realizaciones de una distribución de Poisson cuyo parámetro de intensidad es el producto entre la densidad estimada y el número de estructuras del segmento:

$$
Y_i \mid \delta_i, V_i \;\sim\; \text{Poisson}(\lambda_i), \qquad \lambda_i = \delta_i \cdot V_i, \qquad i \in \mathcal{S}_{obs}
$$

Esta parametrización incorpora el número de estructuras $V_i$ como referencia natural de escala. Segmentos con mayor número de estructuras tienen, en igualdad de condiciones, una intensidad esperada proporcionalmente mayor. El parámetro de localización de la densidad sigue un predictor lineal de la forma:

$$
\mu_i = \mathbf{x}_i^{\top} \boldsymbol{\beta} + \mathbf{z}_i^{\top} \boldsymbol{\gamma}
$$

donde $\mathbf{x}_i \in \mathbb{R}^P$ es el vector de covariables auxiliares estandarizadas del segmento $i$, $\boldsymbol{\beta} \in \mathbb{R}^P$ es el vector de coeficientes de efectos fijos, $\mathbf{z}_i \in \{0,1\}^Q$ es el vector de indicadores para los efectos aleatorios territoriales y $\boldsymbol{\gamma} \in \mathbb{R}^Q$ es el vector de coeficientes de efectos aleatorios. La dimensión $P$ corresponde al número de covariables auxiliares seleccionadas y $Q$ al número de unidades territoriales de nivel superior —provincias, departamentos o regiones— en las que se anidan los segmentos.

El conjunto de parámetros estructurales del modelo es $\boldsymbol{\theta} = \{\boldsymbol{\beta}, \boldsymbol{\gamma}, \sigma, \sigma_U\}$, donde $\sigma_U > 0$ es el hiperparámetro que controla la variabilidad de los efectos aleatorios, cuya especificación se detalla en la sección de distribuciones a priori. Adicionalmente, $\boldsymbol{\delta} = \{\delta_i : i \in \mathcal{S}_{obs}\}$ es el vector de densidades latentes para los segmentos observados, que se trata como conjunto de parámetros latentes en la inferencia bayesiana de manera conjunta con $\boldsymbol{\theta}$.

### Función de verosimilitud

La función de verosimilitud del modelo Poisson-lognormal se construye sobre la información disponible en los segmentos observados $\mathcal{S}_{obs}$. Dado que las densidades $\delta_i$ son tratadas como parámetros latentes, la verosimilitud conjunta factoriza sobre segmentos bajo el supuesto de independencia condicional entre observaciones dado el vector de parámetros $\boldsymbol{\theta}$:

$$
p(\mathbf{Y}_{obs}, \boldsymbol{\delta} \mid \boldsymbol{\theta}) = \prod_{i \in \mathcal{S}_{obs}} p(Y_i \mid \delta_i, V_i) \cdot p(\delta_i \mid \mu_i, \sigma)
$$

donde $\mathbf{Y}_{obs} = \{Y_i : i \in \mathcal{S}_{obs}\}$ es el vector de conteos observados. Expandiendo cada factor con sus formas funcionales explícitas:

$$
p(\mathbf{Y}_{obs}, \boldsymbol{\delta} \mid \boldsymbol{\theta}) = \prod_{i \in \mathcal{S}_{obs}} \frac{e^{-\delta_i V_i}(\delta_i V_i)^{Y_i}}{Y_i!} \cdot \frac{1}{\delta_i \sigma \sqrt{2\pi}} \exp\!\left(-\frac{(\log \delta_i - \mu_i)^2}{2\sigma^2}\right)
$$

La verosimilitud log-conjunta, omitiendo constantes respecto a los parámetros, adopta la forma:

$$
\log p(\mathbf{Y}_{obs}, \boldsymbol{\delta} \mid \boldsymbol{\theta}) = \sum_{i \in \mathcal{S}_{obs}} \left[ Y_i \log(\delta_i V_i) - \delta_i V_i - \log \delta_i - \frac{(\log \delta_i - \mu_i)^2}{2\sigma^2} - \log \sigma \right]
$$

Esta expresión pone de manifiesto la naturaleza jerárquica del modelo: el primer par de términos corresponde a la contribución de la distribución de Poisson para los conteos observados, mientras que los términos restantes corresponden a la contribución de la distribución log-normal para las densidades latentes. El término $-\log \delta_i$ proviene del jacobiano de la densidad log-normal —resultado de la transformación entre la escala multiplicativa de $\delta_i$ y la escala logarítmica— y garantiza la corrección del volumen en el cambio de variables. Ambas contribuciones están conectadas a través del parámetro $\delta_i$, cuya estimación equilibra simultáneamente el ajuste a los conteos observados y la regularización impuesta por el modelo de densidad.

Una propiedad relevante de esta formulación es que la distribución marginal de $Y_i$, obtenida al integrar $\delta_i$ de la expresión conjunta, resulta en una mezcla de Poisson con distribución de mezcla log-normal. Esta mezcla genera mayor dispersión que la Poisson pura. Formalmente, si $\delta_i \sim \text{LogNormal}(\mu_i, \sigma)$ y $Y_i \mid \delta_i \sim \text{Poisson}(\delta_i V_i)$, entonces la media y la varianza marginales del conteo son:

$$
\mathbb{E}[Y_i] = V_i \exp\!\left(\mu_i + \frac{\sigma^2}{2}\right)
$$

$$
\text{Var}(Y_i) = \mathbb{E}[Y_i] + V_i^2\, e^{2\mu_i + \sigma^2}\left(e^{\sigma^2} - 1\right)
$$

Dado que $\text{Var}(Y_i) > \mathbb{E}[Y_i]$ siempre que $\sigma > 0$, el modelo Poisson-lognormal es inherentemente sobredisperso respecto a la distribución de Poisson pura, con el grado de sobredispersión controlado por el parámetro $\sigma$. Esta propiedad lo hace apropiado para datos censales donde la varianza observada supera sistemáticamente la esperada bajo el supuesto de equidispersión.

### Distribuciones a priori

La especificación bayesiana del modelo requiere asignar distribuciones a priori a todos los parámetros desconocidos. En el contexto del modelo Poisson-lognormal, el conjunto de parámetros a los que se asignan distribuciones a priori incluye los coeficientes de efectos fijos $\boldsymbol{\beta}$, los coeficientes de efectos aleatorios $\boldsymbol{\gamma}$, el parámetro de escala de la densidad $\sigma$ y el hiperparámetro de variabilidad de los efectos aleatorios $\sigma_U$.

La elección de distribuciones a priori débilmente informativas ofrece un equilibrio entre la ausencia de información fuerte sobre los parámetros y la estabilización del proceso de estimación. Bajo este enfoque, las distribuciones a priori incorporan restricciones de signo y magnitud consistentes con el conocimiento sustantivo del problema sin imponer concentración excesiva sobre valores específicos. Esta estrategia resulta especialmente adecuada en modelos con alta dimensionalidad paramétrica, donde las distribuciones no informativas pueden generar problemas de identificación o inestabilidad en la inferencia.

Para los coeficientes de efectos fijos se adopta una distribución normal centrada en cero con varianza unitaria:

$$
\beta_k \sim \mathcal{N}(0,\, 1), \qquad k = 1, \ldots, P
$$

Esta distribución a priori es apropiada cuando las covariables han sido previamente estandarizadas, de modo que un coeficiente con valor absoluto superior a dos corresponde a un efecto sustancialmente grande en términos de la escala de las covariables. La centrada en cero refleja la ausencia de conocimiento previo sobre la dirección del efecto de cada covariable, mientras que la varianza unitaria actúa como regularización suave que favorece efectos de magnitud moderada.

Para los coeficientes de efectos aleatorios se adopta una distribución normal jerárquica con varianza controlada por el hiperparámetro $\sigma_U$:

$$
\gamma_j \sim \mathcal{N}(0,\, \sigma_U^2), \qquad j = 1, \ldots, Q
$$

Esta especificación introduce una estructura de encogimiento sobre los efectos aleatorios: territorios con información escasa son atraídos hacia el promedio global capturado por los efectos fijos, mientras que territorios con información abundante y patrón sistemáticamente distinto pueden mantener efectos locales de mayor magnitud. El grado de encogimiento está regulado por $\sigma_U$, que a su vez es un parámetro desconocido al que se asigna una distribución a priori.

Para el hiperparámetro de variabilidad de los efectos aleatorios se adopta una distribución normal positiva:

$$
\sigma_U \sim \mathcal{N}^+(0,\, 1)
$$

Esta elección permite que el modelo aprenda la magnitud de la variabilidad territorial a partir de los datos, sin imponer un valor fijo. La distribución normal positiva asigna probabilidad significativa a valores cercanos a cero —compatibles con un modelo sin efectos aleatorios relevantes— mientras permite valores mayores si los datos los respaldan.

Para el parámetro de escala de la densidad se adopta una distribución de Cauchy positiva:

$$
\sigma \sim \text{Cauchy}^+(0,\, 2{,}5)
$$

La distribución de Cauchy positiva presenta colas más pesadas que la distribución exponencial o que la gamma inversa, lo que permite una amplia dispersión a priori sin concentrar excesiva probabilidad en valores pequeños. Esta propiedad es útil cuando la variabilidad real de las densidades entre segmentos es sustancialmente alta, como suele ocurrir en contextos con marcada heterogeneidad territorial y cobertura censal diferencial.

### Distribución posterior

La distribución posterior del modelo Poisson-lognormal combina la verosimilitud conjunta con las distribuciones a priori de todos los parámetros. Aplicando el teorema de Bayes, la distribución posterior conjunta sobre los parámetros estructurales $\boldsymbol{\theta}$ y las densidades latentes $\boldsymbol{\delta}$ es proporcional al producto de la verosimilitud y las previas:

$$
p(\boldsymbol{\theta}, \boldsymbol{\delta} \mid \mathbf{Y}_{obs}) \;\propto\; p(\mathbf{Y}_{obs}, \boldsymbol{\delta} \mid \boldsymbol{\beta}, \boldsymbol{\gamma}, \sigma) \cdot p(\boldsymbol{\gamma} \mid \sigma_U) \cdot p(\boldsymbol{\beta}) \cdot p(\sigma) \cdot p(\sigma_U)
$$

Expandiendo cada componente con sus formas funcionales específicas:

$$
p(\boldsymbol{\theta}, \boldsymbol{\delta} \mid \mathbf{Y}_{obs}) \;\propto\; \left[\prod_{i \in \mathcal{S}_{obs}} \text{Poisson}(Y_i \mid \delta_i V_i) \cdot \text{LogNormal}(\delta_i \mid \mu_i, \sigma)\right] \cdot \prod_{j=1}^{Q} \mathcal{N}(\gamma_j \mid 0, \sigma_U^2) \cdot \prod_{k=1}^{P} \mathcal{N}(\beta_k \mid 0, 1) \cdot p(\sigma) \cdot p(\sigma_U)
$$

La distribución posterior no tiene forma analítica cerrada debido a la combinación de la distribución de Poisson para los conteos y la distribución log-normal para las densidades latentes. En consecuencia, la inferencia se realiza mediante métodos de Monte Carlo por cadenas de Markov (MCMC), específicamente mediante el algoritmo de Monte Carlo Hamiltoniano implementado en Stan, cuya descripción se desarrolla en el capítulo siguiente.

Las cantidades de interés inferencial se derivan directamente de la distribución posterior conjunta $p(\boldsymbol{\theta}, \boldsymbol{\delta} \mid \mathbf{Y}_{obs})$. Para cada segmento $i \in \mathcal{S}_{obs}$, la estimación puntual de la densidad poblacional se obtiene como la media posterior:

$$
\hat{\delta}_i = \mathbb{E}[\delta_i \mid \mathbf{Y}_{obs}] \approx \frac{1}{T} \sum_{t=1}^{T} \delta_i^{(t)}
$$

donde $\delta_i^{(1)}, \ldots, \delta_i^{(T)}$ son las muestras de la distribución posterior generadas mediante MCMC. Para los segmentos no observados $i \in \mathcal{S} \setminus \mathcal{S}_{obs}$, la predicción se obtiene generando muestras de la distribución predictiva posterior en el bloque de cantidades generadas del modelo:

$$
\tilde{\delta}_i^{(t)} \sim \text{LogNormal}\!\left(\mu_i^{(t)},\, \sigma^{(t)}\right), \qquad \tilde{Y}_i^{(t)} \sim \text{Poisson}\!\left(\tilde{\delta}_i^{(t)} \cdot V_i\right)
$$

donde $\mu_i^{(t)} = \mathbf{x}_i^{\top}\boldsymbol{\beta}^{(t)} + \mathbf{z}_i^{\top}\boldsymbol{\gamma}^{(t)}$ se evalúa utilizando los parámetros de la muestra $t$. Esta predicción se realiza sobre la totalidad de $\mathcal{S}$, lo que permite obtener estimaciones de población para todos los segmentos del país, incluidos aquellos sin cobertura censal directa.

La estimación del total de población de un nivel geográfico superior —municipio, departamento o país— se obtiene agregando las distribuciones predictivas posteriores de los segmentos que lo componen. Si $\mathcal{S}_k \subset \mathcal{S}$ denota el conjunto de segmentos del municipio $k$, el conteo total estimado para ese municipio —nivel (3) en la jerarquía geográfica utilizada en el Capítulo 1, donde el departamento corresponde al nivel (2) y el segmento censal al nivel (4)— es:

$$
\hat{N}_k^{(3)} = \sum_{i \in \mathcal{S}_k} \hat{N}_i, \qquad \hat{N}_i = \begin{cases} Y_i + \hat{Y}_i^{(aus)} & \text{si } i \in \mathcal{S}_{obs} \\ \tilde{Y}_i & \text{si } i \notin \mathcal{S}_{obs} \end{cases}
$$

donde $\hat{Y}_i^{(aus)}$ representa la predicción para las personas no observadas dentro de un segmento con cobertura parcial y $\tilde{Y}_i$ la predicción completa para segmentos sin cobertura. La incertidumbre de esta agregación se cuantifica mediante la distribución posterior del total, cuya varianza refleja simultáneamente la incertidumbre sobre los parámetros del modelo y la variabilidad del proceso de Poisson.

### Interpretación de parámetros

La interpretación de los parámetros del modelo Poisson-lognormal requiere considerar la escala en la que opera cada componente. Dado que la densidad poblacional $\delta_i$ sigue una distribución log-normal, el predictor lineal $\mu_i$ actúa sobre el logaritmo de la densidad, lo que implica que los coeficientes $\boldsymbol{\beta}$ y $\boldsymbol{\gamma}$ se interpretan en escala logarítmica.

Para los coeficientes de efectos fijos, el coeficiente $\beta_k$ representa el cambio esperado en el logaritmo de la densidad poblacional asociado a un incremento de una desviación estándar en la covariable estandarizada $\tilde{x}_{i,k}$, manteniendo constantes las demás covariables y los efectos aleatorios. Dado que $\mathbb{E}[\log \delta_i \mid \mu_i, \sigma] = \mu_i$ para la distribución log-normal, la derivada parcial del predictor lineal respecto a la covariable $k$ es directamente:

$$
\beta_k = \frac{\partial \mu_i}{\partial \tilde{x}_{i,k}}
$$

En escala multiplicativa, $\exp(\beta_k)$ representa el factor por el cual se multiplica la densidad mediana cuando la covariable $k$ aumenta en una desviación estándar. Valores de $\beta_k > 0$ indican que el segmento tiende a tener mayor densidad poblacional a medida que crece la covariable correspondiente; valores negativos indican la relación contraria.

Para los efectos aleatorios, el coeficiente $\gamma_j$ representa el ajuste territorial específico de la unidad geográfica superior $j$ una vez que el efecto de las covariables ha sido controlado. En escala multiplicativa, $\exp(\gamma_j)$ es el factor por el cual se ajusta la densidad de todos los segmentos pertenecientes al territorio $j$ respecto al nivel implícito en los efectos fijos. La distribución a priori $\gamma_j \sim \mathcal{N}(0, \sigma_U^2)$ impone que estos ajustes se concentren alrededor de cero con una variabilidad determinada por $\sigma_U$, lo que produce el efecto de encogimiento sobre territorios con escasa información.

El parámetro $\sigma$ controla la dispersión de las densidades $\delta_i$ alrededor de su media condicional $\exp(\mu_i + \sigma^2/2)$. En escala logarítmica, $\sigma$ corresponde a la desviación estándar de $\log \delta_i$; valores grandes de $\sigma$ indican alta heterogeneidad residual en las densidades no explicada por las covariables ni por los efectos aleatorios. El hiperparámetro $\sigma_U$ cuantifica, por su parte, la dispersión de los efectos aleatorios entre unidades territoriales: valores grandes de $\sigma_U$ indican que los territorios presentan densidades sistemáticamente distintas incluso después de controlar por las covariables auxiliares.

Finalmente, la densidad latente $\delta_i$ tiene una interpretación demográfica directa: representa el número estimado de personas por estructura habitacional en el segmento $i$. Este parámetro puede utilizarse para comparar la intensidad de ocupación habitacional entre segmentos, identificar áreas de alta concentración y construir predicciones de población condicionadas al número de estructuras disponibles. Su distribución posterior provee una medida de incertidumbre que refleja tanto la variabilidad del conteo observado como la posición del segmento en la distribución log-normal especificada por el modelo.

## Componentes del modelo

La especificación completa del modelo Poisson-lognormal requiere detallar la construcción de cada uno de sus componentes estructurales. El predictor lineal $\mu_i = \mathbf{x}_i^{\top}\boldsymbol{\beta} + \mathbf{z}_i^{\top}\boldsymbol{\gamma}$ integra dos tipos de información: efectos sistemáticos capturados por las covariables auxiliares a través de los efectos fijos, y ajustes territoriales no explicados por dichas covariables a través de los efectos aleatorios. Estos componentes interactúan con el offset de estructuras $V_i$ y con el mecanismo de sobredispersión log-normal para producir estimaciones coherentes en el conjunto completo de segmentos.

### Efectos fijos

Los efectos fijos del modelo capturan la relación sistemática entre las covariables auxiliares y la densidad poblacional. Sea $\mathbf{X}_{obs}$ la matriz de covariables de dimensión $D_{obs} \times P$, donde la fila $i$ corresponde al vector $\mathbf{x}_i^{\top}$ del segmento observado $i$ y las columnas corresponden a las $P$ covariables seleccionadas tras el proceso de preparación de insumos descrito en el capítulo anterior. Análogamente, $\mathbf{X}_{tot}$ es la matriz de covariables de dimensión $D \times P$ que contiene los vectores de covariables para la totalidad de los segmentos del país, incluyendo aquellos no observados en el operativo censal.

El predictor lineal de efectos fijos para el segmento $i$ es:

$$
\left(\mathbf{X}_{obs}\boldsymbol{\beta}\right)_i = \sum_{k=1}^{P} \beta_k\, \tilde{x}_{i,k}
$$

donde $\tilde{x}_{i,k}$ denota la versión estandarizada de la covariable $k$ en el segmento $i$, construida mediante las transformaciones descritas en el capítulo anterior: estandarización por media y desviación estándar para variables continuas simétricas, transformación logarítmica para variables de conteo con cola derecha, o normalización al intervalo unitario para índices y proporciones.

Las covariables incorporadas en $\mathbf{X}_{obs}$ se organizan en las tres categorías descritas en el capítulo de integración de fuentes. Las variables demográficas incluyen el tamaño medio del hogar, la razón de masculinidad y las proporciones de grupos etarios específicos. Las variables socioeconómicas incluyen índices de necesidades básicas insatisfechas, tasas de acceso a servicios públicos —electricidad, agua potable, internet— y conteos provenientes de registros administrativos como padrones electorales o afiliados a sistemas de salud. Las variables espaciales de origen satelital incluyen la luminosidad nocturna media del segmento $L_i$, el área construida derivada del producto Global Human Settlement Layer, la proporción de distintas categorías de cobertura de suelo, la pendiente media del terreno y la altitud media sobre el nivel del mar.

Un aspecto crítico en la especificación de los efectos fijos es el tratamiento de la multicolinealidad entre covariables. Dado que muchas de las fuentes auxiliares descritas están correlacionadas entre sí —la luminosidad nocturna y el área construida tienden a ser altas en las mismas zonas urbanas, y el número de registros administrativos crece con la población—, la inclusión simultánea de variables altamente correlacionadas puede dificultar la estimación individual de los coeficientes. En la práctica, esto se aborda mediante análisis de correlación previo a la estimación y selección de variables basada en criterios estadísticos, complementados por el efecto regularizador de las distribuciones a priori $\beta_k \sim \mathcal{N}(0,1)$, que penalizan moderadamente los coeficientes de gran magnitud y estabilizan la estimación en presencia de predictores correlacionados.

La estimación del vector $\boldsymbol{\beta}$ a partir de los datos proporciona información sobre cuáles características del segmento están más fuertemente asociadas con la densidad poblacional. Esta información puede utilizarse para orientar la actualización cartográfica, priorizar la recolección de covariables en futuros operativos censales y validar la consistencia de las fuentes utilizadas con los patrones demográficos observados en el territorio.

### Efectos aleatorios

Los efectos aleatorios capturan la variabilidad sistemática entre unidades territoriales de nivel superior que no es explicada por las covariables auxiliares incluidas en los efectos fijos. Esta variabilidad puede deberse a factores institucionales no medidos —diferencias en la capacidad operativa de los equipos censales entre provincias, por ejemplo—, a condiciones locales no capturadas por las fuentes disponibles, o a características territoriales latentes que afectan simultáneamente a múltiples segmentos de una misma unidad.

Sea $\mathbf{Z}_{obs}$ la matriz de indicadores de dimensión $D_{obs} \times Q$, donde $Q$ es el número de unidades territoriales de nivel superior consideradas. El elemento $z_{i,j}$ vale uno si el segmento $i$ pertenece a la unidad territorial $j$ y cero en caso contrario. Análogamente, $\mathbf{Z}_{tot}$ es la matriz de indicadores de dimensión $D \times Q$ para el conjunto completo de segmentos. La contribución de los efectos aleatorios al predictor lineal del segmento $i$ es:

$$
\left(\mathbf{Z}_{obs}\boldsymbol{\gamma}\right)_i = \sum_{j=1}^{Q} z_{i,j}\,\gamma_j = \gamma_{j(i)}
$$

donde $j(i)$ denota la unidad territorial a la que pertenece el segmento $i$. Dado que cada segmento pertenece a exactamente una unidad territorial, la contribución de los efectos aleatorios es simplemente el coeficiente $\gamma_{j(i)}$ correspondiente a su territorio.

La distribución a priori jerárquica $\gamma_j \sim \mathcal{N}(0, \sigma_U^2)$ regula el comportamiento de los efectos aleatorios a través del hiperparámetro $\sigma_U$. Cuando $\sigma_U$ es pequeño, el modelo impone que los efectos aleatorios sean cercanos a cero, lo que es equivalente a una especificación sin ajustes territoriales específicos. Cuando $\sigma_U$ es grande, los efectos aleatorios pueden tomar valores sustanciales, capturando diferencias importantes entre territorios no explicadas por las covariables. La estimación conjunta de $\sigma_U$ y $\boldsymbol{\gamma}$ permite que el modelo aprenda automáticamente el grado de heterogeneidad territorial presente en los datos.

Una propiedad fundamental de la estructura jerárquica es el préstamo de fortaleza entre segmentos de un mismo territorio. Los segmentos con escasa información —conteos muy bajos, alta variabilidad en el conteo observado o baja cobertura censal— son estabilizados por la información de los demás segmentos de la misma unidad territorial, a través del efecto aleatorio compartido $\gamma_{j(i)}$. Simultáneamente, los efectos fijos proveen información de todos los segmentos del país para estimar el vector $\boldsymbol{\beta}$, que contribuye a la predicción en segmentos con poca o ninguna cobertura censal. Este mecanismo de préstamo de información entre dominios constituye una de las principales ventajas del enfoque jerárquico bayesiano sobre los métodos de estimación directa.

La estructura de efectos aleatorios puede extenderse a múltiples niveles territoriales. En las aplicaciones sobre censos de América Latina y el Caribe desarrolladas en el marco de este libro, los efectos aleatorios se han especificado sobre provincias, departamentos o regiones, que constituyen la unidad administrativa intermedia más relevante para la gestión censal. En países con censos de alta resolución cartográfica y disponibilidad de datos administrativos a nivel de municipio, es posible incorporar efectos aleatorios anidados que capturen simultáneamente variabilidad regional y municipal, a costa de mayor complejidad computacional y mayor exigencia de información.

### Interacciones

El predictor lineal en su forma básica representa efectos aditivos y lineales de las covariables sobre el logaritmo de la densidad poblacional. En determinados contextos, la relación entre las covariables y la densidad puede presentar patrones no lineales o interacciones que requieren representación explícita en el modelo.

Las interacciones entre covariables se incorporan mediante la inclusión de productos entre variables estandarizadas en la matriz $\mathbf{X}_{obs}$. Si $\tilde{x}_{i,k}$ y $\tilde{x}_{i,l}$ son dos covariables estandarizadas, su término de interacción se define como:

$$
\tilde{x}_{i,kl} = \tilde{x}_{i,k} \cdot \tilde{x}_{i,l}
$$

El predictor lineal extendido con interacciones incluye un coeficiente adicional $\beta_{kl}$ con distribución a priori $\beta_{kl} \sim \mathcal{N}(0, 1)$, tratando el término de interacción de manera simétrica a los efectos principales. Esta formulación es apropiada cuando las covariables están estandarizadas, ya que garantiza que los términos de interacción operen en una escala comparable a los efectos principales.

En el contexto de la estimación de conteos censales, las interacciones de mayor relevancia sustantiva suelen involucrar combinaciones entre variables de uso del suelo y clasificaciones territoriales —la interacción entre luminosidad nocturna y la condición urbano-rural puede capturar diferencias en el patrón de ocupación habitacional según el tipo de asentamiento— o entre variables demográficas y socioeconómicas, como la relación entre el tamaño medio del hogar y el acceso a servicios públicos, cuya dirección puede variar sistemáticamente entre contextos urbanos y rurales.

Las interacciones entre efectos fijos y efectos aleatorios, conocidas como efectos de pendiente aleatoria, permiten que la relación de una covariable con la densidad varíe entre territorios. En esta especificación extendida, el coeficiente de la covariable $k$ en el territorio $j$ es $\beta_k + \nu_{j,k}$, donde $\nu_{j,k}$ representa la desviación específica del territorio respecto al efecto promedio nacional. Esta extensión aumenta la flexibilidad del modelo a costa de mayor dimensionalidad y puede resultar útil cuando se sospecha que el efecto de un predictor varía sistemáticamente entre regiones del país.

La inclusión de términos de interacción debe equilibrar la mejora en el ajuste del modelo con el riesgo de sobreajuste en datos de alta dimensión. En la práctica, la selección de interacciones relevantes se evalúa mediante criterios de comparación de modelos como el criterio LOO-CV o el WAIC, cuyas bases se desarrollan en el capítulo dedicado al diagnóstico y validación.

### Sobredispersión, offset y alternativas distribucionales

El diseño del modelo Poisson-lognormal incorpora tres elementos adicionales que merecen consideración específica: el mecanismo de control de sobredispersión a través de la distribución log-normal, el uso del número de estructuras como offset del proceso de conteo, y las alternativas distribucionales consideradas frente al modelo propuesto.

**El offset de estructuras habitacionales.** El número de estructuras habitacionales $V_i$ desempeña el papel de offset en el modelo: escala la intensidad del proceso de Poisson de manera proporcional al tamaño del segmento en términos de unidades habitacionales. Formalmente, el modelo puede reescribirse como:

$$
\log(\lambda_i) = \log(\delta_i) + \log(V_i) = \mu_i + \varepsilon_i + \log(V_i)
$$

donde $\varepsilon_i = \log(\delta_i) - \mu_i \sim \mathcal{N}(0, \sigma^2)$ es el error log-normal. El término $\log(V_i)$ actúa como offset con coeficiente fijado en uno, lo que equivale a modelar la densidad —y no el conteo total— como función de las covariables. Esta parametrización es estadísticamente más apropiada que incluir $\log(V_i)$ como covariable con coeficiente libre, ya que el número de estructuras debe considerarse una referencia de escala del proceso y no un predictor ordinario del logaritmo de la densidad.

La fuente del offset puede variar según la disponibilidad de información. En segmentos con preconteo operativo, $V_i$ corresponde directamente al número de viviendas registradas durante la actualización cartográfica previa al censo. En segmentos sin preconteo o con preconteo desactualizado por cambios demográficos recientes, $V_i$ puede aproximarse mediante el número de estructuras identificadas en imágenes satelitales. La calidad de la estimación final depende directamente de la precisión de $V_i$, dado que errores en el offset se propagan directamente hacia las predicciones de conteo en todo el conjunto de segmentos.

**El mecanismo de sobredispersión log-normal.** La inclusión de la densidad latente $\delta_i$ con distribución log-normal constituye el principal mecanismo de control de sobredispersión del modelo. Bajo un modelo de Poisson puro sin densidad latente y con predictor lineal fijo, se tendría $\text{Var}(Y_i) = \mathbb{E}[Y_i] = \lambda_i$. La introducción de $\delta_i$ log-normal rompe esta restricción de equidispersión e induce la varianza marginal presentada en la sección anterior, cuyo exceso sobre la media es estrictamente positivo para $\sigma > 0$. El parámetro $\sigma$ controla directamente este exceso: a mayor $\sigma$, mayor sobredispersión relativa. Esta parametrización permite que el modelo se adapte automáticamente al nivel de variabilidad presente en los datos, sin requerir la especificación a priori del grado de sobredispersión.

**Restricción de la densidad en predicción.** En la implementación práctica del modelo, la densidad predicha para segmentos no observados se trunca superiormente con el objetivo de evitar predicciones demográficamente implausibles en segmentos con alto valor del predictor lineal. Concretamente, se aplica la restricción:

$$
\tilde{\delta}_i = \min\!\left(\delta_i^*,\, \delta_{\max}\right)
$$

donde $\delta_i^*$ es la densidad generada por la distribución log-normal predictiva y $\delta_{\max}$ es un valor máximo admisible definido a partir del conocimiento experto sobre los rangos plausibles de ocupación habitacional en el contexto regional. En la práctica, $\delta_{\max}$ se determina a partir de la distribución empírica de las densidades observadas en $\mathcal{S}_{obs}$: un valor habitual es el percentil 99 de $\{\delta_i : i \in \mathcal{S}_{obs}\}$ o un umbral redondo —por ejemplo, 20 personas por estructura— que refleje el máximo demográficamente plausible para el país en cuestión. Esta restricción previene que la combinación de un predictor lineal alto y variabilidad log-normal genere densidades que, multiplicadas por el número de estructuras, produzcan conteos individuales que superen toda referencia demográfica razonable.

**Alternativas distribucionales.** El modelo binomial negativo constituye la alternativa distribucional más natural al modelo Poisson-lognormal para el tratamiento de la sobredispersión. Bajo esta especificación, el conteo observado sigue directamente una distribución binomial negativa con media $\mu_i$ y parámetro de dispersión $\phi$:

$$
Y_i \mid \mu_i, \phi \sim \text{NegBin}(\mu_i,\, \phi), \qquad \text{Var}(Y_i) = \mu_i + \frac{\mu_i^2}{\phi}
$$

donde $\mu_i = \exp(\mathbf{x}_i^{\top}\boldsymbol{\beta} + \mathbf{z}_i^{\top}\boldsymbol{\gamma}) \cdot V_i$ incorpora el offset de estructuras. La diferencia fundamental respecto al modelo Poisson-lognormal reside en que la binomial negativa modela la sobredispersión mediante un único parámetro global $\phi$, mientras que la log-normal permite heterogeneidad individual de la densidad a través del parámetro latente $\delta_i$. Esta última propiedad hace del modelo Poisson-lognormal una opción más flexible para contextos con alta variabilidad territorial y disponibilidad de información a nivel de estructura habitacional.

Un modelo de Poisson con efectos aleatorios gaussianos no estructurados en el predictor lineal —sin el componente de densidad latente— constituye una alternativa computacionalmente más sencilla que puede resultar apropiada cuando la sobredispersión es moderada. En ese caso, el predictor lineal incluye un término de error no estructurado $u_i \sim \mathcal{N}(0, \sigma_u^2)$ que absorbe la variabilidad residual no capturada por los efectos fijos ni por los efectos aleatorios territoriales:

$$
\log(\lambda_i) = \mathbf{x}_i^{\top}\boldsymbol{\beta} + \mathbf{z}_i^{\top}\boldsymbol{\gamma} + u_i + \log(V_i)
$$

La elección entre estas especificaciones debe fundamentarse en el diagnóstico exploratorio de los datos —en particular, en la relación empírica entre la media y la varianza de los conteos por segmento— y en la comparación posterior mediante criterios de información. En contextos con elevada variabilidad territorial, alta proporción de segmentos con baja cobertura y disponibilidad de información sobre el número de estructuras, el modelo Poisson-lognormal con offset representa la especificación estadísticamente más apropiada para la estimación subnacional de conteos poblacionales en segmentos censales, y ha mostrado buen desempeño en las aplicaciones desarrolladas sobre censos de América Latina y el Caribe que sirven de referencia para este libro.
