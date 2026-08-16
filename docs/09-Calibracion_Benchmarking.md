# Calibración y Benchmarking Subnacional {#cap-calibracion}

El Capítulo \@ref(cap-diagnostico) estableció los criterios de convergencia, validación predictiva y validación externa que un modelo Poisson-lognormal debe satisfacer antes de que sus estimaciones puedan utilizarse en la producción de estadísticas oficiales de población. Sin embargo, la validación de un modelo no resuelve por sí sola un problema adicional, frecuente en la práctica institucional: los organismos nacionales de estadística suelen requerir que las estimaciones subnacionales, al agregarse, coincidan exactamente con totales de referencia fijados de manera independiente al modelo —un total nacional publicado oficialmente, una cifra departamental proveniente de un recuento preliminar de mayor confiabilidad, o una proyección demográfica considerada autoridad institucional para efectos de asignación presupuestaria—. Este capítulo desarrolla el conjunto de técnicas conocidas como calibración o *benchmarking*, orientadas a conciliar las estimaciones del modelo con dichos totales de control, preservando en la mayor medida posible la información distribucional aportada por el modelo bayesiano.

La estructura del capítulo comprende tres secciones. La primera examina por qué surge la necesidad de calibración y distingue formalmente la coherencia jerárquica interna del modelo —ya garantizada por construcción, según se estableció en el Capítulo \@ref(cap-inferencia)— de la coherencia externa frente a totales de control, que no está garantizada y constituye el objeto propio del benchmarking. La segunda presenta los métodos de calibración: el ajuste proporcional clásico, el ajuste ponderado por precisión y su extensión aditiva a la distribución posterior completa. La tercera evalúa el impacto de la calibración sobre las estimaciones puntuales, con un ejemplo aplicado sobre las mismas unidades territoriales del Capítulo \@ref(cap-inferencia).

## Benchmarking con proyecciones poblacionales

Esta sección examina la primera de las tres etapas del capítulo: por qué un modelo bayesiano de estimación subnacional puede requerir conciliarse con totales que no provienen del propio modelo, y qué distingue esta necesidad de coherencia externa de la coherencia jerárquica interna que el modelo ya garantiza por construcción. La distinción es importante porque determina qué problema resuelve el benchmarking y cuál no: no corrige errores de especificación del modelo ni sustituye a la validación del Capítulo \@ref(cap-diagnostico), sino que concilia una estimación ya validada con información adicional que el modelo, por diseño, no incorporó directamente en su ajuste.

### Necesidad de coherencia entre niveles geográficos

Los organismos nacionales de estadística rara vez producen una estimación de población de manera aislada: para un mismo dominio geográfico suele existir, además de las estimaciones del modelo, al menos otra fuente de información sobre el tamaño de la población —un preconteo operativo levantado en una etapa previa del mismo censo, información auxiliar proveniente de registros administrativos con cobertura casi completa, un recuento independiente realizado posteriormente en áreas específicas, o resultados preliminares y proyecciones demográficas construidos a partir de fuentes distintas al operativo censal—. Cuando el total nacional o departamental implícito en las estimaciones del modelo difiere de estas cifras externas, la discrepancia plantea una pregunta metodológica que trasciende el ajuste del modelo: cómo conciliar ambas fuentes sin descartar la información que cada una aporta. Dos totales distintos y no reconciliados para la misma población, obtenidos por procedimientos independientes, generan confusión y erosionan la confianza en las estadísticas oficiales, incluso cuando ambas cifras sean, en principio, estimaciones razonables.

Esta necesidad de coherencia con totales externos —sean estos información auxiliar, resultados preliminares, recuentos independientes u otras fuentes estadísticamente confiables— es un problema clásico dentro de la Estimación en Áreas Pequeñas [@Rao2015], habitualmente abordado bajo el término *benchmarking*. La particularidad del enfoque bayesiano desarrollado en este libro es que dicho ajuste debe realizarse preservando la coherencia probabilística de las estimaciones: no solo el valor puntual, sino la distribución posterior completa, incluidos los intervalos de credibilidad, deben ajustarse de manera consistente con el nuevo total exigido.

### Restricciones de consistencia jerárquica

Es necesario distinguir dos nociones de coherencia que, aunque relacionadas, tienen naturaleza distinta. La primera es la **coherencia jerárquica interna** del modelo, definida formalmente en el Capítulo \@ref(cap-inferencia): dado que las predicciones $\tilde{Y}_i^{(t)}$ para cada segmento se generan dentro de la misma muestra posterior $t$, su agregación es automáticamente consistente entre niveles geográficos para cualquier muestra individual:

$$
\tilde{N}_k^{(3),(t)} = \sum_{i \,\in\, \mathcal{S}_k} \tilde{Y}_i^{(t)}, \qquad \tilde{N}_j^{(2),(t)} = \sum_{k \,:\, k \subset j} \tilde{N}_k^{(3),(t)}
$$

Se mantiene la tilde, y no un acento circunflejo, sobre ambas cantidades: al igual que $\tilde{Y}_i^{(t)}$, son réplicas generadas para una muestra posterior específica y no resúmenes puntuales, siguiendo la misma convención empleada más adelante en este capítulo para $\tilde{N}_j^{bench,(t)}$. Esta propiedad no requiere ningún procedimiento adicional: es una consecuencia directa de sumar predicciones generadas conjuntamente a partir del mismo vector de parámetros $\boldsymbol{\theta}^{(t)}$, y se mantiene exactamente en cada una de las $T$ muestras posteriores.

Por ejemplo, supóngase que un municipio $j$ contiene dos áreas $k_1$ y $k_2$, cada una formada por tres segmentos. Para una muestra posterior $t$, las predicciones podrían ser $\tilde{N}_{k_1}^{(3),(t)} = 120+85+95=300$ y $\tilde{N}_{k_2}^{(3),(t)} = 110+140+150=400$, de modo que el total municipal en esa muestra es necesariamente $\tilde{N}_j^{(2),(t)}=300+400=700$: la misma relación se cumple en cada una de las $T$ muestras, sin ningún procedimiento adicional.

La segunda noción es la **coherencia externa** frente a un total de control $N_j^*$ que no proviene del modelo —una cifra oficial, una proyección demográfica institucional o un recuento independiente—. En general, el total implícito en el modelo, resumido mediante su media posterior,

$$
\hat{N}_j = \mathbb{E}\!\left[\tilde{N}_j^{(2)} \mid \mathbf{Y}_{obs}\right] \approx \frac{1}{T}\sum_{t=1}^{T} \tilde{N}_j^{(2),(t)}
$$

no coincide exactamente con $N_j^*$, y no existe razón estadística para esperar que lo haga: el modelo y el total de control son, casi siempre, dos estimaciones distintas de la misma cantidad, obtenidas por procedimientos independientes. Retomando el ejemplo anterior, si el modelo estima $\hat{N}_j = 700$ habitantes para el municipio y una proyección demográfica reporta $N_j^{*}=750$, la discrepancia es

$$
\Delta = N_j^{*}-\hat{N}_j = 750-700=50,
$$

la misma cantidad que la subsección siguiente formaliza, con esta misma notación, para un conjunto de $K$ unidades geográficas cualesquiera. Esta diferencia no implica por sí misma un error del modelo, ya que ambas cantidades proceden de fuentes y procedimientos distintos; constituye, sin embargo, una señal que debe evaluarse en el proceso de validación. Es esta segunda forma de incoherencia —y no la primera, que ya está resuelta por construcción— la que constituye el objeto del benchmarking.

Si posteriormente se aplica un procedimiento de benchmarking para conciliar el total municipal con $N_j^*$, el ajuste debe preservar la consistencia con sus áreas componentes. Con el factor proporcional $\phi$ que la sección de Métodos de benchmarking formaliza más adelante,

$$
\phi = \frac{N_j^{*}}{\hat{N}_j} = \frac{750}{700} \approx 1,0714,
$$

las estimaciones de las dos áreas pasarían de $300$ y $400$ a aproximadamente $321,4$ y $428,6$, respectivamente, preservando la suma ($321,4+428,6=750$). Un aspecto crítico, que debe tenerse presente siempre que existan totales de control en más de un nivel geográfico a la vez, es que la calibración externa, al modificar los totales de un nivel, puede romper la coherencia jerárquica interna con los niveles adyacentes si no se propaga de manera consistente a través de la jerarquía territorial: calibrar cada nivel de forma aislada no garantiza que las unidades ya calibradas de un nivel sumen exactamente al total ya calibrado del nivel superior.

### Relación entre estimaciones locales y totales conocidos

Sea $N^{*}$ un total de control conocido para un conjunto de $K$ unidades geográficas de un mismo nivel, y sean $\hat{N}_1,\ldots,\hat{N}_K$ las estimaciones puntuales obtenidas mediante el modelo. Su total implícito es

$$
\hat{N}_{+}=\sum_{\ell=1}^{K}\hat{N}_{\ell},
$$

y la discrepancia respecto al total de control se define como

$$
\Delta=N^{*}-\hat{N}_{+}.
$$

El *benchmarking* consiste en obtener estimaciones ajustadas $\hat{N}_1^{bench},\ldots,\hat{N}_K^{bench}$ que satisfagan

$$
\sum_{\ell=1}^{K}\hat{N}_{\ell}^{bench}=N^{*},
$$

procurando modificar lo menos posible las estimaciones originales. La forma en que se distribuye la discrepancia $\Delta$ entre las unidades depende del método de benchmarking utilizado y puede considerar, entre otros criterios, el tamaño de las unidades o la precisión de sus estimaciones.

## Métodos de benchmarking

Los métodos de *benchmarking* permiten ajustar las estimaciones locales obtenidas por el modelo para que sean consistentes con uno o más totales de control conocidos. La diferencia entre los métodos radica principalmente en cómo se distribuye el ajuste entre las unidades y cuánto se modifica cada estimación respecto a su valor original.

En los modelos de población, esta decisión es especialmente relevante porque las unidades pueden diferir considerablemente en la calidad de la información disponible y en la incertidumbre de sus estimaciones. Un método puede distribuir el ajuste de manera proporcional al tamaño de las unidades, mientras que otros pueden asignar una mayor parte de la discrepancia a las estimaciones con mayor incertidumbre. En todos los casos, el método debe preservar la restricción de agregación establecida por el total de control.

### Benchmarking proporcional

El método más simple y de mayor tradición en la práctica de oficinas de estadística es el ajuste proporcional (*ratio benchmarking*), empleado desde los primeros desarrollos de estimaciones postcensales de población en dominios pequeños [@PurcellKish1980] y documentado extensamente en la literatura de Estimación en Áreas Pequeñas [@Rao2015], que distribuye la discrepancia $\Delta$ en proporción al tamaño relativo de cada unidad. El factor de ajuste se define como:

$$
\phi = \frac{N^{*}}{\hat{N}_{+}}
$$

y la estimación calibrada de cada unidad es:

$$
\hat{N}_\ell^{bench} = \hat{N}_\ell \cdot \phi = \hat{N}_\ell \cdot \frac{N^{*}}{\hat{N}_{+}}
$$

Por construcción, $\sum_{\ell=1}^{K} \hat{N}_\ell^{bench} = \phi \sum_{\ell=1}^{K} \hat{N}_\ell = \phi \, \hat{N}_{+} = N^{*}$, de modo que la restricción de suma se satisface exactamente. El método preserva las proporciones relativas entre unidades —si $\hat{N}_a / \hat{N}_b = 2$ antes del ajuste, la misma razón se mantiene después—, lo que lo hace fácil de comunicar e implementar. Su principal limitación es que aplica el mismo factor multiplicativo $\phi$ a todas las unidades, sin distinguir entre aquellas cuya estimación es precisa —con posterior concentrada y $\text{Var}(\hat{N}_\ell \mid \mathbf{Y}_{obs})$ pequeña, típicamente unidades con buena cobertura censal directa— y aquellas cuya estimación depende casi enteramente de la estructura jerárquica del modelo, con incertidumbre considerablemente mayor. El ajuste proporcional penaliza a ambos tipos de unidad por igual, en contraste con el principio de que la información más incierta debería absorber una proporción mayor de cualquier corrección externa.

### Benchmarking ponderado por incertidumbre

El benchmarking ponderado por incertidumbre distribuye la discrepancia $\Delta$ entre las unidades de acuerdo con la incertidumbre de sus estimaciones. La idea es sencilla: si una unidad tiene una estimación muy precisa, debería modificarse poco; si otra presenta mayor incertidumbre, puede absorber una mayor parte del ajuste. Esta característica lo diferencia del benchmarking proporcional, que aplica el mismo factor relativo a todas las unidades [@Datta2011].

Las estimaciones ajustadas se obtienen buscando los valores más cercanos a las estimaciones originales que, al mismo tiempo, reproduzcan exactamente el total de control $N^{*}$. Formalmente:

$$
\min_{{\hat{N}_\ell^{bench}}}
\sum_{\ell=1}^{K}
\frac{
\left(\hat{N}_\ell^{bench}-\hat{N}_\ell\right)^2
}{w_\ell}
\qquad
\text{sujeto a}
\qquad
\sum_{\ell=1}^{K}\hat{N}_\ell^{bench}=N^{*},
$$

donde $w_\ell>0$ representa la incertidumbre asociada a la estimación de la unidad $\ell$. La solución es:

$$
\hat{N}_\ell^{bench} = \hat{N}_\ell +
\frac{w_\ell}
{\sum_{\ell'=1}^{K}w_{\ell'}}
\left(N^{*}-\hat{N}_{+}\right),
$$

donde $\ell'$ es un índice mudo que recorre las mismas $K$ unidades que $\ell$: se usa una letra distinta únicamente para no confundir la unidad específica $\ell$ que se está calibrando con las unidades sobre las que se suma en el denominador, de modo que $\sum_{\ell'=1}^{K}w_{\ell'} = w_1+\cdots+w_K$ es simplemente la suma de todos los pesos. Además,

$$
\hat{N}_{+}=\sum_{\ell=1}^{K}\hat{N}_\ell.
$$

La expresión muestra cómo se distribuye el ajuste. La unidad $\ell$ recibe la fracción

$$
\frac{w_\ell}{\sum_{\ell'=1}^{K}w_{\ell'}}
$$

de la discrepancia total. Por ejemplo, si tres unidades tienen pesos $1$, $2$ y $3$, respectivamente, reciben $1/6$, $2/6$ y $3/6$ del ajuste. Así, una unidad con el triple de incertidumbre que otra recibe el triple de la corrección.

En el enfoque bayesiano desarrollado en este libro, una elección natural para $w_\ell$ es la varianza posterior de la población estimada. Si $\hat{N}_\ell$ representa la media posterior, esta se estima a partir de las $T$ muestras posteriores mediante:

$$
w_\ell = \operatorname{Var}
\left( \hat{N}_\ell\mid\mathbf{Y}_{obs} \right)
\approx
\frac{1}{T-1} \sum_{t=1}^{T}
\left(\hat{N}_\ell^{(t)}-\hat{N}_\ell\right)^2.
$$

Con esta elección, las unidades cuya población estimada presenta mayor incertidumbre posterior absorben una mayor proporción de la discrepancia, mientras que las estimaciones más precisas se modifican en menor medida. En todos los casos, el procedimiento garantiza que:

$$
\sum_{\ell=1}^{K}\hat{N}_\ell^{bench}=N^{*}.
$$


### Benchmarking aditivo con restricciones de suma

Los dos métodos anteriores calibran únicamente la estimación puntual, dejando sin ajustar la distribución posterior completa. Esto es insuficiente en un marco bayesiano: si solo se recalibra la media posterior y los intervalos de credibilidad se calculan sobre las muestras originales sin ajustar, la incertidumbre reportada resulta inconsistente con la estimación puntual calibrada. La extensión adecuada, propuesta como benchmarking *totalmente bayesiano* por @ZhangBryant2020, consiste en aplicar el ajuste a cada una de las $T$ muestras de la distribución predictiva posterior, de manera que la restricción de suma se satisfaga en cada muestra individual y no solo en la media.

El ajuste proporcional por muestra se define como:

$$
\tilde{N}_\ell^{bench,(t)} = \tilde{N}_\ell^{(t)} \cdot \frac{N^{*}}{\sum_{\ell'=1}^{K} \tilde{N}_{\ell'}^{(t)}}, \qquad t = 1, \ldots, T
$$

Nótese que el factor de ajuste $\phi^{(t)} = N^{*} / \sum_{\ell'} \tilde{N}_{\ell'}^{(t)}$ varía entre muestras, dado que el total agregado del modelo fluctúa de una muestra posterior a otra como consecuencia del proceso de Poisson subyacente. Esta variación del factor de ajuste entre muestras es precisamente lo que permite que la incertidumbre del proceso de calibración se propague correctamente hacia los intervalos de credibilidad calibrados.

El ajuste aditivo ponderado por muestra sigue la misma lógica que el benchmarking ponderado por incertidumbre, aplicado ahora sobre cada muestra individual:

$$
\tilde{N}_\ell^{bench,(t)} = \tilde{N}_\ell^{(t)} + w_\ell \cdot \frac{N^{*} - \sum_{\ell'=1}^{K} \tilde{N}_{\ell'}^{(t)}}{\sum_{\ell'=1}^{K} w_{\ell'}}, \qquad t = 1, \ldots, T
$$

## Evaluación del impacto del benchmarking

La calibración modifica las estimaciones producidas por un modelo previamente validado, y esta modificación debe documentarse y evaluarse explícitamente, tanto en su efecto sobre las estimaciones puntuales como sobre la incertidumbre reportada.

### Cambio en estimaciones puntuales

El cambio relativo introducido por la calibración en la unidad $\ell$ se define como:

$$
\eta_\ell = \frac{\hat{N}_\ell^{bench} - \hat{N}_\ell}{\hat{N}_\ell}
$$

Bajo el ajuste proporcional, $\eta_\ell = \phi - 1$ es idéntico para todas las unidades, independientemente de su tamaño o de la precisión de su estimación. Bajo el ajuste ponderado por precisión, $\eta_\ell$ varía sistemáticamente entre unidades: se espera una relación positiva entre $\eta_\ell$ y la incertidumbre posterior relativa de la unidad, de modo que las unidades con estimaciones más precisas —mayor cobertura censal directa— exhiban valores de $\eta_\ell$ cercanos a cero, mientras que las unidades con mayor dependencia de la estructura jerárquica del modelo absorban una proporción mayor del ajuste.

### Ejemplo aplicado

Este ejemplo retoma las mismas 11 unidades territoriales y las mismas estimaciones agregadas de la Tabla \@ref(tab:ejemplo-agregacion) del Capítulo \@ref(cap-inferencia), pero bajo un supuesto distinto al de la sección anterior: en vez de un único total de control agregado que hay que distribuir con pesos, se dispone de una referencia externa propia para cada una de las 11 unidades —por ejemplo, una proyección demográfica calculada independientemente al mismo nivel de agregación—. Cuando la información externa ya está disponible por unidad, la calibración no requiere distribuir nada: se compara directamente cada unidad con su propia referencia, sin necesidad de la fórmula de pesos de la sección anterior. El Código \@ref(exr:cod-benchmarking-ejemplo) agrega las unidades y calcula ese cambio directo:

::: {.exercise #cod-benchmarking-ejemplo name="Benchmarking directo contra una referencia externa por unidad"}

```r
# Segmentos del ejemplo aplicado (Capítulo 7)
pred_area <- readRDS("Data/rutinas/Output/Base_input.rds")

unidades <- pred_area %>%
  group_by(unidad_value) %>%
  summarise(N_hat = sum(pob_final_media), .groups = "drop") %>%
  arrange(desc(N_hat)) %>%
  mutate(`Unidad territorial` = paste("Unidad", row_number()), .before = 1)

# Referencia externa dada por unidad (p. ej., una proyección demográfica
# calculada de forma independiente al mismo nivel de agregación)
referencia_externa <- tibble(
  `Unidad territorial` = paste("Unidad", 1:11),
  N_ext = c(80636, 59436, 31589, 29764, 25554,
            17418, 13732, 12187, 11217, 10352, 5719)
)

unidades <- unidades %>%
  left_join(referencia_externa, by = "Unidad territorial") %>%
  mutate(eta_directo = (N_ext - N_hat) / N_hat)
```

:::

El Código \@ref(exr:cod-benchmarking-proporcional-ejemplo) añade el contraste: si solo se conociera el total agregado de esas 11 referencias —sin el detalle por unidad—, `benchmarking_proporcional()`, ya definida en la Sección "Benchmarking proporcional", habría aplicado el mismo factor a las 11 unidades:

::: {.exercise #cod-benchmarking-proporcional-ejemplo name="Contraste con el benchmarking proporcional sobre el total agregado"}

```r
benchmarking_proporcional <- function(N_hat, N_control) {
  phi <- N_control / sum(N_hat)
  N_hat * phi
}

N_star <- sum(unidades$N_ext)
unidades <- unidades %>%
  mutate(
    N_bench_prop = benchmarking_proporcional(N_hat, N_star),
    eta_prop     = N_star / sum(N_hat) - 1
  )
```

:::


La Tabla \@ref(tab:ejemplo-benchmarking-unidades) muestra el resultado de calibrar contra esa referencia: la estimación antes de calibrar ($\hat{N}_\ell$), la referencia externa dada ($N_\ell^{*}$) y el cambio directo que implica —el $\eta_\ell$ definido en la Sección "Cambio en estimaciones puntuales"—, junto al cambio que habría aplicado el benchmarking proporcional si solo se hubiera conocido el total agregado de esas 11 referencias ($N^{*}=\sum_\ell N_\ell^{*}=297.604$):

<table class="table" style="width: auto !important; margin-left: auto; margin-right: auto;">
<caption>(\#tab:ejemplo-benchmarking-unidades)Benchmarking directo contra una referencia externa por unidad, comparado con el benchmarking proporcional sobre el total agregado, para las 11 unidades territoriales.</caption>
 <thead>
  <tr>
   <th style="text-align:center;"> Unidad </th>
   <th style="text-align:center;"> $\hat{N}_\ell$ (antes) </th>
   <th style="text-align:center;"> $N_\ell^{*}$ (referencia) </th>
   <th style="text-align:center;"> $\eta_\ell$ (directo) </th>
   <th style="text-align:center;"> $\eta_\ell$ (prop.) </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:center;"> Unidad 6 </td>
   <td style="text-align:center;"> 16291 </td>
   <td style="text-align:center;"> 17418 </td>
   <td style="text-align:center;"> 0.069 </td>
   <td style="text-align:center;"> 0.055 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> Unidad 8 </td>
   <td style="text-align:center;"> 11405 </td>
   <td style="text-align:center;"> 12187 </td>
   <td style="text-align:center;"> 0.069 </td>
   <td style="text-align:center;"> 0.055 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> Unidad 5 </td>
   <td style="text-align:center;"> 23949 </td>
   <td style="text-align:center;"> 25554 </td>
   <td style="text-align:center;"> 0.067 </td>
   <td style="text-align:center;"> 0.055 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> Unidad 11 </td>
   <td style="text-align:center;"> 5367 </td>
   <td style="text-align:center;"> 5719 </td>
   <td style="text-align:center;"> 0.066 </td>
   <td style="text-align:center;"> 0.055 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> Unidad 10 </td>
   <td style="text-align:center;"> 9771 </td>
   <td style="text-align:center;"> 10352 </td>
   <td style="text-align:center;"> 0.059 </td>
   <td style="text-align:center;"> 0.055 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> Unidad 7 </td>
   <td style="text-align:center;"> 12974 </td>
   <td style="text-align:center;"> 13732 </td>
   <td style="text-align:center;"> 0.058 </td>
   <td style="text-align:center;"> 0.055 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> Unidad 4 </td>
   <td style="text-align:center;"> 28186 </td>
   <td style="text-align:center;"> 29764 </td>
   <td style="text-align:center;"> 0.056 </td>
   <td style="text-align:center;"> 0.055 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> Unidad 3 </td>
   <td style="text-align:center;"> 29930 </td>
   <td style="text-align:center;"> 31589 </td>
   <td style="text-align:center;"> 0.055 </td>
   <td style="text-align:center;"> 0.055 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> Unidad 9 </td>
   <td style="text-align:center;"> 10683 </td>
   <td style="text-align:center;"> 11217 </td>
   <td style="text-align:center;"> 0.050 </td>
   <td style="text-align:center;"> 0.055 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> Unidad 2 </td>
   <td style="text-align:center;"> 56633 </td>
   <td style="text-align:center;"> 59436 </td>
   <td style="text-align:center;"> 0.049 </td>
   <td style="text-align:center;"> 0.055 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> Unidad 1 </td>
   <td style="text-align:center;"> 76966 </td>
   <td style="text-align:center;"> 80636 </td>
   <td style="text-align:center;"> 0.048 </td>
   <td style="text-align:center;"> 0.055 </td>
  </tr>
</tbody>
</table>

El cambio relativo por unidad se encuentra entre $4,8%$ (Unidad 1) y $6,9%$ (Unidad 6), mientras que el benchmarking proporcional aplica un incremento uniforme de $5,5%$ a todas las unidades. La diferencia entre ambos métodos refleja la forma en que se distribuye la discrepancia respecto al total de control. En el ajuste proporcional, todas las unidades reciben la misma corrección relativa, independientemente de la incertidumbre de sus estimaciones. En el ajuste ponderado, la corrección se distribuye de acuerdo con los pesos definidos para cada unidad, de modo que aquellas con mayor incertidumbre reciben una proporción mayor del ajuste y aquellas con menor incertidumbre una proporción menor. En ambos casos, las estimaciones ajustadas reproducen exactamente el total de control; la diferencia radica en cómo se distribuye la corrección entre las unidades.


**Benchmarking ponderado por incertidumbre.** Si *no* se hubiera dispuesto de una referencia para cada unidad, sino únicamente del total agregado $N^{*}=297.604$, el Código \@ref(exr:cod-benchmarking-ponderado-ejemplo) distribuye esa discrepancia utilizando como peso $w_\ell$ la varianza posterior de cada unidad —la suma de la varianza posterior de `Y_tot` en sus segmentos, cero para los de cobertura censal completa—, de acuerdo con el método descrito en la sección anterior:

::: {.exercise #cod-benchmarking-ponderado-ejemplo name="Benchmarking ponderado por incertidumbre sobre el ejemplo aplicado"}

```r
# Varianza posterior de Y_tot por segmento (cero si cobertura completa)
stan_summary    <- readRDS("Data/rutinas/Output/05_stan_summary.rds")
y_tot_rows      <- grep("^Y_tot\\[", rownames(stan_summary), value = TRUE)
pred_area$N_var <- ifelse(
  pred_area$Status == "Completa", 0, stan_summary[y_tot_rows, "sd"]^2
)

# Peso de cada unidad: suma de las varianzas de sus segmentos
pesos_unidad <- pred_area %>%
  group_by(unidad_value) %>%
  summarise(w = sum(N_var), .groups = "drop")

benchmarking_ponderado <- function(N_hat, N_control, pesos) {
  delta <- N_control - sum(N_hat)
  N_hat + pesos * (delta / sum(pesos))
}

unidades <- unidades %>%
  left_join(pesos_unidad, by = "unidad_value") %>%
  mutate(
    N_bench_pond = benchmarking_ponderado(N_hat, N_star, w),
    eta_pond     = (N_bench_pond - N_hat) / N_hat
  )
```

:::

La Tabla \@ref(tab:ejemplo-benchmarking-ponderado) muestra el resultado:

<table class="table" style="width: auto !important; margin-left: auto; margin-right: auto;">
<caption>(\#tab:ejemplo-benchmarking-ponderado)Benchmarking ponderado por incertidumbre sobre el total agregado $N^{*}=297.604$, comparado con el cambio directo de la Tabla anterior.</caption>
 <thead>
  <tr>
   <th style="text-align:center;"> Unidad </th>
   <th style="text-align:center;"> $\hat{N}_\ell$ (antes) </th>
   <th style="text-align:center;"> $\hat{N}_\ell^{bench}$ (ponder.) </th>
   <th style="text-align:center;"> $\eta_\ell$ (ponder.) </th>
   <th style="text-align:center;"> $\eta_\ell$ (directo) </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:center;"> Unidad 6 </td>
   <td style="text-align:center;"> 16291 </td>
   <td style="text-align:center;"> 17417 </td>
   <td style="text-align:center;"> 0.069 </td>
   <td style="text-align:center;"> 0.069 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> Unidad 8 </td>
   <td style="text-align:center;"> 11405 </td>
   <td style="text-align:center;"> 12188 </td>
   <td style="text-align:center;"> 0.069 </td>
   <td style="text-align:center;"> 0.069 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> Unidad 5 </td>
   <td style="text-align:center;"> 23949 </td>
   <td style="text-align:center;"> 25554 </td>
   <td style="text-align:center;"> 0.067 </td>
   <td style="text-align:center;"> 0.067 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> Unidad 11 </td>
   <td style="text-align:center;"> 5367 </td>
   <td style="text-align:center;"> 5719 </td>
   <td style="text-align:center;"> 0.066 </td>
   <td style="text-align:center;"> 0.066 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> Unidad 10 </td>
   <td style="text-align:center;"> 9771 </td>
   <td style="text-align:center;"> 10352 </td>
   <td style="text-align:center;"> 0.060 </td>
   <td style="text-align:center;"> 0.059 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> Unidad 7 </td>
   <td style="text-align:center;"> 12974 </td>
   <td style="text-align:center;"> 13732 </td>
   <td style="text-align:center;"> 0.058 </td>
   <td style="text-align:center;"> 0.058 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> Unidad 4 </td>
   <td style="text-align:center;"> 28186 </td>
   <td style="text-align:center;"> 29764 </td>
   <td style="text-align:center;"> 0.056 </td>
   <td style="text-align:center;"> 0.056 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> Unidad 3 </td>
   <td style="text-align:center;"> 29930 </td>
   <td style="text-align:center;"> 31589 </td>
   <td style="text-align:center;"> 0.055 </td>
   <td style="text-align:center;"> 0.055 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> Unidad 9 </td>
   <td style="text-align:center;"> 10683 </td>
   <td style="text-align:center;"> 11217 </td>
   <td style="text-align:center;"> 0.050 </td>
   <td style="text-align:center;"> 0.050 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> Unidad 2 </td>
   <td style="text-align:center;"> 56633 </td>
   <td style="text-align:center;"> 59436 </td>
   <td style="text-align:center;"> 0.050 </td>
   <td style="text-align:center;"> 0.049 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> Unidad 1 </td>
   <td style="text-align:center;"> 76966 </td>
   <td style="text-align:center;"> 80635 </td>
   <td style="text-align:center;"> 0.048 </td>
   <td style="text-align:center;"> 0.048 </td>
  </tr>
</tbody>
</table>

La comparación muestra que los cambios relativos obtenidos mediante el benchmarking ponderado son muy cercanos a los cambios observados en el ajuste directo. La diferencia máxima entre ambos es de apenas $0,0001$ en términos relativos. Por ejemplo, la Unidad 6 recibe un incremento de $6,9%$ bajo ambos procedimientos, mientras que la Unidad 1 recibe aproximadamente $4,8%$.

Este resultado muestra que, para este conjunto de unidades, la incertidumbre posterior proporciona una distribución del ajuste muy similar a la obtenida cuando se dispone de información específica para cada unidad. Esto constituye evidencia favorable para el uso de la varianza posterior como mecanismo de ponderación en este ejercicio, aunque no implica que dicha correspondencia deba mantenerse en otros conjuntos de unidades o aplicaciones. Su desempeño debe evaluarse en cada aplicación cuando existan referencias externas que permitan realizar la comparación.

**Benchmarking aditivo por muestra.** El benchmarking aditivo por muestra extiende el ajuste ponderado a la distribución posterior completa. Para cada muestra posterior $t=1,\ldots,T$, la estimación de cada unidad se ajusta mediante:

$$
\tilde{N}_\ell^{bench,(t)} = \tilde{N}_\ell^{(t)} +
\frac{w_\ell}{\sum_{\ell'=1}^{K}w_{\ell'}}
\Delta^{(t)},
$$

donde $\Delta^{(t)}$ representa la discrepancia entre el total de control y el total estimado en la muestra $t$. De esta forma, el benchmarking se aplica a cada realización posterior y no únicamente a la estimación puntual, permitiendo obtener directamente la distribución posterior ajustada y sus intervalos de credibilidad.

El intervalo de credibilidad del 95% para cada unidad se obtiene a partir de los cuantiles 2,5% y 97,5% de las muestras posteriores ajustadas:

$$
IC_\ell^{bench} = \left[
Q_{0.025}\left(\tilde{N}_\ell^{bench}\right),
Q_{0.975}\left(\tilde{N}_\ell^{bench}\right)
\right].
$$

Para evaluar el efecto del benchmarking sobre la incertidumbre, puede compararse la longitud del intervalo ajustado con la del intervalo original mediante:


$$
\text{L}_\ell = \frac{\text{IC}^{bench}_{97,5\%,\ell} - \text{IC}^{bench}_{2,5\%,\ell}}{\text{IC}_{97,5\%,\ell} - \text{IC}_{2,5\%,\ell}}.
$$

Valores de $L_\ell$ cercanos a uno indican que el benchmarking modifica principalmente la localización de la distribución posterior, mientras que valores diferentes de uno indican que también modifica la incertidumbre asociada a la estimación.


**Benchmarking aditivo por muestra.** El ajuste aditivo ponderado por muestra, definido en la ecuación de la Sección "Benchmarking aditivo con restricciones de suma", se aplica aquí a las $K=11$ unidades del ejemplo: cada réplica $\tilde{N}_\ell^{(t)}$, $t=1,\ldots,T$, se calibra según $\tilde{N}_\ell^{bench,(t)} = \tilde{N}_\ell^{(t)} + w_\ell \cdot \Delta^{(t)} / \sum_{\ell'} w_{\ell'}$, de modo que además de la media calibrada se obtiene un intervalo de credibilidad calibrado. Como `06_posterior_draws_core.rds` no conserva las muestras posteriores de `Y_tot` por unidad territorial, cada $\tilde{N}_\ell^{(t)}$ se genera a partir de una distribución normal truncada en cero, con la misma media $\hat{N}_\ell$ y varianza $w_\ell$ ya calculadas —una aproximación distribucional que no reemplaza las muestras MCMC genuinas, pero permite ilustrar el procedimiento—.

El intervalo de credibilidad calibrado de cada unidad se obtiene directamente de los cuantiles 2,5% y 97,5% de $\tilde{N}_\ell^{bench,(t)}$ a lo largo de las $T$ réplicas. Su longitud relativa respecto al intervalo original —un indicador simple de cuánto modifica la calibración la incertidumbre reportada— se define como

$$
\text{Longitud relativa}_\ell = \frac{\text{IC}^{bench}_{97,5\%,\ell} - \text{IC}^{bench}_{2,5\%,\ell}}{\text{IC}_{97,5\%,\ell} - \text{IC}_{2,5\%,\ell}}.
$$

La Tabla \@ref(tab:ejemplo-benchmarking-aditivo) muestra el resultado:

<table class="table" style="width: auto !important; margin-left: auto; margin-right: auto;">
<caption>(\#tab:ejemplo-benchmarking-aditivo)Benchmarking aditivo por muestra sobre el total agregado $N^{*}=297.604$: media e intervalo de credibilidad calibrados, y longitud relativa respecto al intervalo original.</caption>
 <thead>
  <tr>
   <th style="text-align:center;"> Unidad </th>
   <th style="text-align:center;"> $\hat{N}_\ell$ (antes) </th>
   <th style="text-align:center;"> $\hat{N}_\ell^{bench}$ (media) </th>
   <th style="text-align:center;"> IC 2,5\% </th>
   <th style="text-align:center;"> IC 97,5\% </th>
   <th style="text-align:center;"> Longitud relativa </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:center;"> Unidad 6 </td>
   <td style="text-align:center;"> 16291 </td>
   <td style="text-align:center;"> 17419 </td>
   <td style="text-align:center;"> 16222 </td>
   <td style="text-align:center;"> 18609 </td>
   <td style="text-align:center;"> 0.996 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> Unidad 5 </td>
   <td style="text-align:center;"> 23949 </td>
   <td style="text-align:center;"> 25560 </td>
   <td style="text-align:center;"> 24212 </td>
   <td style="text-align:center;"> 27026 </td>
   <td style="text-align:center;"> 0.968 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> Unidad 8 </td>
   <td style="text-align:center;"> 11405 </td>
   <td style="text-align:center;"> 12166 </td>
   <td style="text-align:center;"> 11190 </td>
   <td style="text-align:center;"> 13142 </td>
   <td style="text-align:center;"> 0.964 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> Unidad 11 </td>
   <td style="text-align:center;"> 5367 </td>
   <td style="text-align:center;"> 5714 </td>
   <td style="text-align:center;"> 5063 </td>
   <td style="text-align:center;"> 6360 </td>
   <td style="text-align:center;"> 0.957 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> Unidad 7 </td>
   <td style="text-align:center;"> 12974 </td>
   <td style="text-align:center;"> 13724 </td>
   <td style="text-align:center;"> 12750 </td>
   <td style="text-align:center;"> 14696 </td>
   <td style="text-align:center;"> 0.967 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> Unidad 10 </td>
   <td style="text-align:center;"> 9771 </td>
   <td style="text-align:center;"> 10335 </td>
   <td style="text-align:center;"> 9462 </td>
   <td style="text-align:center;"> 11226 </td>
   <td style="text-align:center;"> 0.975 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> Unidad 4 </td>
   <td style="text-align:center;"> 28186 </td>
   <td style="text-align:center;"> 29797 </td>
   <td style="text-align:center;"> 28431 </td>
   <td style="text-align:center;"> 31181 </td>
   <td style="text-align:center;"> 0.966 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> Unidad 3 </td>
   <td style="text-align:center;"> 29930 </td>
   <td style="text-align:center;"> 31621 </td>
   <td style="text-align:center;"> 30307 </td>
   <td style="text-align:center;"> 33009 </td>
   <td style="text-align:center;"> 0.964 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> Unidad 9 </td>
   <td style="text-align:center;"> 10683 </td>
   <td style="text-align:center;"> 11233 </td>
   <td style="text-align:center;"> 10419 </td>
   <td style="text-align:center;"> 12054 </td>
   <td style="text-align:center;"> 0.968 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> Unidad 2 </td>
   <td style="text-align:center;"> 56633 </td>
   <td style="text-align:center;"> 59476 </td>
   <td style="text-align:center;"> 57809 </td>
   <td style="text-align:center;"> 61132 </td>
   <td style="text-align:center;"> 0.918 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> Unidad 1 </td>
   <td style="text-align:center;"> 76966 </td>
   <td style="text-align:center;"> 80559 </td>
   <td style="text-align:center;"> 78628 </td>
   <td style="text-align:center;"> 82424 </td>
   <td style="text-align:center;"> 0.827 </td>
  </tr>
</tbody>
</table>

Las medias calibradas de la Tabla \@ref(tab:ejemplo-benchmarking-aditivo) coinciden, salvo diferencias de simulación, con el ajuste ponderado de la Tabla \@ref(tab:ejemplo-benchmarking-ponderado); la diferencia es que ahora cada unidad conserva además un intervalo de credibilidad propio, calibrado muestra por muestra y no solo en su media. La longitud relativa se ubica entre $0,83$ (Unidad 1) y $1,00$ (Unidad 6), siempre por debajo o prácticamente igual a uno: la calibración estrecha los intervalos originales en las 11 unidades, de forma más marcada en la Unidad 1 que en la Unidad 6, consistente con tratar $N^{*}$ como una constante sin incertidumbre propia —al no aportar varianza adicional, la calibración solo puede mantener o reducir la dispersión total, nunca aumentarla—.

**Cascada al nivel de segmento censal.** Las tres tablas anteriores calibran el total de cada unidad territorial, pero el modelo se especifica y se estima al nivel de segmento censal (Capítulos \@ref(cap-modelos-poblacion), \@ref(cap-insumos) y \@ref(cap-inferencia)): publicar solo el total corregido por unidad deja sin resolver cómo se distribuye esa corrección entre los segmentos que la componen, ni qué ocurre con la incertidumbre de cada uno. El Código \@ref(exr:cod-benchmarking-segmento) desciende la calibración directa desde la unidad hasta el segmento —tanto la estimación puntual como su intervalo de credibilidad—: el factor implícito en cada unidad, $\phi_\ell=N_\ell^{*}/\hat{N}_\ell$, se aplica a todos sus segmentos por igual, preservando el peso relativo de cada segmento dentro de su unidad.

::: {.exercise #cod-benchmarking-segmento name="Cascada de la calibración desde la unidad hasta el segmento censal"}

```r
# Factor de calibración de cada unidad, según la referencia externa directa
phi_unidad <- comparacion %>%
  transmute(`Unidad territorial`, phi = N_ext / N_hat)

# Se aplica a cada uno de los 609 segmentos, según la unidad a la que
# pertenece -- a la estimación puntual y, por ser una transformación
# lineal positiva, también a los límites de su intervalo de credibilidad
# (el intervalo real del ajuste, ic_li_segm/ic_ls_segm, no una
# aproximación; puntual para los segmentos con cobertura censal completa)
segmentos_bench <- pred_area %>%
  left_join(mapa_unidad, by = "unidad_value") %>%
  left_join(phi_unidad, by = "Unidad territorial") %>%
  mutate(
    pob_bench_segm    = pob_final_media * phi,
    ic_li_bench_segm  = ic_li_segm * phi,
    ic_ls_bench_segm  = ic_ls_segm * phi
  )
```

:::

La Tabla \@ref(tab:ejemplo-benchmarking-segmento) verifica, para cada una de las 11 unidades, que la suma de sus segmentos calibrados reproduce exactamente su referencia externa —sin listar los 609 segmentos de forma individual—:

<table class="table" style="width: auto !important; margin-left: auto; margin-right: auto;">
<caption>(\#tab:ejemplo-benchmarking-segmento)Verificación de la cascada al nivel de segmento censal: la suma de los segmentos calibrados de cada unidad reproduce exactamente su referencia externa (609 segmentos en total).</caption>
 <thead>
  <tr>
   <th style="text-align:center;"> Unidad </th>
   <th style="text-align:center;"> N.º de segmentos </th>
   <th style="text-align:center;"> Suma segmentos calibrados </th>
   <th style="text-align:center;"> $N_\ell^{*}$ (referencia) </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:center;"> Unidad 6 </td>
   <td style="text-align:center;"> 30 </td>
   <td style="text-align:center;"> 17418 </td>
   <td style="text-align:center;"> 17418 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> Unidad 8 </td>
   <td style="text-align:center;"> 21 </td>
   <td style="text-align:center;"> 12187 </td>
   <td style="text-align:center;"> 12187 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> Unidad 5 </td>
   <td style="text-align:center;"> 44 </td>
   <td style="text-align:center;"> 25554 </td>
   <td style="text-align:center;"> 25554 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> Unidad 11 </td>
   <td style="text-align:center;"> 11 </td>
   <td style="text-align:center;"> 5719 </td>
   <td style="text-align:center;"> 5719 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> Unidad 10 </td>
   <td style="text-align:center;"> 21 </td>
   <td style="text-align:center;"> 10352 </td>
   <td style="text-align:center;"> 10352 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> Unidad 7 </td>
   <td style="text-align:center;"> 29 </td>
   <td style="text-align:center;"> 13732 </td>
   <td style="text-align:center;"> 13732 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> Unidad 4 </td>
   <td style="text-align:center;"> 64 </td>
   <td style="text-align:center;"> 29764 </td>
   <td style="text-align:center;"> 29764 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> Unidad 3 </td>
   <td style="text-align:center;"> 65 </td>
   <td style="text-align:center;"> 31589 </td>
   <td style="text-align:center;"> 31589 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> Unidad 9 </td>
   <td style="text-align:center;"> 24 </td>
   <td style="text-align:center;"> 11217 </td>
   <td style="text-align:center;"> 11217 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> Unidad 2 </td>
   <td style="text-align:center;"> 126 </td>
   <td style="text-align:center;"> 59436 </td>
   <td style="text-align:center;"> 59436 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> Unidad 1 </td>
   <td style="text-align:center;"> 174 </td>
   <td style="text-align:center;"> 80636 </td>
   <td style="text-align:center;"> 80636 </td>
  </tr>
</tbody>
</table>

La suma de los 609 segmentos calibrados —$297.604$— coincide exactamente con $N^{*}$, y la de cada unidad con su propia referencia: la cascada preserva la coherencia jerárquica interna (Sección "Restricciones de consistencia jerárquica") en cada nivel, no solo en el agregado nacional.

A nivel individual, la Tabla \@ref(tab:ejemplo-benchmarking-segmento-ic) muestra seis segmentos de ejemplo dentro de la Unidad 1 ($\phi=1,05$), con su intervalo de credibilidad real —no aproximado— antes y después de calibrar:

<table class="table" style="width: auto !important; margin-left: auto; margin-right: auto;">
<caption>(\#tab:ejemplo-benchmarking-segmento-ic)Estimación puntual e intervalo de credibilidad de seis segmentos de ejemplo dentro de la Unidad 1, antes y después de la cascada de calibración.</caption>
 <thead>
  <tr>
   <th style="text-align:center;"> Segmento </th>
   <th style="text-align:center;"> $\hat{N}_i$ (antes) </th>
   <th style="text-align:center;"> IC (antes) </th>
   <th style="text-align:center;"> $\hat{N}_i^{bench}$ (después) </th>
   <th style="text-align:center;"> IC (después) </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:center;"> 6 </td>
   <td style="text-align:center;"> 1283 </td>
   <td style="text-align:center;"> [851, 1861] </td>
   <td style="text-align:center;"> 1344 </td>
   <td style="text-align:center;"> [892, 1950] </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 71 </td>
   <td style="text-align:center;"> 829 </td>
   <td style="text-align:center;"> [558, 1192] </td>
   <td style="text-align:center;"> 868 </td>
   <td style="text-align:center;"> [585, 1249] </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 126 </td>
   <td style="text-align:center;"> 818 </td>
   <td style="text-align:center;"> [552, 1165] </td>
   <td style="text-align:center;"> 857 </td>
   <td style="text-align:center;"> [578, 1221] </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 164 </td>
   <td style="text-align:center;"> 183 </td>
   <td style="text-align:center;"> [183, 183] </td>
   <td style="text-align:center;"> 192 </td>
   <td style="text-align:center;"> [192, 192] </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 16 </td>
   <td style="text-align:center;"> 140 </td>
   <td style="text-align:center;"> [89, 204] </td>
   <td style="text-align:center;"> 147 </td>
   <td style="text-align:center;"> [93, 214] </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 32 </td>
   <td style="text-align:center;"> 119 </td>
   <td style="text-align:center;"> [119, 119] </td>
   <td style="text-align:center;"> 125 </td>
   <td style="text-align:center;"> [125, 125] </td>
  </tr>
</tbody>
</table>

El mismo factor $\phi=1,05$ se aplica tanto a la estimación puntual como a los dos límites del intervalo —al ser una transformación lineal positiva, el intervalo se escala exactamente igual, sin necesidad de volver a calcular cuantiles—, de modo que un segmento con $\hat{N}=1.283$ e IC $[851,1861]$ pasa a $1.344$ con IC $[892,1950]$. Los dos últimos segmentos de la tabla tienen cobertura censal completa: su conteo es exacto —intervalo de ancho cero antes de calibrar, $119$ en ambos límites— y, aunque el factor de la unidad los desplaza a $125$, la calibración no introduce ninguna incertidumbre donde el operativo censal ya la había eliminado.

En síntesis, este ejemplo recorre los cuatro métodos del capítulo sobre el mismo conjunto de 11 unidades, y desciende el resultado hasta el segmento censal. Cuando existe información externa al nivel de la propia unidad territorial, la comparación directa es la más simple y no requiere ningún supuesto adicional. Cuando esa información no está disponible —el caso más frecuente en la práctica— y solo se conoce un total agregado, el benchmarking proporcional ofrece una solución simple pero uniforme, mientras que el ponderado por incertidumbre usa la precisión posterior del modelo para aproximarse al resultado que la referencia directa habría dado, como confirma la coincidencia casi exacta entre ambos en este ejercicio. El benchmarking aditivo por muestra extiende cualquiera de estos principios a la distribución posterior completa, de modo que la incertidumbre reportada tras la calibración —y no solo el valor puntual— sea consistente con la información externa incorporada. Y puesto que el modelo se estima y se publica finalmente a nivel de segmento censal, cualquiera de estos ajustes debe descender hasta ese nivel antes de considerarse completo, como ilustra el Código \@ref(exr:cod-benchmarking-segmento).

