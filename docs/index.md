---
title: "Modelos Bayesianos de Población para América Latina y el Caribe"
subtitle: "Implementación, Validación y Aplicación Subnacional"
author: |
  Andrés Gutiérrez^[Experto Regional en Estadísticas Sociales, CEPAL. andres.gutierrez@cepal.org]
  Stalyn Guerrero^[Consultor, CEPAL. guerrerostalyn@gmail.com]
date: "julio de 2026"
lang: es
documentclass: book
bibliography: [book.bib, packages.bib]
biblio-style: apalike
link-citations: yes
colorlinks: yes
lot: yes
lof: yes
site: bookdown::bookdown_site
github-repo: psirusteam/MBP-ALC
description: >
  Libro técnico sobre modelos bayesianos jerárquicos para la estimación subnacional
  de población en América Latina y el Caribe, con énfasis en integración de múltiples
  fuentes de información y aplicación en institutos nacionales de estadística.
---

# Prefacio {-}

La producción de estadísticas oficiales sobre población constituye uno de los pilares fundamentales para la formulación, implementación y evaluación de políticas públicas. En América Latina y el Caribe, los censos de población continúan siendo la principal fuente de información demográfica; sin embargo, la creciente complejidad de los operativos censales, las limitaciones presupuestarias y los problemas de cobertura observados en distintos países han puesto de manifiesto la necesidad de desarrollar metodologías que permitan mejorar la calidad de los conteos censales, particularmente en unidades geográficas pequeñas donde las omisiones y otros errores de cobertura pueden tener un impacto considerable.

Este libro surge de la experiencia acumulada durante diversos proyectos de asistencia técnica desarrollados con oficinas nacionales de estadística de América Latina y el Caribe, en el marco de las actividades de cooperación estadística de la Comisión Económica para América Latina y el Caribe (CEPAL). En estos proyectos fue evidente que la mejora de los conteos censales requiere integrar información proveniente de diferentes fuentes, como preconteos operativos, registros administrativos, imágenes satelitales y variables geoespaciales. Estas fuentes presentan distintos niveles de cobertura, calidad y resolución espacial, por lo que su utilización exige modelos estadísticos capaces de representar explícitamente la incertidumbre asociada a cada una de ellas y de producir estimaciones consistentes de la población.


El objetivo de este libro trasciende la presentación de modelos bayesianos para la estimación de población. Su propósito es desarrollar una metodología integral para la producción de estimaciones subnacionales que articule de manera coherente las diferentes etapas del proceso estadístico. El lector encontrará un recorrido completo que abarca la preparación y evaluación de las fuentes de información, la construcción de variables auxiliares derivadas de información geoespacial y registros administrativos, la formulación de modelos bayesianos jerárquicos, la estimación mediante técnicas modernas de inferencia y la evaluación de la calidad de las estimaciones obtenidas mediante procedimientos de validación y diagnóstico.

Un principio transversal de la obra es la reproducibilidad. Todos los métodos se implementan utilizando herramientas de código abierto, principalmente R y Stan, y cada capítulo incluye desarrollos computacionales que permiten reproducir íntegramente los análisis presentados. Más que ilustrar algoritmos aislados, el libro propone flujos de trabajo completos que pueden adaptarse a las necesidades de las oficinas nacionales de estadística y de otras instituciones responsables de la producción de información demográfica. Aunque los ejemplos se basan en aplicaciones inspiradas en experiencias de América Latina y el Caribe, las metodologías desarrolladas son de carácter general y pueden extenderse a otros contextos geográficos.

El libro está dirigido a estadísticos, demógrafos, científicos de datos e investigadores involucrados en la producción y análisis de estadísticas oficiales, así como a profesionales de organismos nacionales e internacionales interesados en métodos bayesianos aplicados a la estimación de población. Asimismo, puede servir como texto de referencia para estudiantes de posgrado en estadística, demografía o disciplinas afines que deseen profundizar en la construcción e implementación de modelos jerárquicos para datos de conteo. Se asume que el lector posee formación en probabilidad, inferencia estadística, modelos lineales y fundamentos de inferencia bayesiana.

Finalmente, este libro parte de una premisa fundamental: ningún modelo estadístico reemplaza el conocimiento sustantivo sobre los procesos demográficos ni la experiencia acumulada por los especialistas encargados de la producción estadística. Los modelos constituyen, más bien, un instrumento para integrar información proveniente de múltiples fuentes, representar explícitamente las diferentes fuentes de incertidumbre y producir estimaciones consistentes bajo supuestos claramente establecidos. En este sentido, la inferencia bayesiana proporciona un marco flexible para combinar evidencia, incorporar conocimiento previo cuando resulte pertinente y cuantificar rigurosamente la incertidumbre asociada a las estimaciones. El objetivo último es contribuir al fortalecimiento de la producción de estadísticas oficiales mediante metodologías transparentes, reproducibles y científicamente fundamentadas.






