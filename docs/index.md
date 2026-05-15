--- 
title: "Modelos Bayesianos de Población para América Latina y el Caribe Implementación, Validación y Aplicación Subnacional"
author: "Andrés Gutiérrez^[Experto Regional en Estadísticas Sociales - Comisión Económica para América Latina y el Caribe (CEPAL) -  andres.gutierrez@cepal.org],Stalyn Guerrero^[Consultor - Comisión Económica para América Latina y el Caribe (CEPAL), guerrerostalyn@gmail.com]"
date: "2026-05-15"
lang: es
documentclass: book
# bibliography: [CEPAL.bib]
biblio-style: apalike
link-citations: yes
colorlinks: yes
lot: yes
lof: yes
fontsize: 12pt
geometry: margin = 3cm
header-includes:
  - \usepackage{amsmath}
  - \usepackage[ruled,vlined,linesnumbered]{algorithm2e}
  - \usepackage{hyperref}
github-repo: psirusteam/2021ASDA
description: "Este es el repositorio del libro *Análisis de encuestas con R*."
knit: "bookdown::render_book"
linkcolor: blue
output:
  pdf_document:
    toc: true
    toc_depth: 3
    keep_tex: true
    latex_engine: xelatex
  gitbook:
    df_print: kable
    css: "style.css"
# Compilar así:
# bookdown::render_book("index.Rmd", "bookdown::pdf_book")
# bookdown::render_book("index.Rmd", "bookdown::epub_book")
# bookdown::render_book("index.Rmd", "bookdown::word_document2")
# bookdown::preview_chapter("01.Rmd", "bookdown::word_document2")
---
# Prefacio {-}


La versión online de este libro está licenciada bajo una [Licencia Internacional de Creative Commons para compartir con atribución no comercial 4.0](http://creativecommons.org/licenses/by-nc-sa/4.0/). 

Este libro es el resultado de un compendio de las experiencias internacionales prácticas adquiridas por el autor como Experto Regional en Estadísticas Sociales de la CEPAL.


