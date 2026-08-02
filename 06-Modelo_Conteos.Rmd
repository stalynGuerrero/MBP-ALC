# Modelo para Conteos Poblacionales {#cap-conteos}

Los capítulos precedentes han establecido el marco conceptual de la estimación subnacional, identificado las fuentes de información disponibles y detallado el proceso de construcción de los insumos analíticos. Sobre esta base, el presente capítulo introduce la especificación formal del modelo estadístico que integra dichos elementos bajo un esquema probabilístico coherente, orientado a estimar los conteos de población en segmentos censales con cobertura parcial o incompleta.

La formulación adoptada debe satisfacer los requerimientos establecidos en capítulos anteriores: representar adecuadamente la naturaleza discreta y no negativa de los conteos, incorporar información auxiliar de fuentes heterogéneas, producir estimaciones en dominios sin cobertura directa y cuantificar explícitamente la incertidumbre de los resultados. Frente a estos requerimientos, un modelo de Poisson simple resulta insuficiente cuando los datos exhiben sobredispersión o cuando se dispone de información de referencia sobre el número de estructuras habitacionales en cada segmento. La extensión log-normal del modelo de Poisson, articulada con una estructura jerárquica de efectos aleatorios, responde a estas limitaciones de manera estadísticamente coherente.

El modelo propuesto opera en dos niveles. En el primer nivel, la densidad poblacional —definida como el número de personas por estructura habitacional— se representa mediante una distribución log-normal cuyo parámetro de localización es función lineal de covariables auxiliares y efectos aleatorios territoriales. En el segundo nivel, los conteos de población observados se modelan como realizaciones de una distribución de Poisson cuyo parámetro de intensidad resulta del producto entre la densidad estimada y el número de estructuras en cada segmento. Esta arquitectura de dos etapas constituye el modelo Poisson-lognormal y provee un mecanismo natural de control de la sobredispersión mientras mantiene la interpretabilidad de los parámetros [@BryantGraham2013; @Mercer2015].

La estructura del capítulo se organiza en dos secciones principales. La primera presenta la especificación probabilística completa del modelo: definición formal, función de verosimilitud, distribuciones previas, distribución posterior e interpretación de parámetros. La segunda describe en detalle los componentes del modelo: efectos fijos, efectos aleatorios, mecanismos de interacción y elementos adicionales como el offset y la sobredispersión.

## Modelo Poisson-lognormal

Esta sección desarrolla la especificación probabilística completa del modelo Poisson-lognormal introducido anteriormente. Se parte de la definición formal de sus componentes observados y latentes, se deriva la función de verosimilitud conjunta que los articula, se establecen las distribuciones previas de cada parámetro estructural y se caracteriza la distribución posterior resultante. El recorrido cierra con la interpretación sustantiva de los parámetros estimados, de modo que la formulación matemática quede conectada con su lectura demográfica.

### Definición formal {#definicion-formal}

Sea $\mathcal{S}=\{1,\ldots,D\}$ el conjunto de todos los segmentos censales del país, donde $D=|\mathcal{S}|$ representa el número total de segmentos. En este capítulo se utiliza la notación $D$ para el número de segmentos, en reemplazo de la notación $I$ empleada en los Capítulos \@ref(cap-modelos-poblacion) y \@ref(cap-insumos), con el propósito de mantener consistencia con la implementación computacional presentada en el Capítulo \@ref(stan-implementacion). En consecuencia, se utilizarán las cantidades $D_{obs}$ y $D_{tot}$ para denotar, respectivamente, el número de segmentos observados y el número total de segmentos considerados en el análisis.

Para cada segmento censal $i \in \mathcal{S}$ se consideran dos cantidades fundamentales. La primera corresponde al conteo de población observado, denotado por $Y_i$, el cual únicamente está disponible para los segmentos que alcanzaron cobertura efectiva durante el operativo censal. La segunda corresponde al número de estructuras habitacionales, denotado por $V_i$, disponible para todos los segmentos del país. Esta variable proviene del preconteo operativo descrito en el Capítulo \@ref(cap-integracion) o, cuando este no se encuentra disponible, puede derivarse de fuentes auxiliares basadas en imágenes satelitales y estimaciones de área construida.

El objetivo del modelo consiste en describir la relación entre ambas cantidades mediante una tasa promedio de ocupación poblacional por estructura habitacional. Esta razón se denota por

$$
\delta_i=\frac{N_i}{V_i},
$$

donde $N_i$ representa la población verdadera del segmento $i$. La notación $\delta_i$ se adopta para evitar confusión con la densidad poblacional por unidad de área,

$$
\text{DP}_i=\frac{N_i}{A_i},
$$

introducida en el Capítulo \@ref(cap-modelos-poblacion), la cual responde a un concepto diferente. Mientras $\text{DP}_i$ mide el número de personas por unidad de superficie, $\delta_i$ representa el número esperado de personas por estructura habitacional y constituye el parámetro central de los modelos desarrollados en este capítulo. Nótese además que $\text{DP}_i$ no guarda relación alguna con la cardinalidad $D=|\mathcal{S}|$ definida al inicio de esta sección: una es una medida de densidad por segmento, la otra es el número total de segmentos del país.


### Función de verosimilitud {#funcion-verosimilitud}

La inferencia del modelo se basa exclusivamente en la información disponible para los segmentos censales observados durante el operativo de campo. Sea

$$
\mathcal{S}_{obs}\subseteq\mathcal{S}
$$

el conjunto de segmentos con cobertura efectiva, para los cuales se dispone simultáneamente del conteo de población observado $Y_i$ y del número de estructuras habitacionales $V_i$. Los segmentos no observados no aportan información directa a la verosimilitud, puesto que el conteo poblacional es desconocido. Su estimación se realiza posteriormente mediante la distribución predictiva posterior.

En cada segmento observado, el modelo supone que el conteo poblacional se genera mediante un proceso de Poisson cuya intensidad depende de una densidad poblacional latente por estructura habitacional,

$$
Y_i\mid \delta_i,V_i
\sim
\text{Poisson}(\delta_iV_i),
$$

donde $\delta_i$ representa el número esperado de personas por estructura habitacional. Esta cantidad no es observable y constituye el parámetro fundamental del modelo, ya que captura la heterogeneidad existente entre segmentos censales con características similares.

A diferencia del modelo Poisson clásico, donde la intensidad es un parámetro fijo, el modelo Poisson-lognormal considera que cada $\delta_i$ es una realización de una distribución log-normal,

$$
\delta_i \mid \mu_i, \sigma \;\sim\; \text{LogNormal}(\mu_i,\, \sigma),
$$

de manera que la variabilidad entre segmentos queda incorporada explícitamente en la estructura probabilística del modelo. El parámetro de localización

$$
\mu_i = \mathbf{x}_i^{\top}\boldsymbol{\beta} + \mathbf{z}_i^{\top}\boldsymbol{\gamma}
$$

resume la contribución de las variables auxiliares disponibles a través de los efectos fijos $\boldsymbol{\beta}$ y el ajuste territorial no explicado por dichas covariables a través de los efectos aleatorios $\boldsymbol{\gamma}$, mientras que $\sigma$ cuantifica la variabilidad residual entre segmentos una vez explicados ambos efectos.

Bajo esta formulación jerárquica, la información observada se encuentra completamente determinada por dos componentes probabilísticos: el modelo de generación de los conteos y el modelo de variación de las densidades latentes. Asumiendo independencia condicional entre segmentos dado el conjunto de parámetros estructurales

$$
\boldsymbol{\theta} = (\boldsymbol{\beta},\, \boldsymbol{\gamma},\, \sigma,\, \sigma_U),
$$

la distribución conjunta factoriza como

$$
p(\mathbf{Y}_{obs},\boldsymbol{\delta}\mid\boldsymbol{\theta}) = \prod_{i\in\mathcal{S}_{obs}} p(Y_i\mid\delta_i,V_i) \cdot p(\delta_i\mid\mu_i,\sigma),
$$

donde $\mathbf{Y}_{obs} = \{Y_i : i\in\mathcal{S}_{obs}\}$ denota el vector de conteos observados y $\boldsymbol{\delta} = \{\delta_i : i\in\mathcal{S}_{obs}\}$ el conjunto de densidades latentes asociadas a dichos segmentos.

Sustituyendo las expresiones funcionales de las distribuciones Poisson y log-normal se obtiene

$$
p(\mathbf{Y}_{obs},\boldsymbol{\delta}\mid\boldsymbol{\theta}) = \prod_{i\in\mathcal{S}_{obs}} \frac{e^{-\delta_iV_i}(\delta_iV_i)^{Y_i}}{Y_i!} \cdot \frac{1}{\delta_i\sigma\sqrt{2\pi}} \exp\!\left(-\frac{(\log\delta_i-\mu_i)^2}{2\sigma^2}\right).
(\#eq:verosimilitud-conjunta)
$$

La primera contribución corresponde al mecanismo de generación de los conteos observados, mientras que la segunda describe la distribución de las densidades poblacionales entre segmentos. La función de verosimilitud refleja, por tanto, el compromiso entre reproducir los conteos efectivamente observados y mantener valores plausibles para las densidades de acuerdo con el modelo estructural.

Trabajar sobre la escala logarítmica simplifica considerablemente la inferencia, ya que transforma el producto de densidades en una suma de contribuciones individuales. Partiendo de la verosimilitud conjunta de la Ecuación \@ref(eq:verosimilitud-conjunta), se aplica el logaritmo natural a ambos lados,

$$
\log p(\mathbf{Y}_{obs},\boldsymbol{\delta}\mid\boldsymbol{\theta}) = \log \left[\prod_{i\in\mathcal{S}_{obs}} \frac{e^{-\delta_iV_i}(\delta_iV_i)^{Y_i}}{Y_i!} \cdot \frac{1}{\delta_i\sigma\sqrt{2\pi}} \exp\!\left(-\frac{(\log\delta_i-\mu_i)^2}{2\sigma^2}\right)\right].
$$

Utilizando la propiedad

$$
\log\left(\prod_i a_i\right) = \sum_i\log(a_i),
$$

la expresión anterior puede escribirse como

$$
\log p(\mathbf{Y}_{obs},\boldsymbol{\delta}\mid\boldsymbol{\theta}) = \sum_{i\in\mathcal{S}_{obs}} \log \left[\frac{e^{-\delta_iV_i}(\delta_iV_i)^{Y_i}}{Y_i!} \cdot \frac{1}{\delta_i\sigma\sqrt{2\pi}} \exp\!\left(-\frac{(\log\delta_i-\mu_i)^2}{2\sigma^2}\right)\right].
$$

Posteriormente, el logaritmo de un producto se separa en la suma de los logaritmos,

$$
\log p(\mathbf{Y}_{obs},\boldsymbol{\delta}\mid\boldsymbol{\theta}) = \sum_{i\in\mathcal{S}_{obs}} \left[\log\left(\frac{e^{-\delta_iV_i}(\delta_iV_i)^{Y_i}}{Y_i!}\right) + \log\left(\frac{1}{\delta_i\sigma\sqrt{2\pi}}\exp\!\left(-\frac{(\log\delta_i-\mu_i)^2}{2\sigma^2}\right)\right)\right].
$$

Ahora se desarrolla cada uno de estos términos por separado.

Para la componente Poisson,

$$
\begin{aligned}
\log\left(\frac{e^{-\delta_iV_i}(\delta_iV_i)^{Y_i}}{Y_i!}\right)
&= \log(e^{-\delta_iV_i}) + \log\!\left((\delta_iV_i)^{Y_i}\right) - \log(Y_i!) \\
&= -\delta_iV_i + Y_i\log(\delta_iV_i) - \log(Y_i!).
\end{aligned}
$$

Para la componente log-normal,

$$
\begin{aligned}
\log\left(\frac{1}{\delta_i\sigma\sqrt{2\pi}}\exp\!\left(-\frac{(\log\delta_i-\mu_i)^2}{2\sigma^2}\right)\right)
&= -\log(\delta_i) - \log(\sigma) - \frac{1}{2}\log(2\pi) \\
&\qquad - \frac{(\log\delta_i-\mu_i)^2}{2\sigma^2}.
\end{aligned}
$$

Sustituyendo ambos desarrollos en la expresión anterior se obtiene

$$
\begin{aligned}
\log p(\mathbf{Y}_{obs},\boldsymbol{\delta}\mid\boldsymbol{\theta}) = \sum_{i\in\mathcal{S}_{obs}} \Bigg[
&Y_i\log(\delta_iV_i) -\delta_iV_i -\log(Y_i!) \\
&-\log(\delta_i) -\log(\sigma) -\frac{1}{2}\log(2\pi) \\
&-\frac{(\log\delta_i-\mu_i)^2}{2\sigma^2}\Bigg].
\end{aligned}
$$

Finalmente, dado que los términos

$$
\log(Y_i!) \qquad\text{y}\qquad \frac{1}{2}\log(2\pi)
$$

no dependen de ninguno de los parámetros del modelo, pueden agruparse dentro de una constante aditiva. Como la inferencia bayesiana y la optimización dependen únicamente de cantidades proporcionales a la verosimilitud, estas constantes pueden omitirse, obteniéndose la log-verosimilitud

$$
\log p(\mathbf{Y}_{obs},\boldsymbol{\delta}\mid\boldsymbol{\theta}) = \sum_{i\in\mathcal{S}_{obs}} \left[Y_i\log(\delta_iV_i) -\delta_iV_i -\log(\delta_i) -\frac{(\log\delta_i-\mu_i)^2}{2\sigma^2} -\log(\sigma)\right].
$$

Cada uno de estos términos posee una interpretación estadística directa. El componente

$$
Y_i\log(\delta_iV_i)-\delta_iV_i
$$

proviene de la distribución de Poisson y mide el grado de concordancia entre la intensidad propuesta por el modelo y el conteo efectivamente observado. El término cuadrático

$$
-\frac{(\log\delta_i-\mu_i)^2}{2\sigma^2}
$$

corresponde a la penalización inducida por la distribución log-normal y favorece densidades compatibles con la información auxiliar incorporada mediante el predictor lineal. Finalmente, el término

$$
-\log\delta_i
$$

es consecuencia del jacobiano asociado al cambio de variable entre la escala logarítmica y la escala original de las densidades, garantizando que la distribución log-normal quede correctamente normalizada.

Desde una perspectiva bayesiana, esta función constituye el mecanismo mediante el cual la información observada actualiza el conocimiento previo sobre las densidades poblacionales. Los valores de $\delta_i$ que maximizan la contribución Poisson pueden diferir de aquellos sugeridos por la estructura log-normal; la estimación posterior resulta precisamente del equilibrio entre ambas fuentes de información.

Una característica fundamental del modelo Poisson-lognormal es que la distribución marginal de los conteos ya no pertenece a la familia Poisson. Dado que la intensidad $\delta_i$ es una variable aleatoria, la distribución marginal de $Y_i$ se obtiene integrando respecto a la distribución de las densidades latentes,

$$
p(Y_i\mid\boldsymbol{\theta}) = \int_0^\infty p(Y_i\mid\delta_i,V_i) \cdot p(\delta_i\mid\mu_i,\sigma) \, d\delta_i.
$$

Sustituyendo las distribuciones del modelo,

$$
Y_i\mid\delta_i \sim \text{Poisson}(\delta_iV_i),
$$

y

$$
\delta_i \sim \text{LogNormal}(\mu_i,\sigma),
$$

se obtiene

$$
p(Y_i\mid\boldsymbol{\theta}) = \int_0^\infty \frac{e^{-\delta_iV_i}(\delta_iV_i)^{Y_i}}{Y_i!} \cdot \frac{1}{\delta_i\sigma\sqrt{2\pi}} \exp\!\left(-\frac{(\log\delta_i-\mu_i)^2}{2\sigma^2}\right) \, d\delta_i.
$$

Esta integral no posee una solución analítica cerrada, por lo que la distribución marginal no pertenece a una familia paramétrica simple. Sin embargo, sus primeros momentos —consistentes con los reportados para la mezcla Poisson-lognormal en modelos bayesianos de estimación subnacional [@BryantGraham2013; @Mercer2015]— pueden obtenerse utilizando las propiedades de la esperanza y la varianza condicionales, sin necesidad de resolver la integral directamente.

La media marginal se obtiene aplicando la ley de la esperanza total,

$$
\mathbb{E}[Y_i] = \mathbb{E}\left[\mathbb{E}(Y_i\mid\delta_i)\right].
$$

Como $Y_i\mid\delta_i \sim \text{Poisson}(\delta_iV_i)$, se tiene $\mathbb{E}(Y_i\mid\delta_i) = \delta_iV_i$, de modo que

$$
\mathbb{E}[Y_i] = \mathbb{E}[\delta_iV_i] = V_i\, \mathbb{E}[\delta_i],
$$

dado que $V_i$ es conocido. Y puesto que $\delta_i \sim \text{LogNormal}(\mu_i,\sigma)$, su primer momento es $\mathbb{E}[\delta_i] = \exp\!\left(\mu_i+\frac{\sigma^2}{2}\right)$, con lo que la media marginal del conteo queda determinada por

$$
\mathbb{E}[Y_i] = V_i \exp\!\left(\mu_i+\frac{\sigma^2}{2}\right).
$$

La varianza marginal se deriva de manera análoga, apoyándose esta vez en la ley de la varianza total,

$$
\operatorname{Var}(Y_i) = \mathbb{E}\left[\operatorname{Var}(Y_i\mid\delta_i)\right] + \operatorname{Var}\left[\mathbb{E}(Y_i\mid\delta_i)\right],
$$

cuyos dos términos conviene desarrollar por separado. El primero recoge la variabilidad propia del proceso Poisson: dado que su varianza condicional coincide con su media, $\operatorname{Var}(Y_i\mid\delta_i) = \delta_iV_i$, y reutilizando el primer momento de la log-normal calculado arriba,

$$
\mathbb{E}\left[\operatorname{Var}(Y_i\mid\delta_i)\right] = V_i\, \mathbb{E}[\delta_i] = V_i \exp\!\left(\mu_i+\frac{\sigma^2}{2}\right),
$$

expresión que coincide exactamente con $\mathbb{E}[Y_i]$. El segundo término recoge, en cambio, la variabilidad que aporta la propia densidad latente: como $\mathbb{E}(Y_i\mid\delta_i) = \delta_iV_i$ y $V_i$ es constante,

$$
\operatorname{Var}\left[\mathbb{E}(Y_i\mid\delta_i)\right] = \operatorname{Var}(\delta_iV_i) = V_i^2\, \operatorname{Var}(\delta_i),
$$

y dado que la varianza de una log-normal es $\operatorname{Var}(\delta_i) = e^{2\mu_i+\sigma^2}\left(e^{\sigma^2}-1\right)$, se sigue que

$$
\operatorname{Var}\left[\mathbb{E}(Y_i\mid\delta_i)\right] = V_i^2\, e^{2\mu_i+\sigma^2}\left(e^{\sigma^2}-1\right).
$$

Sustituyendo ambos términos en la ley de la varianza total,

$$
\operatorname{Var}(Y_i) = \mathbb{E}[Y_i] + V_i^2\, e^{2\mu_i+\sigma^2}\left(e^{\sigma^2}-1\right).
$$

La expresión anterior muestra que la varianza marginal está compuesta por dos fuentes de variabilidad. El primer término, $\mathbb{E}[Y_i]$, corresponde a la variabilidad inherente del proceso Poisson. El segundo, $V_i^2\, e^{2\mu_i+\sigma^2}\left(e^{\sigma^2}-1\right)$, representa la variabilidad adicional introducida por la heterogeneidad de las densidades poblacionales entre segmentos. Este componente desaparece únicamente cuando $\sigma=0$, caso en el cual la distribución log-normal degenera en una constante y el modelo se reduce exactamente a un modelo Poisson clásico.

Dado que $\text{Var}(Y_i) > \mathbb{E}[Y_i]$ siempre que $\sigma > 0$, el modelo incorpora de manera natural sobredispersión respecto a la distribución Poisson clásica, con el grado de sobredispersión controlado directamente por $\sigma$: cuando $\sigma\rightarrow0$, la distribución log-normal degenera en un punto y el modelo converge al modelo Poisson estándar; a medida que $\sigma$ aumenta, la heterogeneidad entre segmentos se incrementa y la distribución marginal de los conteos presenta colas más pesadas y una varianza considerablemente mayor que la media. Esta propiedad resulta especialmente adecuada para datos censales, donde las diferencias locales en composición demográfica, ocupación de viviendas y patrones de asentamiento producen variabilidad que difícilmente puede ser explicada bajo el supuesto de equidispersión propio del modelo Poisson clásico [@Gelman2013].


### Distribuciones previas {#distribuciones-previas}

La especificación bayesiana del modelo requiere asignar distribuciones previas a todos los parámetros desconocidos. En el contexto del modelo Poisson-lognormal, el conjunto de parámetros a los que se asignan distribuciones previas incluye los coeficientes de efectos fijos $\boldsymbol{\beta}$, los coeficientes de efectos aleatorios $\boldsymbol{\gamma}$, el parámetro de escala de la densidad $\sigma$ y el hiperparámetro de variabilidad de los efectos aleatorios $\sigma_U$.

El enfoque adoptado en este libro utiliza distribuciones previas no informativas: normales centradas en cero con varianza grande —normales planas— para los parámetros definidos sobre toda la recta real ($\boldsymbol{\beta}$, $\sigma_U$), de modo que sea la información contenida en los datos, y no la previa, la que domine la distribución posterior. Bajo este enfoque, las distribuciones previas no imponen restricciones de signo ni concentran probabilidad sobre valores específicos, evitando introducir información sustantiva ajena a los datos.

Para los coeficientes de efectos fijos se adopta una distribución normal centrada en cero:

$$
\beta_k \sim \mathcal{N}(0,\, \tau_\beta^2), \qquad k = 1, \ldots, P
$$

donde $\tau_\beta^2$ es un hiperparámetro de escala fijado en un valor grande, de modo que la distribución resulte esencialmente plana en el rango plausible de las covariables —previamente estandarizadas—, sin dejar de ser una distribución propia. La centrada en cero refleja la ausencia de conocimiento previo sobre la dirección del efecto de cada covariable, mientras que $\tau_\beta^2$ grande garantiza que dicha información sea mínima.

Para los coeficientes de efectos aleatorios se adopta una distribución normal jerárquica con varianza controlada por el hiperparámetro $\sigma_U$:

$$
\gamma_j \sim \mathcal{N}(0,\, \sigma_U^2), \qquad j = 1, \ldots, Q
$$

Esta especificación introduce una estructura de encogimiento sobre los efectos aleatorios: territorios con información escasa son atraídos hacia el promedio global capturado por los efectos fijos, mientras que territorios con información abundante y patrón sistemáticamente distinto pueden mantener efectos locales de mayor magnitud. El grado de encogimiento está regulado por $\sigma_U$, que a su vez es un parámetro desconocido al que se asigna una distribución previa.

Para el hiperparámetro de variabilidad de los efectos aleatorios se adopta, igualmente, una normal plana truncada a valores positivos:

$$
\sigma_U \sim \mathcal{N}^+(0,\, \tau_U^2)
$$

con $\tau_U^2$ grande. Esta elección permite que el modelo aprenda la magnitud de la variabilidad territorial a partir de los datos, sin imponer un valor fijo ni una restricción informativa sobre su escala.

Para el parámetro de escala de la densidad $\sigma$ se mantiene, en cambio, una distribución de Cauchy positiva:

$$
\sigma \sim \text{Cauchy}^+(0,\, \tau_\sigma)
$$

con $\tau_\sigma$ grande. A diferencia de $\boldsymbol{\beta}$ y $\sigma_U$, para $\sigma$ se prefiere la Cauchy positiva sobre la normal plana truncada: sus colas más pesadas evitan concentrar probabilidad en valores pequeños de la escala, lo que la vuelve más robusta como previa no informativa para un parámetro de dispersión, especialmente en contextos con marcada heterogeneidad territorial y cobertura censal diferencial.


### Distribución posterior {#distribucion-posterior}

La inferencia bayesiana combina la información aportada por los datos observados con el conocimiento previo especificado para los parámetros del modelo. Formalmente, el teorema de Bayes establece que la distribución posterior conjunta sobre los parámetros estructurales $\boldsymbol{\theta}$ y las densidades latentes $\boldsymbol{\delta}$ es

$$
p(\boldsymbol{\theta},\boldsymbol{\delta}\mid\mathbf{Y}_{obs}) = \frac{p(\mathbf{Y}_{obs},\boldsymbol{\delta}\mid\boldsymbol{\theta}) \cdot p(\boldsymbol{\theta})}{p(\mathbf{Y}_{obs})},
$$

donde $p(\mathbf{Y}_{obs},\boldsymbol{\delta}\mid\boldsymbol{\theta})$ corresponde a la verosimilitud conjunta desarrollada en la sección anterior, $p(\boldsymbol{\theta})$ representa la distribución previa conjunta de todos los parámetros estructurales, y $p(\mathbf{Y}_{obs})$ es la distribución marginal de los datos, conocida como constante de normalización o evidencia bayesiana. La evidencia se obtiene integrando la distribución conjunta sobre la totalidad del espacio de parámetros y densidades latentes,

$$
p(\mathbf{Y}_{obs}) = \iint p(\mathbf{Y}_{obs},\boldsymbol{\delta}\mid\boldsymbol{\theta}) \cdot p(\boldsymbol{\theta}) \; d\boldsymbol{\delta}\, d\boldsymbol{\theta},
$$

donde la integración comprende simultáneamente los coeficientes de regresión, los efectos aleatorios, las desviaciones estándar y las densidades latentes. En modelos jerárquicos como el Poisson-lognormal esta integral no posee solución analítica cerrada. Sin embargo, dado que la evidencia no depende de $\boldsymbol{\theta}$ ni de $\boldsymbol{\delta}$, puede tratarse como una constante de proporcionalidad durante la inferencia, de modo que

$$
p(\boldsymbol{\theta},\boldsymbol{\delta}\mid\mathbf{Y}_{obs}) \;\propto\; p(\mathbf{Y}_{obs},\boldsymbol{\delta}\mid\boldsymbol{\theta}) \cdot p(\boldsymbol{\theta}).
$$

Resta expandir la distribución previa conjunta $p(\boldsymbol{\theta})$. Bajo el supuesto de independencia entre los distintos bloques de parámetros en su distribución previa,

$$
p(\boldsymbol{\theta}) = p(\boldsymbol{\beta}) \cdot p(\boldsymbol{\gamma}\mid\sigma_U) \cdot p(\sigma) \cdot p(\sigma_U),
$$

donde la dependencia de $\boldsymbol{\gamma}$ respecto a $\sigma_U$ refleja precisamente la estructura jerárquica introducida en la sección de distribuciones previas: los efectos aleatorios no son previamente independientes de su propio hiperparámetro de variabilidad. Sustituyendo esta descomposición en la expresión de proporcionalidad se obtiene

$$
p(\boldsymbol{\theta}, \boldsymbol{\delta} \mid \mathbf{Y}_{obs}) \;\propto\; p(\mathbf{Y}_{obs}, \boldsymbol{\delta} \mid \boldsymbol{\beta}, \boldsymbol{\gamma}, \sigma) \cdot p(\boldsymbol{\gamma} \mid \sigma_U) \cdot p(\boldsymbol{\beta}) \cdot p(\sigma) \cdot p(\sigma_U).
$$

Finalmente, reemplazando la verosimilitud y las distribuciones previas por sus formas funcionales específicas, la distribución posterior puede escribirse como

$$
\begin{aligned}
p(\boldsymbol{\theta},\boldsymbol{\delta}\mid\mathbf{Y}_{obs})
\propto
&
\prod_{i\in\mathcal S_{obs}}
\left[
\frac{e^{-\delta_iV_i}(\delta_iV_i)^{Y_i}}
{Y_i!}
\times
\frac{1}{\delta_i\sigma\sqrt{2\pi}}
\exp\left(
-\frac{(\log\delta_i-\mu_i)^2}
{2\sigma^2}
\right)
\right]
\times \\
&
\prod_{j=1}^{Q}
\frac{1}{\sigma_U\sqrt{2\pi}}
\exp\left(
-\frac{\gamma_j^2}{2\sigma_U^2}
\right)
\times \\
&
\prod_{k=1}^{P}
\frac{1}{\tau_\beta\sqrt{2\pi}}
\exp\left(
-\frac{\beta_k^2}{2\tau_\beta^2}
\right)
\times \\
&
p(\sigma) \times 
p(\sigma_U)
\end{aligned}
$$

donde el predictor lineal está dado por

$$
\mu_i = \mathbf{x}_i^{\top}\boldsymbol{\beta} +
\mathbf{z}_i^{\top}\boldsymbol{\gamma}.
$$

Sustituyendo esta expresión en la densidad log-normal, la distribución posterior puede escribirse completamente en función de los parámetros del modelo como

$$
\begin{aligned}
p(\boldsymbol{\theta},\boldsymbol{\delta}\mid\mathbf{Y}_{obs})
\propto
&
\prod_{i\in\mathcal S_{obs}}
\left[
\frac{e^{-\delta_iV_i}(\delta_iV_i)^{Y_i}}
{Y_i!}
\times
\frac{1}{\delta_i\sigma\sqrt{2\pi}}
\exp\left(
-\frac{
\left(
\log\delta_i - 
 (\mathbf{x}_i^{\top}\boldsymbol{\beta} +  \mathbf{z}_i^{\top}\boldsymbol{\gamma})
\right)^2}
{2\sigma^2}
\right)
\right]
\times \\
&
\prod_{j=1}^{Q}
\frac{1}{\sigma_U\sqrt{2\pi}}
\exp\left(
-\frac{\gamma_j^2}{2\sigma_U^2}
\right)
\times \\
&
\prod_{k=1}^{P}
\frac{1}{\tau_\beta\sqrt{2\pi}}
\exp\left( -\frac{\beta_k^2}{2\tau_\beta^2}
\right)
\times \\
&
p(\sigma) \times p(\sigma_U).
\end{aligned}
$$

La expresión anterior constituye la distribución posterior conjunta del modelo, y en ella aparecen simultáneamente: la información aportada por los conteos observados a través de la distribución Poisson; la estructura jerárquica de las densidades latentes a través de la distribución log-normal; y las restricciones introducidas por las distribuciones previas sobre los coeficientes de regresión, los efectos aleatorios y los parámetros de variabilidad.

A diferencia de los modelos conjugados, esta distribución posterior no pertenece a una familia paramétrica conocida: la combinación entre la verosimilitud Poisson y la estructura log-normal rompe la conjugación y hace imposible obtener expresiones analíticas cerradas para las distribuciones marginales de los parámetros. Por esta razón, la inferencia debe realizarse mediante métodos numéricos de simulación.

Una vez obtenida la distribución posterior, el objetivo de la inferencia consiste en generar realizaciones de dicha distribución para aproximar las cantidades de interés. Dado que la distribución posterior del modelo Poisson-lognormal no posee una forma analítica cerrada, este proceso debe realizarse mediante algoritmos de simulación Monte Carlo, cuyo esquema conceptual puede resumirse en los siguientes pasos:

1. Definir las distribuciones previas para $\boldsymbol{\beta}$, $\boldsymbol{\gamma}$, $\sigma$ y $\sigma_U$.
2. Construir la verosimilitud conjunta $p(\mathbf{Y}_{obs},\boldsymbol{\delta}\mid\boldsymbol{\theta})$.
3. Aplicar el teorema de Bayes para obtener la distribución posterior no normalizada, $p(\boldsymbol{\theta},\boldsymbol{\delta}\mid\mathbf{Y}_{obs}) \propto p(\mathbf{Y}_{obs},\boldsymbol{\delta}\mid\boldsymbol{\theta}) \, p(\boldsymbol{\theta})$.
4. Inicializar los parámetros del modelo y, para cada iteración $t = 1,\ldots,T$, generar una muestra conjunta $(\boldsymbol{\theta}^{(t)}, \boldsymbol{\delta}^{(t)}) \sim p(\boldsymbol{\theta},\boldsymbol{\delta}\mid\mathbf{Y}_{obs})$, almacenando las realizaciones obtenidas.
5. Aproximar las cantidades de interés mediante promedios Monte Carlo.
6. Generar la distribución predictiva posterior para los segmentos sin observación.
7. Agregar las predicciones por segmento para obtener estimaciones de niveles geográficos superiores.

La implementación computacional de este procedimiento, mediante el algoritmo de Monte Carlo Hamiltoniano en Stan, se desarrolla en el capítulo siguiente. A continuación se detallan las expresiones correspondientes a los pasos 4 a 7.

Las muestras generadas en la iteración $t$,

$$
(\boldsymbol{\theta}^{(t)},\boldsymbol{\delta}^{(t)}), \qquad t=1,\ldots,T,
$$

permiten aproximar cualquier funcional de la distribución posterior mediante integración Monte Carlo. En particular, la esperanza posterior de la densidad poblacional para el segmento $i$ se estima como

$$
\hat{\delta}_i = \mathbb{E}[\delta_i\mid\mathbf{Y}_{obs}] \approx \frac{1}{T}\sum_{t=1}^{T}\delta_i^{(t)}.
$$

Una vez obtenidas las muestras posteriores, para cada segmento no observado $i\in\mathcal{S}\setminus\mathcal{S}_{obs}$ se generan realizaciones de la distribución predictiva posterior,

$$
\tilde{\delta}_i^{(t)} \sim \text{LogNormal}\!\left(\mu_i^{(t)},\, \sigma^{(t)}\right), \qquad \tilde{Y}_i^{(t)} \sim \text{Poisson}\!\left(\tilde{\delta}_i^{(t)} \cdot V_i\right),
$$

donde

$$
\mu_i^{(t)} = \mathbf{x}_i^{\top}\boldsymbol{\beta}^{(t)} + \mathbf{z}_i^{\top}\boldsymbol{\gamma}^{(t)}.
$$

En la práctica, la densidad simulada $\tilde{\delta}_i^{(t)}$ se trunca superiormente antes de generar el conteo predicho, según la restricción descrita en la Sección \@ref(sobredispersion-offset). Finalmente, las predicciones de los segmentos se agregan para estimar la población de municipios, departamentos o del total nacional, propagando automáticamente la incertidumbre posterior del modelo.



### Interpretación de parámetros

Cada parámetro del modelo describe un aspecto diferente de la distribución de la población entre los segmentos censales. En conjunto, permiten explicar cómo varía el número esperado de personas por estructura habitacional y cuantificar la incertidumbre asociada a esa variación.

El predictor lineal, introducido en la Sección \@ref(funcion-verosimilitud),

$$
\mu_i = \mathbf{x}_i^{\top}\boldsymbol{\beta} + \mathbf{z}_i^{\top}\boldsymbol{\gamma},
$$

representa el nivel esperado de ocupación del segmento $i$ antes de incorporar la variabilidad propia del modelo. Este predictor resume toda la información auxiliar disponible y constituye el punto de partida para estimar la densidad poblacional del segmento.

Los coeficientes de efectos fijos, $\boldsymbol{\beta}$ —descritos con mayor detalle en la Sección \@ref(efectos-fijos)—, cuantifican la contribución de cada variable auxiliar a la densidad poblacional. En particular, el coeficiente $\beta_k$ mide cómo cambia la ocupación esperada de un segmento cuando la covariable correspondiente aumenta una desviación estándar, manteniendo constantes las demás variables del modelo. Debido a que la relación se establece sobre una escala logarítmica, el efecto suele interpretarse mediante su exponencial,

$$
\exp(\beta_k),
$$

que corresponde al factor por el cual cambia la densidad mediana de personas por estructura habitacional. Por ejemplo, un valor de $\exp(\beta_k) = 1.10$ indica que, al aumentar una desviación estándar la covariable $k$, la densidad esperada aumenta aproximadamente un 10 %; por el contrario, un valor de $0.90$ indica una reducción cercana al 10 %.

Los efectos aleatorios, representados por $\boldsymbol{\gamma}$ —tratados con mayor detalle en la Sección \@ref(efectos-aleatorios)—, capturan diferencias sistemáticas entre unidades territoriales que no pueden ser explicadas por las variables auxiliares. En otras palabras, permiten que territorios con características similares presenten densidades poblacionales distintas debido a factores no observados, como patrones de urbanización, condiciones geográficas o dinámicas demográficas locales. Cada efecto aleatorio actúa como un ajuste específico para la unidad territorial correspondiente y desplaza hacia arriba o hacia abajo la densidad estimada de todos los segmentos pertenecientes a esa unidad.

El parámetro $\sigma$ mide la variabilidad de las densidades poblacionales entre segmentos después de considerar tanto las covariables como los efectos aleatorios. Valores pequeños de $\sigma$ indican que segmentos con características similares presentan densidades relativamente homogéneas, mientras que valores grandes reflejan una mayor heterogeneidad residual y, por tanto, una mayor incertidumbre en las predicciones individuales.

Por su parte, el hiperparámetro $\sigma_U$ describe el grado de variabilidad existente entre las unidades territoriales consideradas en el modelo. Si $\sigma_U$ es cercano a cero, los territorios presentan comportamientos muy similares una vez controladas las covariables. En cambio, valores elevados indican que existen diferencias importantes entre territorios que no son explicadas únicamente por la información auxiliar disponible. Las distribuciones previas de $\sigma$ y $\sigma_U$ se describen en la Sección \@ref(distribuciones-previas).

Finalmente, el parámetro de mayor interés es la densidad poblacional latente, $\delta_i$ —definida en la Sección \@ref(definicion-formal)—, la cual representa el número esperado de personas por estructura habitacional en el segmento censal $i$. Esta cantidad resume la intensidad de ocupación del segmento y constituye la base para predecir la población cuando únicamente se conoce el número de estructuras habitacionales. Su distribución posterior, caracterizada en la Sección \@ref(distribucion-posterior), no solo proporciona una estimación puntual, sino también un intervalo de valores plausibles que refleja la incertidumbre inherente al proceso de estimación.

En conjunto, los parámetros del modelo cumplen funciones complementarias: los efectos fijos explican cómo las características observables influyen sobre la ocupación de los segmentos; los efectos aleatorios representan diferencias territoriales no observadas; los parámetros de dispersión cuantifican la variabilidad residual entre segmentos y territorios; y la densidad latente $\delta_i$ integra toda esta información para producir las estimaciones finales de población.

## Componentes del modelo

La especificación completa del modelo Poisson-lognormal requiere detallar la construcción de cada uno de sus componentes estructurales. El predictor lineal  dado en la Sección \@ref(funcion-verosimilitud) integra dos tipos de información: efectos sistemáticos capturados por las covariables auxiliares a través de los efectos fijos, y ajustes territoriales no explicados por dichas covariables a través de los efectos aleatorios. Estos componentes interactúan con el offset de estructuras $V_i$ y con el mecanismo de sobredispersión log-normal para producir estimaciones coherentes en el conjunto completo de segmentos.

### Efectos fijos {#efectos-fijos}

Los efectos fijos del modelo capturan la relación sistemática entre las covariables auxiliares y la densidad poblacional. Sea $\mathbf{X}_{obs}$ la matriz de covariables de dimensión $D_{obs} \times P$, donde la fila $i$ corresponde al vector $\mathbf{x}_i^{\top}$ del segmento observado $i$ y las columnas corresponden a las $P$ covariables seleccionadas tras el proceso de preparación de insumos descrito en el capítulo anterior. Análogamente, $\mathbf{X}_{tot}$ es la matriz de covariables de dimensión $D \times P$ que contiene los vectores de covariables para la totalidad de los segmentos del país, incluyendo aquellos no observados en el operativo censal.

El predictor lineal de efectos fijos para el segmento $i$ es:

$$
\left(\mathbf{X}_{obs}\boldsymbol{\beta}\right)_i = \sum_{k=1}^{P} \beta_k\, \tilde{x}_{i,k}
$$

donde $\tilde{x}_{i,k}$ denota la versión estandarizada de la covariable $k$ en el segmento $i$, construida mediante las transformaciones descritas en el capítulo anterior: estandarización por media y desviación estándar para variables continuas, o normalización al intervalo unitario para proporciones e índices con interpretación intrínseca en $[0,1]$.

Las covariables incorporadas en $\mathbf{X}_{obs}$ se organizan en las dos categorías descritas en el capítulo de integración de fuentes. Las variables socioeconómicas incluyen tasas de acceso a servicios públicos —electricidad, agua potable, internet— y conteos provenientes de registros administrativos como padrones electorales o afiliados a sistemas de salud. Las variables espaciales de origen satelital incluyen la luminosidad nocturna media del segmento $L_i$, el área construida derivada del producto Global Human Settlement Layer, la proporción de distintas categorías de cobertura de suelo, la pendiente media del terreno y la altitud media sobre el nivel del mar.

Un aspecto crítico en la especificación de los efectos fijos es el tratamiento de la multicolinealidad entre covariables. Dado que muchas de las fuentes auxiliares descritas están correlacionadas entre sí —la luminosidad nocturna y el área construida tienden a ser altas en las mismas zonas urbanas, y el número de registros administrativos crece con la población—, la inclusión simultánea de variables altamente correlacionadas puede dificultar la estimación individual de los coeficientes. En la práctica, esto se aborda principalmente mediante el análisis de correlación y la selección de variables descritos en el Capítulo \@ref(cap-insumos), realizados antes de la estimación. Cabe señalar que las distribuciones previas $\beta_k \sim \mathcal{N}(0,\tau_\beta^2)$ no cumplen aquí un papel regularizador relevante: al fijarse $\tau_\beta^2$ en un valor grande —precisamente para que la previa sea no informativa—, la estabilización frente a predictores correlacionados debe resolverse mediante el tratamiento de las covariables previo al modelamiento, y no delegarse en la previa.

La estimación del vector $\boldsymbol{\beta}$ a partir de los datos proporciona información sobre cuáles características del segmento están más fuertemente asociadas con la densidad poblacional. Esta información puede utilizarse para orientar la actualización cartográfica, priorizar la recolección de covariables en futuros operativos censales y validar la consistencia de las fuentes utilizadas con los patrones demográficos observados en el territorio.

### Efectos aleatorios {#efectos-aleatorios}

Los efectos aleatorios capturan la variabilidad sistemática entre unidades territoriales de nivel superior que no es explicada por las covariables auxiliares incluidas en los efectos fijos. Esta variabilidad puede deberse a factores institucionales no medidos —diferencias en la capacidad operativa de los equipos censales entre provincias, por ejemplo—, a condiciones locales no capturadas por las fuentes disponibles, o a características territoriales latentes que afectan simultáneamente a múltiples segmentos de una misma unidad.

Sea $\mathbf{Z}_{obs}$ la matriz de indicadores de dimensión $D_{obs} \times Q$, donde $Q$ es el número de unidades territoriales de nivel superior consideradas. El elemento $z_{i,j}$ vale uno si el segmento $i$ pertenece a la unidad territorial $j$ y cero en caso contrario. Análogamente, $\mathbf{Z}_{tot}$ es la matriz de indicadores de dimensión $D \times Q$ para el conjunto completo de segmentos. La contribución de los efectos aleatorios al predictor lineal del segmento $i$ es:

$$
\left(\mathbf{Z}_{obs}\boldsymbol{\gamma}\right)_i = \sum_{j=1}^{Q} z_{i,j}\,\gamma_j = \gamma_{j(i)}
$$

donde $j(i)$ denota la unidad territorial a la que pertenece el segmento $i$. Dado que cada segmento pertenece a exactamente una unidad territorial, la contribución de los efectos aleatorios es simplemente el coeficiente $\gamma_{j(i)}$ correspondiente a su territorio.

La distribución previa jerárquica $\gamma_j \sim \mathcal{N}(0, \sigma_U^2)$ regula el comportamiento de los efectos aleatorios a través del hiperparámetro $\sigma_U$. Cuando $\sigma_U$ es pequeño, el modelo impone que los efectos aleatorios sean cercanos a cero, lo que es equivalente a una especificación sin ajustes territoriales específicos. Cuando $\sigma_U$ es grande, los efectos aleatorios pueden tomar valores sustanciales, capturando diferencias importantes entre territorios no explicadas por las covariables. La estimación conjunta de $\sigma_U$ y $\boldsymbol{\gamma}$ permite que el modelo aprenda automáticamente el grado de heterogeneidad territorial presente en los datos.

Una propiedad fundamental de la estructura jerárquica es el préstamo de fortaleza entre segmentos de un mismo territorio. Los segmentos con escasa información —conteos muy bajos, alta variabilidad en el conteo observado o baja cobertura censal— son estabilizados por la información de los demás segmentos de la misma unidad territorial, a través del efecto aleatorio compartido $\gamma_{j(i)}$. Simultáneamente, los efectos fijos proveen información de todos los segmentos del país para estimar el vector $\boldsymbol{\beta}$, que contribuye a la predicción en segmentos con poca o ninguna cobertura censal. Este mecanismo de préstamo de información entre dominios constituye una de las principales ventajas del enfoque jerárquico bayesiano sobre los métodos de estimación directa [@Rao2015; @Banerjee2015].

La estructura de efectos aleatorios puede extenderse a múltiples niveles territoriales. En las aplicaciones sobre censos de América Latina y el Caribe desarrolladas en el marco de este libro, los efectos aleatorios se han especificado sobre provincias, departamentos o regiones, que constituyen la unidad administrativa intermedia más relevante para la gestión censal. En países con censos de alta resolución cartográfica y disponibilidad de datos administrativos a nivel de municipio, es posible incorporar efectos aleatorios anidados que capturen simultáneamente variabilidad regional y municipal, a costa de mayor complejidad computacional y mayor exigencia de información.

### Interacciones

El predictor lineal en su forma básica representa efectos aditivos y lineales de las covariables sobre el logaritmo de la densidad poblacional. En determinados contextos, la relación entre las covariables y la densidad puede presentar patrones no lineales o interacciones que requieren representación explícita en el modelo.

Las interacciones entre covariables se incorporan mediante la inclusión de productos entre variables estandarizadas en la matriz $\mathbf{X}_{obs}$. Si $\tilde{x}_{i,k}$ y $\tilde{x}_{i,l}$ son dos covariables estandarizadas, su término de interacción se define como:

$$
\tilde{x}_{i,kl} = \tilde{x}_{i,k} \cdot \tilde{x}_{i,l}
$$

El predictor lineal extendido con interacciones incluye un coeficiente adicional $\beta_{kl}$ con distribución previa $\beta_{kl} \sim \mathcal{N}(0, \tau_\beta^2)$, tratando el término de interacción de manera simétrica a los efectos principales. Esta formulación es apropiada cuando las covariables están estandarizadas, ya que garantiza que los términos de interacción operen en una escala comparable a los efectos principales.

En el contexto de la estimación de conteos censales, las interacciones de mayor relevancia sustantiva suelen involucrar combinaciones entre variables de uso del suelo y clasificaciones territoriales —la interacción entre luminosidad nocturna y la condición urbano-rural puede capturar diferencias en el patrón de ocupación habitacional según el tipo de asentamiento— o entre variables socioeconómicas y espaciales, como la relación entre el acceso a servicios públicos y la distancia a centros urbanos, cuya dirección puede variar sistemáticamente entre contextos urbanos y rurales.

Las interacciones entre efectos fijos y efectos aleatorios, conocidas como efectos de pendiente aleatoria, permiten que la relación de una covariable con la densidad varíe entre territorios. En esta especificación extendida, el coeficiente de la covariable $k$ en el territorio $j$ es $\beta_k + \nu_{j,k}$, donde $\nu_{j,k}$ representa la desviación específica del territorio respecto al efecto promedio nacional. Esta extensión aumenta la flexibilidad del modelo a costa de mayor dimensionalidad y puede resultar útil cuando se sospecha que el efecto de un predictor varía sistemáticamente entre regiones del país.

La inclusión de términos de interacción debe equilibrar la mejora en el ajuste del modelo con el riesgo de sobreajuste en datos de alta dimensión. En la práctica, la selección de interacciones relevantes se evalúa mediante criterios de comparación de modelos como el criterio LOO-CV o el WAIC [@Vehtari2017; @Watanabe2010], cuyas bases se desarrollan en el capítulo dedicado al diagnóstico y validación.

### Sobredispersión y offset {#sobredispersion-offset}

El diseño del modelo Poisson-lognormal incorpora dos elementos adicionales que merecen consideración específica: el uso del número de estructuras como offset del proceso de conteo, y el mecanismo de control de sobredispersión a través de la distribución log-normal.

**El offset de estructuras habitacionales.** El número de estructuras habitacionales $V_i$ desempeña el papel de offset en el modelo: escala la intensidad del proceso de Poisson de manera proporcional al tamaño del segmento en términos de unidades habitacionales. A partir de la definición $\lambda_i = \delta_i V_i$, la intensidad puede escribirse en escala logarítmica como

$$
\log(\lambda_i) = \log(\delta_i) + \log(V_i).
$$

Dado que $\log(\delta_i) = \mu_i + \varepsilon_i$, con $\varepsilon_i \sim \mathcal{N}(0, \sigma^2)$ (Sección \@ref(funcion-verosimilitud)), se obtiene

$$
\log(\lambda_i) = \mu_i + \varepsilon_i + \log(V_i).
$$

El término $\log(V_i)$ actúa como offset con coeficiente fijado en uno, lo que equivale a modelar la densidad —y no el conteo total— como función de las covariables. Esta parametrización es estadísticamente más apropiada que incluir $\log(V_i)$ como covariable con coeficiente libre, ya que el número de estructuras debe considerarse una referencia de escala del proceso y no un predictor ordinario del logaritmo de la densidad.

Esta parametrización posee además una interpretación demográfica directa: dos segmentos con igual densidad poblacional pero distinto número de estructuras tendrán conteos esperados diferentes únicamente por esa diferencia en el número de estructuras. El modelo explica, en consecuencia, la ocupación promedio por estructura habitacional, y utiliza $V_i$ para escalar dicha ocupación hasta el nivel del conteo total del segmento.

La fuente del offset puede variar según la disponibilidad de información. En segmentos con preconteo operativo, $V_i$ corresponde directamente al número de viviendas registradas durante la actualización cartográfica previa al censo. En segmentos sin preconteo o con preconteo desactualizado por cambios demográficos recientes, $V_i$ puede aproximarse mediante el número de estructuras identificadas en imágenes satelitales. La calidad de la estimación final depende directamente de la precisión de $V_i$, dado que errores en el offset se propagan directamente hacia las predicciones de conteo en todo el conjunto de segmentos.

**El mecanismo de sobredispersión log-normal.** La inclusión de la densidad latente $\delta_i$ con distribución log-normal constituye el principal mecanismo de control de sobredispersión del modelo. Bajo un modelo de Poisson puro, sin densidad latente y con predictor lineal fijo, la media y la varianza del conteo coinciden, $\operatorname{Var}(Y_i) = \mathbb{E}(Y_i)$ —un supuesto que los conteos poblacionales observados en segmentos censales suelen incumplir, dada la variabilidad adicional que introducen las diferencias locales en ocupación de viviendas, procesos de urbanización y composición demográfica—.

La introducción de $\delta_i$ log-normal rompe esta restricción de equidispersión: como se mostró en la Sección \@ref(funcion-verosimilitud), la varianza marginal del conteo es

$$
\operatorname{Var}(Y_i) = \mathbb{E}(Y_i) + V_i^2\, e^{2\mu_i+\sigma^2}\left(e^{\sigma^2}-1\right),
$$

donde el segundo término representa la variabilidad adicional inducida por la mezcla Poisson-lognormal, estrictamente positiva para $\sigma > 0$. El parámetro $\sigma$ controla directamente esta sobredispersión: cuando $\sigma \to 0$, la distribución log-normal degenera en un valor fijo y el modelo se reduce al Poisson clásico; a medida que $\sigma$ aumenta, también aumenta la heterogeneidad entre segmentos y, con ella, la varianza marginal de los conteos. Esta propiedad permite que el modelo se adapte automáticamente al nivel de variabilidad presente en los datos, sin requerir la especificación previa del grado de sobredispersión.

**Restricción de la densidad en predicción.** En la implementación práctica del modelo, la densidad predicha para segmentos no observados —generada según el procedimiento descrito en la Sección \@ref(distribucion-posterior)— se trunca superiormente con el objetivo de evitar predicciones demográficamente implausibles en segmentos con alto valor del predictor lineal. Concretamente, se aplica la restricción:

$$
\tilde{\delta}_i = \min\!\left(\delta_i^*,\, \delta_{\max}\right)
$$

donde $\delta_i^*$ es la densidad generada por la distribución log-normal predictiva y $\delta_{\max}$ es un valor máximo admisible definido a partir del conocimiento experto sobre los rangos plausibles de ocupación habitacional en el contexto regional. En la práctica, $\delta_{\max}$ se determina a partir de la distribución empírica de las densidades observadas en $\mathcal{S}_{obs}$: un valor habitual es el percentil 99 de $\{\delta_i : i \in \mathcal{S}_{obs}\}$ o un umbral redondo —por ejemplo, 20 personas por estructura— que refleje el máximo demográficamente plausible para el país en cuestión. Esta restricción previene que la combinación de un predictor lineal alto y variabilidad log-normal genere densidades que, multiplicadas por el número de estructuras, produzcan conteos individuales que superen toda referencia demográfica razonable.

La pertinencia de este mecanismo de sobredispersión debe fundamentarse en el diagnóstico exploratorio de los datos —en particular, en la relación empírica entre la media y la varianza de los conteos por segmento, descrita en el Capítulo \@ref(cap-insumos)— y confirmarse posteriormente mediante criterios de comparación de modelos. En contextos con elevada variabilidad territorial, alta proporción de segmentos con baja cobertura y disponibilidad de información sobre el número de estructuras, el modelo Poisson-lognormal con offset representa la especificación estadísticamente más apropiada para la estimación subnacional de conteos poblacionales en segmentos censales [@BryantZhang2018], y ha mostrado buen desempeño en las aplicaciones desarrolladas sobre censos de América Latina y el Caribe que sirven de referencia para este libro.
