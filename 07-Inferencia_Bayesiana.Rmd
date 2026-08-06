# Inferencia Bayesiana e Implementación Computacional {#cap-inferencia}

El capítulo anterior estableció la especificación probabilística completa del modelo Poisson-lognormal: la distribución log-normal para la densidad latente de personas por estructura, la distribución de Poisson para los conteos observados, el predictor lineal con efectos fijos y aleatorios, y las distribuciones previas no informativas para todos los parámetros [@Gelman2013]. Esa especificación, derivada a partir del teorema de Bayes en la Sección \@ref(distribucion-posterior), culmina en la distribución posterior conjunta de los parámetros estructurales y de las densidades latentes:

$$
p(\boldsymbol{\theta}, \boldsymbol{\delta} \mid \mathbf{Y}_{obs}) \;\propto\; p(\mathbf{Y}_{obs}, \boldsymbol{\delta} \mid \boldsymbol{\beta}, \boldsymbol{\gamma}, \sigma) \cdot p(\boldsymbol{\gamma} \mid \sigma_U) \cdot p(\boldsymbol{\beta}) \cdot p(\sigma) \cdot p(\sigma_U)
$$

Disponer de esta expresión no equivale, sin embargo, a poder calcularla: la combinación entre Poisson y log-normal no tiene forma cerrada en ninguno de los parámetros, y la dimensión del espacio parametral —que incluye $D_{obs}$ densidades latentes más los $P + Q + 2$ parámetros estructurales— puede superar varios miles de dimensiones en aplicaciones censales reales.

El presente capítulo cierra esa brecha entre la especificación y la inferencia. La herramienta central es la simulación Monte Carlo por cadenas de Markov (MCMC), y dentro de ella el algoritmo de Monte Carlo Hamiltoniano (HMC) con el muestreador adaptativo NUTS [@Hoffman2014], cuya implementación en Stan [@Carpenter2017] permite obtener muestras de alta calidad de distribuciones posteriores complejas de manera eficiente. El capítulo se organiza en dos secciones: la primera describe los fundamentos del método de simulación y su implementación en Stan, ilustrada con las aplicaciones desarrolladas en cinco países del Caribe y América Latina en el marco de proyectos de asistencia técnica de CEPAL; la segunda describe el procedimiento para derivar, a partir de las muestras obtenidas, estimaciones puntuales, intervalos de credibilidad y agregaciones territoriales.

## Métodos de simulación

Esta sección desarrolla, en cinco etapas, el aparato de simulación que permite aproximar la distribución posterior del modelo Poisson-lognormal: los fundamentos de la inferencia MCMC, el algoritmo de Monte Carlo Hamiltoniano y su variante adaptativa NUTS, la traducción del modelo a un programa Stan, la configuración práctica de cadenas e iteraciones, y las consideraciones de paralelización y eficiencia computacional que hacen viable ejecutar el modelo sobre segmentos censales de gran escala.

### Cadenas de Markov Monte Carlo

En la mayoría de los modelos bayesianos la distribución posterior no puede obtenerse de forma analítica, por lo que es necesario aproximarla mediante métodos de simulación. Las cadenas de Markov Monte Carlo (MCMC) constituyen la familia de algoritmos más utilizada para este propósito. Su idea central consiste en generar una secuencia de valores de los parámetros cuya distribución, después de un número suficiente de iteraciones, coincide con la distribución posterior de interés [@Tierney1994].

Si la cadena ha alcanzado esta distribución estacionaria, las muestras generadas pueden utilizarse para estimar cualquier cantidad de interés, como medias, varianzas, intervalos de credibilidad o funciones de los parámetros. Para una función cualquiera $g(\boldsymbol{\theta})$, su esperanza posterior puede aproximarse mediante el promedio de Monte Carlo

$$
\hat{g}_T = \frac{1}{T} \sum_{t=1}^{T} g\left(\boldsymbol{\theta}^{(t)}\right),
$$

el cual converge a medida que aumenta el número de iteraciones. En la práctica, la precisión de esta aproximación depende no solo del tamaño de la muestra simulada, sino también del grado de dependencia entre observaciones consecutivas. Cuando las muestras presentan alta autocorrelación, la información efectiva contenida en la cadena disminuye y se requieren más iteraciones para obtener estimaciones precisas.

Durante varias décadas, los algoritmos de Metropolis-Hastings y sus variantes fueron el estándar para realizar inferencia bayesiana. Sin embargo, en modelos con un gran número de parámetros, como los modelos Poisson-lognormales utilizados para estimar población en miles de segmentos censales, estos métodos suelen explorar el espacio parametral de manera poco eficiente, produciendo cadenas altamente correlacionadas y tiempos de convergencia elevados. Para superar estas limitaciones surgió el *Hamiltonian Monte Carlo* (HMC), que utiliza información del gradiente de la distribución posterior para recorrer el espacio parametral de forma más rápida y eficiente [@Neal2011].

### Monte Carlo Hamiltoniano y el algoritmo NUTS

La presente subsección formaliza el mecanismo mediante el cual HMC aprovecha el gradiente de la distribución posterior para guiar —en lugar de sortear al azar— su exploración del espacio parametral.

La idea proviene de la mecánica clásica, donde el movimiento de un sistema físico se describe a partir de su posición y su momento. En HMC, los parámetros del modelo $\boldsymbol{\theta}$ se interpretan como la posición del sistema y se introduce un vector auxiliar de momento $\boldsymbol{p}$. Ambos definen la función hamiltoniana,

$$
H(\boldsymbol{\theta}, \boldsymbol{p}) = -\log p(\boldsymbol{\theta}\mid\mathbf{Y}) + \frac{1}{2}\boldsymbol{p}^{\top}M^{-1}\boldsymbol{p},
$$

que combina la información de la distribución posterior con una cantidad auxiliar necesaria para simular la dinámica del sistema. Esta formulación permite recorrer el espacio parametral mediante trayectorias suaves, evitando el comportamiento errático característico de los métodos basados únicamente en propuestas aleatorias.

En la práctica, estas trayectorias se aproximan mediante el *integrador leapfrog*, que actualiza de forma alternada el momento y la posición utilizando el gradiente de la distribución posterior. Cada iteración del algoritmo realiza las siguientes actualizaciones:

$$
\boldsymbol{p}^{(t+\varepsilon/2)} = \boldsymbol{p}^{(t)} + \frac{\varepsilon}{2}\nabla_{\boldsymbol{\theta}} \log p(\boldsymbol{\theta}^{(t)}\mid\mathbf{Y}),
$$

$$
\boldsymbol{\theta}^{(t+\varepsilon)} = \boldsymbol{\theta}^{(t)} + \varepsilon M^{-1}\boldsymbol{p}^{(t+\varepsilon/2)},
$$

$$
\boldsymbol{p}^{(t+\varepsilon)} = \boldsymbol{p}^{(t+\varepsilon/2)} + \frac{\varepsilon}{2}\nabla_{\boldsymbol{\theta}} \log p(\boldsymbol{\theta}^{(t+\varepsilon)}\mid\mathbf{Y}).
$$

Estas actualizaciones permiten que la cadena explore la distribución posterior de forma eficiente, conservando una alta probabilidad de aceptación incluso en modelos con un gran número de parámetros. Una introducción accesible al funcionamiento de HMC puede encontrarse en @Betancourt2017, mientras que los fundamentos teóricos se desarrollan con mayor detalle en @Neal2011 y @Gelman2013.

Aunque HMC mejora notablemente la eficiencia de los algoritmos MCMC, todavía requiere especificar el número de pasos que debe recorrer cada trayectoria. Elegir un valor demasiado pequeño produce una exploración limitada, mientras que uno demasiado grande incrementa el costo computacional sin aportar información adicional.

El algoritmo *No-U-Turn Sampler* (NUTS) [@Hoffman2014], implementado por defecto en Stan, elimina esta dificultad ajustando automáticamente la longitud de cada trayectoria. El algoritmo detiene el recorrido cuando detecta que la trayectoria comienza a regresar sobre sí misma —un *U-turn*—, indicando que continuar la simulación dejaría de ser eficiente. Durante la fase inicial de calentamiento (*warm-up*), Stan también ajusta automáticamente el tamaño de paso utilizado por el integrador, reduciendo la necesidad de calibrar manualmente estos parámetros.

La combinación de HMC y NUTS ha convertido a Stan en una de las herramientas más eficientes para realizar inferencia bayesiana en modelos jerárquicos de alta dimensión. Esta capacidad resulta especialmente importante en los modelos Poisson-lognormales considerados en este libro, donde deben estimarse simultáneamente miles de efectos aleatorios asociados a segmentos censales. Gracias a esta eficiencia computacional, es posible obtener estimaciones estables y tiempos de ejecución razonables incluso en problemas de gran escala, como los abordados en los proyectos de estimación de población desarrollados por la CEPAL. La implementación práctica de estos modelos en Stan se presenta en la siguiente sección.

### Implementación en Stan {#stan-implementacion}

Una vez descritos los principios de HMC y NUTS, es posible abordar su implementación computacional. En este libro se emplea Stan, un lenguaje de programación probabilística ampliamente utilizado para especificar modelos bayesianos y realizar inferencia mediante algoritmos de muestreo como HMC-NUTS [@Carpenter2017]. Stan compila los modelos a código C++ optimizado, lo que permite ajustar modelos complejos de manera eficiente. Desde R, la interacción con Stan se realiza mediante el paquete `rstan` [@rstan2023], que proporciona las herramientas necesarias para compilar el modelo, ejecutar el proceso de inferencia y recuperar las muestras de la distribución posterior.

Un programa en Stan se organiza en bloques, cada uno con una función específica dentro del proceso de inferencia. El bloque `data` declara la información conocida que se suministra desde R; `parameters` define los parámetros desconocidos del modelo; `transformed parameters` calcula cantidades deterministas derivadas de esos parámetros; `model` especifica la verosimilitud y las distribuciones previas que definen la distribución posterior; y `generated quantities` calcula cantidades derivadas de las muestras posteriores, como predicciones para nuevas observaciones. Esta secuencia no es arbitraria: reproduce, en el mismo orden, la construcción del modelo presentada en el capítulo anterior, desde los datos observados hasta las predicciones derivadas de la distribución posterior.

El Código \@ref(exr:cod-stan-poisson-lognormal) presenta la implementación en Stan del modelo Poisson-lognormal utilizada en las asistencias técnicas de la CEPAL para la estimación de población:

::: {.exercise #cod-stan-poisson-lognormal name="Modelo Poisson-lognormal en Stan"}

```stan
data {
  int<lower=1> D_obs;                  // Segmentos observados en el censo
  int<lower=1> D_tot;                  // Total de segmentos en el país
  int<lower=1> P;                      // Número de covariables
  int<lower=1> Q;                      // Número de efectos aleatorios
  array[D_obs] int<lower=0> Y_obs;     // Conteos poblacionales observados
  array[D_obs] int<lower=0> V_obs;     // Estructuras en segmentos observados
  array[D_tot] int<lower=0> V_tot;     // Estructuras en todos los segmentos
  matrix[D_obs, P] X_obs;              // Covariables en segmentos observados
  matrix[D_tot, P] X_tot;              // Covariables en todos los segmentos
  matrix[D_obs, Q] Z_obs;              // Indicadores de efectos aleatorios (observadas)
  matrix[D_tot, Q] Z_tot;              // Indicadores de efectos aleatorios (todas)
}

parameters {
  vector[P]           beta;     // Coeficientes de efectos fijos
  vector[Q]           gamma;    // Coeficientes de efectos aleatorios
  real<lower=0>       sigma;    // Escala de la distribución log-normal
  real<lower=0>       sigmaU;   // Escala de los efectos aleatorios
  vector<lower=0>[D_obs] densidad; // Densidades latentes en segmentos observados
}

transformed parameters {
  vector[D_obs]        lp;      // Predictor lineal
  vector<lower=0>[D_obs] lambda; // Parámetro Poisson

  lp = X_obs * beta + Z_obs * gamma;

  for (d in 1:D_obs)
    lambda[d] = fmin(fmax(1, densidad[d] * V_obs[d]), 10000000);
}

model {
  // Distribuciones previas
  beta   ~ normal(0, 100);
  gamma  ~ normal(0, sigmaU);
  sigma  ~ cauchy(0, 2.5);
  sigmaU ~ normal(0, 1);

  // Verosimilitud
  Y_obs    ~ poisson(lambda);
  densidad ~ lognormal(lp, sigma);
}

generated quantities {
  vector[D_tot]           lp_tot;
  array[D_tot] real<lower=0> densidad_hat;
  vector<lower=0>[D_tot]  lambda2;
  array[D_tot] int<lower=0> Y_tot;
  vector[D_obs]           log_lik;      // Log-verosimilitud puntual (LOO/WAIC)

  lp_tot = X_tot * beta + Z_tot * gamma;

  for (d in 1:D_tot) {
    densidad_hat[d] = lognormal_rng(lp_tot[d], sigma);
    lambda2[d]      = fmin(fmax(1, densidad_hat[d] * V_tot[d]), 10000000);
    Y_tot[d]        = poisson_rng(lambda2[d]);
  }

  for (d in 1:D_obs)
    log_lik[d] = poisson_lpmf(Y_obs[d] | lambda[d]);
}
```

:::

La Tabla \@ref(tab:stan-notacion) traduce, símbolo por símbolo, la notación matemática del capítulo anterior a los objetos declarados en el código, indicando en qué bloque aparece cada uno; sirve como referencia para el recorrido bloque por bloque que sigue, de modo que este último pueda centrarse en las decisiones de implementación y no en repetir esa correspondencia:

| Notación del capítulo anterior | Objeto en Stan | Bloque |
|---|---|---|
| $D_{obs}$, $D_{tot}$ (segmentos observados y totales, Sección \@ref(definicion-formal)) | `D_obs`, `D_tot` | `data` |
| $P$, $Q$ (número de covariables y de unidades territoriales) | `P`, `Q` | `data` |
| $Y_i$, $i\in\mathcal{S}_{obs}$ | `Y_obs` | `data` |
| $V_i$ (offset de estructuras, Sección \@ref(sobredispersion-offset)) | `V_obs`, `V_tot` | `data` |
| $\mathbf{x}_i^{\top}$, $\mathbf{z}_i^{\top}$ (filas de $\mathbf{X}_{obs}$, $\mathbf{Z}_{obs}$) | `X_obs`, `X_tot`, `Z_obs`, `Z_tot` | `data` |
| $\boldsymbol{\beta}$, $\boldsymbol{\gamma}$, $\sigma$, $\sigma_U$ | `beta`, `gamma`, `sigma`, `sigmaU` | `parameters` |
| $\delta_i$, $i\in\mathcal{S}_{obs}$ (Sección \@ref(definicion-formal)) | `densidad` | `parameters` |
| $\mu_i = \mathbf{x}_i^{\top}\boldsymbol{\beta} + \mathbf{z}_i^{\top}\boldsymbol{\gamma}$ | `lp`, `lp_tot` | `transformed parameters`, `generated quantities` |
| $\lambda_i = \delta_i V_i$ | `lambda`, `lambda2` | `transformed parameters`, `generated quantities` |
| $\beta_k\sim\mathcal{N}(0,\tau_\beta^2)$, $\gamma_j\sim\mathcal{N}(0,\sigma_U^2)$, $\sigma\sim\text{Cauchy}^+(0,\tau_\sigma)$, $\sigma_U\sim\mathcal{N}^+(0,\tau_U^2)$ | `beta ~ normal(0,100)`, `gamma ~ normal(0,sigmaU)`, `sigma ~ cauchy(0,2.5)`, `sigmaU ~ normal(0,1)` | `model` |
| $Y_i\mid\delta_i,V_i\sim\text{Poisson}(\delta_iV_i)$ | `Y_obs ~ poisson(lambda)` | `model` |
| $\delta_i\mid\mu_i,\sigma\sim\text{LogNormal}(\mu_i,\sigma)$ | `densidad ~ lognormal(lp, sigma)` | `model` |
| $\tilde{\delta}_i^{(t)}\sim\text{LogNormal}(\mu_i^{(t)},\sigma^{(t)})$, $\tilde{Y}_i^{(t)}\sim\text{Poisson}(\tilde{\delta}_i^{(t)}V_i)$ | `densidad_hat`, `Y_tot` | `generated quantities` |

Table: (\#tab:stan-notacion) Correspondencia entre la notación del modelo Poisson-lognormal (Capítulo \@ref(cap-conteos)) y los objetos declarados en el programa Stan.

Más allá de esa correspondencia literal, cada bloque involucra decisiones de implementación que la tabla, por su naturaleza, no puede capturar. El bloque `data` declara dos versiones de cada matriz de diseño y del conteo de estructuras —con sufijo `_obs` para los segmentos que aportan información a la verosimilitud y `_tot` para la totalidad del país—, lo que permite ajustar el modelo y generar predicciones fuera de muestra dentro de un único programa, sin duplicar la especificación matemática. En `parameters`, la densidad latente `densidad` se declara como un vector de longitud `D_obs` —un parámetro propio por segmento observado, y no un efecto compartido—, reflejando su condición de cantidad latente individual; la restricción `lower=0`, aplicada también a `sigma` y `sigmaU`, hace que Stan muestree internamente en la escala logarítmica y aplique de forma automática la transformación correspondiente, sin intervención adicional del modelador.

En `transformed parameters`, el producto matricial `X_obs * beta + Z_obs * gamma` evalúa el predictor lineal $\mu_i$ para todos los segmentos observados en una sola operación vectorizada, y la intensidad Poisson se construye como $\lambda_i=\delta_iV_i$, a partir de la identidad $\log(\lambda_i)=\log(\delta_i)+\log(V_i)$ derivada en la Sección \@ref(sobredispersion-offset). La función `fmin(fmax(1, ...), 10000000)` es, en cambio, un resguardo puramente numérico —evita intensidades menores que uno y desbordamientos aritméticos en segmentos con predictor lineal muy alto— y no debe confundirse con la restricción demográfica $\tilde{\delta}_i=\min(\delta_i^*,\delta_{\max})$ de esa misma sección: esta última, más estricta y basada en el conocimiento experto del rango plausible de ocupación habitacional, se aplicaría como un paso adicional sobre `densidad_hat` en `generated quantities`, si el país en cuestión lo requiere.

El bloque `model` implementa la especificación probabilística del modelo mediante las distribuciones previas y la función de verosimilitud. Las distribuciones previas constituyen la implementación directa de las definidas en la Sección \@ref(distribuciones-previas), utilizando los hiperparámetros adoptados para este modelo. La restricción `lower=0` sobre sigma, combinada con la instrucción `sigma ~ cauchy(0, 2.5)`, garantiza que la distribución previa corresponda a una Cauchy positiva. Las dos líneas de verosimilitud, `Y_obs ~ poisson(lambda)` y `densidad ~ lognormal(lp, sigma)`, reproducen conjuntamente la verosimilitud de la Ecuación \@ref(eq:verosimilitud-conjunta), siguiendo las recomendaciones de @Gelman2013 y @McElreath2020 para modelos jerárquicos.

El bloque `generated quantities` repite, para cada muestra posterior y para la totalidad de los segmentos del país, el mismo mecanismo generativo del modelo —predictor lineal, densidad log-normal y conteo Poisson—, lo que produce directamente la distribución predictiva posterior descrita al cierre de la Sección \@ref(distribucion-posterior), sin requerir post-procesamiento adicional. El vector `log_lik`, en cambio, no forma parte de la especificación del modelo: es una cantidad puramente diagnóstica —$\log p(Y_i \mid \delta_i, V_i)$ para cada $i \in \mathcal{S}_{obs}$—, calculada solo para los segmentos observados y reservada como insumo para los criterios LOO y WAIC retomados hacia el final de este capítulo.

### Configuración de cadenas, muestras e iteraciones

Con el programa Stan completamente especificado, resta decidir cómo se ejecuta. La ejecución del modelo desde R requiere configurar cuatro parámetros principales: el número de cadenas, el número de iteraciones totales, el número de iteraciones de calentamiento y los parámetros de control del algoritmo [@Gelman2013, cap. 11], como en el Código \@ref(exr:cod-stan-ajuste):

::: {.exercise #cod-stan-ajuste name="Ajuste del modelo Poisson-lognormal con rstan"}

```r
library(rstan)
library(bayesplot)
library(loo)

# Habilitar paralelización y caché de modelos compilados

options(mc.cores = parallel::detectCores())
rstan::rstan_options(auto_write = TRUE)

# Ajustar el modelo
stan_model <- rstan::stan(
  file    = "/Data/rutinas/Stan/Modelo_ECLAC.stan",
  data    = list_par,
  iter    = 2000,
  warmup  = 1500,
  chains  = 4,
  control = list(max_treedepth = 15)
)
```

:::

El parámetro `iter` fija el número total de iteraciones por cadena, incluyendo el calentamiento. De las 2 000 iteraciones totales por cadena, 1 500 corresponden a la fase de calentamiento y 500 a la fase de inferencia. Con 4 cadenas en paralelo, el conjunto de muestras útiles comprende $4 \times 500 = 2\,000$ muestras de la distribución posterior. En aplicaciones censales con alta dimensión latente —$D_{obs}$ del orden de miles de segmentos— esta configuración es un punto de partida razonable que puede refinarse en función de los diagnósticos de convergencia descritos en las Secciones \@ref(estadistico-rhat) y \@ref(tamano-efectivo-muestra) del capítulo siguiente.

El uso de múltiples cadenas independientes, iniciadas desde puntos dispersos del espacio paramétrico, es una práctica estándar en inferencia MCMC [@Gelman1992]. La comparación entre cadenas permite detectar problemas de convergencia que una cadena única no puede revelar: si todas las cadenas convergen a la misma región de alta densidad posterior, existe mayor confianza en que están explorando adecuadamente la distribución objetivo. El diagnóstico formal basado en la comparación de varianza entre cadenas e intra-cadena, el estadístico $\hat{R}$ [@Gelman1992; @Vehtari2021], se reporta de forma sistemática junto con el tamaño efectivo de muestra.

La fase de calentamiento, ya mencionada como uno de los dos componentes de `iter`, cumple en realidad tres funciones en Stan. Primera: el algoritmo NUTS ajusta adaptativamente el tamaño de paso $\varepsilon$ para alcanzar la tasa de aceptación objetivo. Segunda: se estima la matriz de masa $M$ que actúa como métrica del espacio parametral; Stan utiliza por defecto una métrica euclidiana diagonal cuyos elementos se estiman a partir de la varianza empírica de las muestras de calentamiento. Tercera: la cadena se aproxima a la región de alta densidad posterior, descartando las muestras iniciales que pueden estar lejos del modo. Las muestras de la fase de calentamiento no son utilizables para inferencia porque los hiperparámetros del algoritmo aún están siendo ajustados.

El parámetro `max_treedepth = 15` controla la profundidad máxima del árbol binomial que construye NUTS en cada iteración. Un árbol de profundidad $L$ equivale a $2^L$ evaluaciones del leapfrog, lo que permite trayectorias de gran alcance en distribuciones posteriores con geometría compleja. El valor por defecto en Stan es 10; aumentarlo a 15 es recomendable en modelos con alta dimensionalidad latente o correlaciones posteriores fuertes, al costo de mayor tiempo de cómputo por iteración. Si durante la ejecución Stan registra advertencias de tipo `maximum treedepth exceeded`, se debe aumentar este parámetro o revisar la parametrización del modelo.

### Paralelización y eficiencia computacional

Más allá de la configuración estadística de las cadenas, la ejecución práctica del modelo sobre datos censales de gran escala exige atender también los aspectos computacionales del ajuste: el aprovechamiento de los núcleos de procesamiento disponibles y el manejo de la memoria que generan las predicciones fuera de muestra. La línea `options(mc.cores = parallel::detectCores())` del Código \@ref(exr:cod-stan-ajuste) se configura la ejecución de las cuatro cadenas en paralelo, utilizando tantos núcleos del procesador como estén disponibles. La opción `rstan_options(auto_write = TRUE)` permite que Stan almacene en disco el modelo compilado en C++, de modo que sucesivas ejecuciones del mismo modelo reutilizan el código compilado y evitan el tiempo de compilación —que puede ser de 30 a 90 segundos según la complejidad del modelo— en cada llamada a `stan()`.

En aplicaciones con $D_{obs}$ del orden de varios miles de segmentos, el costo computacional dominante por iteración proviene de la evaluación del gradiente del logaritmo de la distribución conjunta respecto a los parámetros latentes $\boldsymbol{\delta}$. Stan calcula estos gradientes mediante diferenciación automática sobre el grafo computacional del modelo [@Carpenter2017], lo que garantiza gradientes exactos al costo de un factor constante —típicamente entre 2 y 5— sobre el tiempo de evaluación de la log-densidad.

El manejo de memoria es relevante, en particular, cuando el bloque `generated quantities` genera matrices de predicción de dimensión $D_{tot} \times T$. Por esa razón es recomendable guardar el objeto Stan en disco inmediatamente tras la ejecución, evitando así recomputaciones costosas en sesiones de análisis posteriores, como en el Código \@ref(exr:cod-stan-guardar):

::: {.exercise #cod-stan-guardar name="Guardar y recuperar el objeto Stan ajustado"}

```r
# Guardar el objeto ajustado
saveRDS(stan_model,
        file = "Data/modelo/fit_pob_bayes_lognormal.rds")

# Cargar para análisis posteriores sin reejecutar el modelo
stan_model <- readRDS("Data/modelo/fit_pob_bayes_lognormal.rds")
```

:::

Con el objeto ajustado disponible en disco se cierra el ciclo de estimación propiamente dicho: se cuenta con muestras válidas de la distribución posterior del modelo Poisson-lognormal, obtenidas mediante HMC-NUTS y almacenadas de forma persistente. Resta traducir esas muestras en las cantidades que efectivamente interesan a la producción estadística oficial —estimaciones puntuales, intervalos de credibilidad y totales agregados por unidad geográfica— y verificar que el ajuste sea adecuado para ese propósito. Ambas tareas se desarrollan en la sección siguiente.

## Distribución posterior y estimaciones

Esta sección recorre el camino que va de las muestras crudas generadas por Stan a las cifras que un instituto nacional de estadística puede publicar. El recorrido comprende seis etapas: la extracción del resumen posterior estándar, el acceso a las muestras brutas para calcular intervalos de credibilidad, la construcción de estimaciones puntuales a nivel de segmento censal que respetan el estado de cobertura del operativo, la agregación coherente a niveles geográficos superiores, la verificación predictiva posterior del ajuste y, por último, los criterios de información empleados para comparar especificaciones alternativas del modelo.


### Estimaciones puntuales y resumen posterior

Una vez finalizado el proceso de inferencia, el objeto `stan_model` contiene las muestras de la distribución posterior de todos los parámetros y cantidades generadas por el modelo. A partir de estas muestras es posible obtener estimaciones puntuales, intervalos de credibilidad y diagnósticos de convergencia mediante la función `summary()`, como se muestra en el Código \@ref(exr:cod-resumen-posterior).

::: {.exercise #cod-resumen-posterior name="Resumen posterior de los parámetros"}

```r
# Resumen de todos los parámetros
params <- summary(stan_model)$summary

# Resumen específico de parámetros de interés
densidad_obs  <- summary(stan_model, pars = "densidad")$summary
densidad_pred <- summary(stan_model, pars = "densidad_hat")$summary
Y_tot_pred    <- summary(stan_model, pars = "Y_tot")$summary
```

:::

La función `summary()` resume tanto los parámetros del modelo como las cantidades generadas durante el proceso de inferencia. Cada fila corresponde a un parámetro o cantidad derivada, mientras que las columnas contienen las principales estadísticas descriptivas de la distribución posterior. La Tabla \@ref(tab:resumen-posterior-columnas) resume la interpretación de cada una de ellas.

| Columna | Descripción |
|---------|-------------|
| `mean` | Esperanza de la distribución posterior, utilizada habitualmente como estimación puntual. |
| `se_mean` | Error estándar de Monte Carlo asociado a la estimación de la media posterior. |
| `sd` | Desviación estándar de la distribución posterior. |
| `2.5%`, `25%`, `75%`, `97.5%` | Percentiles de la distribución posterior; los percentiles `2.5%` y `97.5%` delimitan el intervalo de credibilidad del 95%. |
| `50%` | Mediana de la distribución posterior. |
| `n_eff` | Tamaño efectivo de muestra. |
| `Rhat` | Estadístico de convergencia potencial $\hat{R}$. |

Table: (\#tab:resumen-posterior-columnas) Estadísticas reportadas por `summary(stan_model)$summary` para cada parámetro o cantidad generada.

En los modelos desarrollados en este libro, las estimaciones de mayor interés corresponden a las densidades poblacionales (`densidad`, `densidad_hat`) y a los conteos poblacionales predichos (`Y_tot`). La media posterior constituye el estimador de Bayes bajo pérdida cuadrática y, por tanto, suele emplearse como estimación puntual cuando el objetivo es producir estimaciones y realizar agregaciones territoriales. La mediana posterior, en cambio, es el estimador de Bayes bajo pérdida absoluta y puede resultar preferible cuando la distribución posterior presenta una marcada asimetría o colas pesadas [@Gelman2013].

La diferencia entre ambas medidas resume el grado de asimetría de la distribución posterior. En el caso de los conteos predichos (`Y_tot`), esta diferencia puede evaluarse comparando los totales nacionales obtenidos mediante `sum(Y_tot_pred[, "mean"])` y `sum(Y_tot_pred[, "50%"])`. Aunque en muchas aplicaciones ambas estimaciones son similares, diferencias apreciables indican distribuciones predictivas asimétricas y conviene documentarlas en los reportes técnicos.

Los estadísticos `Rhat` y `n_eff` permiten, además, evaluar la calidad del proceso de muestreo. Mientras la media, la mediana y los intervalos de credibilidad resumen la distribución posterior de los parámetros, estos diagnósticos indican si las cadenas de Markov convergieron adecuadamente y si el número de muestras efectivas es suficiente para sustentar las inferencias realizadas. Su interpretación se desarrolla en las Secciones \@ref(estadistico-rhat) y \@ref(tamano-efectivo-muestra) del capítulo siguiente.


### Extracción de muestras e intervalos de credibilidad

El resumen posterior recién descrito reporta estadísticas marginales por parámetro, pero las agregaciones territoriales que se desarrollan más adelante en este capítulo requieren operar directamente sobre las muestras conjuntas, no sobre sus resúmenes. La función `rstan::extract()` extrae las muestras brutas de la distribución posterior en forma de arreglos, lo que permite calcular cualquier funcional que no esté incluido en el resumen estándar, tal como se ilustra en el Código \@ref(exr:cod-extraccion-muestras):

::: {.exercise #cod-extraccion-muestras name="Extracción de muestras posteriores"}

```r
# Extraer muestras posteriores de los parámetros de interés
posterior_samples <- rstan::extract(
  stan_model,
  pars = c("densidad", "Y_tot", "densidad_hat")
)

# densidad_post: matriz de dimensión T × D_obs
densidad_post <- posterior_samples$densidad

# Y_tot_samp: matriz de dimensión T × D_tot
Y_tot_samp <- posterior_samples$Y_tot
```

:::

El intervalo de credibilidad al 95% para el conteo del segmento $d$ se calcula como:

$$
\text{IC}_{95\%}(Y_d) = \left[F_{Y_d}^{-1}(0{,}025),\; F_{Y_d}^{-1}(0{,}975)\right]
$$

donde $F_{Y_d}^{-1}$ denota el cuantil empírico de las $T$ muestras de `Y_tot_samp[, d]`. A diferencia de los intervalos de confianza frecuentistas, el intervalo de credibilidad tiene una interpretación probabilística directa: dada la información observada y el modelo, la probabilidad posterior de que $Y_d$ caiga en ese intervalo es 0,95 [@Gelman2013]. Esta propiedad facilita la comunicación de la incertidumbre a usuarios institucionales no especializados en estadística.

### Estimaciones a nivel de segmento censal

El mismo mecanismo de extracción de muestras permite ir un paso más allá del intervalo de credibilidad genérico y construir la estimación final de población que efectivamente se reporta en la producción estadística, la cual depende del estado de cobertura censal de cada segmento. La predicción del conteo poblacional para cada segmento del país combina, en efecto, la información directa del censo con las predicciones del modelo según ese estado de cobertura. El objeto `data_model` es el data frame de segmentos censales construido durante la preparación de insumos (Capítulo \@ref(cap-insumos)), con una fila por segmento; incluye el identificador operativo del segmento (`ED`, *enumeration district*), el conteo de personas efectivamente registrado en el censo (`T_pers`) y el estado de cobertura del operativo (`Status`). Siguiendo la terminología operativa de los censos del Caribe anglófono en los que se aplicó este modelo (Barbados, Jamaica, Dominica), `Status` distingue cuatro situaciones: cobertura completa (`"Completed-full"`), segmento no abordado (`"Not Attempted"`), y dos formas de cobertura parcial —con rechazos (`"Completed-with refusals"`) o incompleta por otras razones (`"Completed-partial"`)—, como se muestra en el Código \@ref(exr:cod-estimaciones-segmento):

::: {.exercise #cod-estimaciones-segmento name="Estimación puntual e incertidumbre por segmento censal"}

```r
library(tidyverse)

# Extraer predicciones como data frame
df_y_pred <- data.frame(t(Y_tot_samp))
colnames(df_y_pred) <- paste0("pred_cont_", seq_len(ncol(df_y_pred)))

# Unir con metadatos del segmento
df_y_pred <- data_model %>%
  select(ED:Status) %>%
  bind_cols(df_y_pred)

pred_cols <- grep("^pred_cont_", names(df_y_pred), value = TRUE)

# Calcular estimación puntual y medidas de incertidumbre por segmento
estimaciones_segmento <- df_y_pred %>%
  rowwise() %>%
  mutate(
    pob_media  = mean(c_across(all_of(pred_cols))),
    pob_mediana = median(c_across(all_of(pred_cols))),
    pob_sd     = sd(c_across(all_of(pred_cols))),
    pob_li_95  = quantile(c_across(all_of(pred_cols)), 0.025),
    pob_ls_95  = quantile(c_across(all_of(pred_cols)), 0.975)
  ) %>%
  ungroup()
```

:::

La estimación definitiva del conteo de cada segmento aplica la regla del Código \@ref(exr:cod-regla-cobertura) según el estado de cobertura:

::: {.exercise #cod-regla-cobertura name="Regla de estimación final según el estado de cobertura"}

```r
estimaciones_segmento <- estimaciones_segmento %>%
  mutate(
    pob_final = case_when(
      # Cobertura completa: se usa directamente el conteo censal
      Status == "Completed-full"  ~ T_pers,
      # Sin cobertura: se usa la predicción del modelo
      Status == "Not Attempted"   ~ pob_media,
      # Cobertura parcial con subenumeración: se usa la predicción
      Status %in% c("Completed-with refusals", "Completed-partial") &
        T_pers < pob_media        ~ pob_media,
      # Cobertura parcial sin subenumeración evidente: se mantiene el observado
      Status %in% c("Completed-with refusals", "Completed-partial") &
        T_pers >= pob_media       ~ T_pers,
      TRUE ~ NA_real_
    )
  )
```

:::

Esta regla garantiza coherencia operativa y refleja la naturaleza unidireccional del error de cobertura: la omisión genera subenumeración, no sobreconteo. Los segmentos con cobertura completa no son modificados por el modelo; los no abordados reciben íntegramente la predicción bayesiana; los parcialmente cubiertos son tratados según el principio de dominancia descrito en @Mercer2015 para contextos similares de integración de múltiples fuentes.

### Agregación a niveles geográficos superiores

Resuelta la estimación en la unidad mínima de análisis —el segmento censal—, el paso siguiente consiste en agregar esas estimaciones hacia los niveles geográficos que efectivamente se publican: municipios, provincias o el total nacional. La distribución posterior del total de población en cualquier unidad geográfica de nivel superior se obtiene sumando los conteos de los segmentos que la componen a través de cada muestra de la distribución predictiva. Esta propiedad de coherencia por agregación es una de las ventajas del enfoque probabilístico respecto a los métodos de estimación directa [@Rao2015]. El ejemplo siguiente agrega a nivel de `parish` —la unidad administrativa de nivel superior en los países del Caribe anglófono referidos en este capítulo (Barbados, Jamaica, Dominica); en Costa Rica o República Dominicana el mismo procedimiento se aplicaría agrupando por cantón o provincia, respectivamente—, como en el Código \@ref(exr:cod-agregacion-geografica):

::: {.exercise #cod-agregacion-geografica name="Agregación territorial con intervalos de credibilidad"}

```r
# Agregación a nivel parroquial con intervalo de credibilidad
estimaciones_parroquia <- df_y_pred %>%
  group_by(parish) %>%
  summarise(
    across(all_of(pred_cols), sum, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  rowwise() %>%
  mutate(
    tot_pob_media = mean(c_across(all_of(pred_cols))),
    tot_pob_sd    = sd(c_across(all_of(pred_cols))),
    tot_pob_li_95 = quantile(c_across(all_of(pred_cols)), 0.025),
    tot_pob_ls_95 = quantile(c_across(all_of(pred_cols)), 0.975),
    len_ic        = tot_pob_ls_95 - tot_pob_li_95
  ) %>%
  ungroup()

# Total nacional con intervalo de credibilidad
estimacion_nacional <- df_y_pred %>%
  summarise(across(all_of(pred_cols), sum, na.rm = TRUE)) %>%
  pivot_longer(everything(), names_to = "iteracion", values_to = "total_pob") %>%
  summarise(
    media   = mean(total_pob),
    sd      = sd(total_pob),
    li_95   = quantile(total_pob, 0.025),
    ls_95   = quantile(total_pob, 0.975),
    mediana = median(total_pob)
  )
```

:::

La amplitud del intervalo de credibilidad del total nacional refleja simultáneamente la incertidumbre sobre los parámetros del modelo y la variabilidad estocástica del proceso de Poisson en cada segmento. En aplicaciones prácticas, este intervalo es usualmente estrecho en comparación con el total estimado porque la mayor parte de la variabilidad individual se cancela en la suma; pero puede ser sustancialmente amplio para unidades geográficas con pocos segmentos y baja cobertura censal.

### Verificación predictiva posterior

Las estimaciones puntuales y sus intervalos de credibilidad, calculados hasta aquí en todos los niveles de agregación, son tan confiables como lo sea el modelo del que provienen. Antes de dar por válidas estas cifras corresponde, entonces, verificar la calidad del ajuste comparando los datos observados con réplicas generadas por el propio modelo [@Gabry2019]. En el contexto del modelo Poisson-lognormal, es más informativo verificar la capacidad predictiva sobre la densidad $\delta_i = Y_i/V_i$ que directamente sobre los conteos, ya que la densidad es la cantidad central del modelo y su distribución no depende del número de estructuras, según el Código \@ref(exr:cod-ppc-densidad):

::: {.exercise #cod-ppc-densidad name="Verificación predictiva posterior de la densidad"}

```r
# Subconjunto aleatorio de muestras de densidad
densidad_post <- posterior_samples$densidad
idx_muestra   <- sample(nrow(densidad_post), 500)
densidad_rep  <- densidad_post[idx_muestra, ]

# Gráfico de verificación predictiva posterior
ppc_dens <- bayesplot::ppc_dens_overlay(
  y    = as.numeric(Y_obs / V_obs),
  yrep = densidad_rep
)

# Verificación sobre los conteos brutos
ppc_pers <- bayesplot::ppc_dens_overlay(
  y    = as.numeric(Y_obs),
  yrep = t(t(densidad_rep) * V_obs)
)

ppc_dens | ppc_pers
```

:::

En este gráfico [@bayesplot2022], la línea sólida corresponde a la distribución empírica de los datos observados y las líneas semitransparentes representan las distribuciones predictivas generadas por las muestras posteriores. Un modelo bien especificado produce líneas predictivas que envuelven razonablemente bien la distribución observada sin exceso ni defecto sistemático. Desviaciones importantes señalan limitaciones del modelo que pueden orientar la reformulación del predictor lineal o el cambio de la distribución de la densidad latente [@Gabry2019].

### Criterios de información LOO y WAIC

La verificación predictiva posterior confirma, o cuestiona, el ajuste de una única especificación del modelo. Cuando existen especificaciones alternativas —distintos subconjuntos de covariables o distintas estructuras de efectos aleatorios, por ejemplo— se requiere además un criterio cuantitativo que permita compararlas de manera formal, sin recurrir a validación cruzada explícita [@Vehtari2017]. El criterio LOO-CV y el WAIC [@Watanabe2010] cumplen ese papel, calculándose ambos a partir de la log-verosimilitud evaluada en cada muestra posterior, como muestra el Código \@ref(exr:cod-loo-waic):

::: {.exercise #cod-loo-waic name="Cálculo de los criterios LOO y WAIC"}

```r
# Extraer log-verosimilitud puntual (una columna por segmento observado)
log_lik_mat <- loo::extract_log_lik(stan_model,
                                     parameter_name = "log_lik")

# WAIC y LOO-CV
waic_result <- loo::waic(log_lik_mat)
loo_result  <- loo::loo(log_lik_mat)

print(waic_result)
print(loo_result)

# Comparar dos especificaciones alternativas
loo::loo_compare(loo_modelo_1, loo_modelo_2)
```

:::

Valores más altos de elpd-LOO (*expected log predictive density*) indican mejor capacidad predictiva fuera de muestra [@Vehtari2017]. En la comparación entre modelos, una diferencia en elpd superior al doble de su error estándar se interpreta como evidencia de diferencia predictiva sustancial. La comparación entre LOO y WAIC en presencia de observaciones influyentes —frecuentes en segmentos con conteos extremos— se discute en @Piironen2017, que concluye que LOO es más robusto en esos contextos y debe ser el criterio principal para la selección del modelo final.


## Resumen

Este capítulo describió el ciclo completo de inferencia computacional para el modelo Poisson-lognormal: desde los fundamentos del algoritmo HMC-NUTS [@Hoffman2014; @Betancourt2017], pasando por la implementación en Stan [@Carpenter2017] con los cinco bloques del programa, hasta el procedimiento de extracción de estimaciones puntuales, intervalos de credibilidad y agregaciones territoriales en R mediante `rstan` [@rstan2023], `bayesplot` [@bayesplot2022] y `loo` [@loo2022; @Vehtari2017]. Las aplicaciones desarrolladas en esos cinco países del Caribe y América Latina ilustraron cómo los parámetros de implementación —selección de covariables, fuente del offset, umbral de densidad y configuración MCMC— se adaptan al contexto de cada operativo censal sin alterar la especificación estadística del modelo. El capítulo incluyó además el diagnóstico de convergencia mediante los estadísticos $\hat{R}$ y ESS [@Vehtari2021; @Gelman1992], la validación predictiva posterior [@Gabry2019] y la selección entre modelos alternativos mediante los criterios LOO y WAIC [@Vehtari2017; @Watanabe2010]. El capítulo siguiente profundiza en estos diagnósticos —trazas, autocorrelación y diagnósticos específicos de HMC, residuos bayesianos y calibración, criterios formales de aceptación de modelos— y añade la validación externa frente a proyecciones demográficas, registros administrativos independientes y coherencia geoespacial, como verificación final antes de la publicación de estimaciones oficiales.
