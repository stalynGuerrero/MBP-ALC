# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **bookdown** project producing a technical book in Spanish: *Modelos Bayesianos de Población para América Latina y el Caribe* (MBP-ALC). The book targets statisticians and demographers at national statistical institutes, covering Bayesian hierarchical models for subnational population estimation using multi-source data integration (census pre-counts, administrative records, satellite imagery).

Authors: Andrés Gutiérrez (CEPAL) and Stalyn Guerrero (CEPAL consultant).

## Build Commands

```r
# Interactive HTML (gitbook)
bookdown::render_book("index.Rmd", "bookdown::gitbook")

# PDF (requires XeLaTeX)
bookdown::render_book("index.Rmd", "bookdown::pdf_book")

# Word (.docx)
bookdown::render_book("index.Rmd", "bookdown::word_document2")

# Generate Word style template (run once, then uncomment reference_docx in _output.yml)
source("crear_plantilla_word.R")
```

Output lands in `docs/`. The book filename is `MBP-ALC`.

## Chapter File Order

Defined in `_bookdown.yml`. Current order:
1. `index.Rmd` — Prefacio
2. `01-intro.Rmd` — Introducción
3. `02-Modelos_poblacion.Rmd` — Modelos de Población
4. `03-Integracion_Fuentes.Rmd` — Integración de Fuentes
5. `04-Imagenes_Satelitales.Rmd` — Imágenes Satelitales
6. `05-InsumosModelamiento.Rmd` — Insumos para Modelamiento
7. `06-Modelo_Conteos.Rmd` — Modelo para Conteos Poblacionales
8. `07-Inferencia_Bayesiana.Rmd` — (in progress, not yet in `_bookdown.yml`)
9. `07-references.Rmd` — References

New chapters must be added to `rmd_files:` in `_bookdown.yml` to be included in the build.

## Authoring Conventions

- **Language:** All prose is in Spanish; code comments are in Spanish.
- **Code blocks:** R is preferred; Stan and Python are also used. All blocks must be functional and reproducible.
- **Equations:** Use LaTeX math, numbered and cross-referenceable via `\@ref(eq:label)`.
- **Figure/table labels:** Use `fig:`, `tab:` prefixes; Spanish captions (`Figura`, `Tabla` — configured in `_bookdown.yml`).
- **Chapter structure:** Introduction → theoretical development with equations → reproducible code → summary.
- **Key R packages:** `tidyverse`, `ggplot2`, `rstan`/`cmdstanr`, `bayesplot`, `loo`, `tidybayes`.

## Key Architecture Points

- `index.Rmd` sets global knitr options (`echo=TRUE`, `cache=FALSE`, no messages/warnings) and writes `packages.bib` via `knitr::write_bib`.
- `book.bib` contains hand-curated references; `packages.bib` is auto-generated at render time — do not edit `packages.bib` manually.
- `preamble.tex` provides LaTeX customizations for PDF output (XeLaTeX + natbib).
- `style.css` styles the gitbook HTML output.
- `_output.yml` configures all three output formats. The Word template (`word_template.docx`) is optional — generate it with `crear_plantilla_word.R` then uncomment `reference_docx` in `_output.yml`.
- `docs/` is the rendered output directory committed to the repo (GitHub Pages source).

## Country/Data Context

Examples use census data from Colombia (DANE), Bolivia (INE), and Paraguay (DGEEC). Synthetic or publicly available data should be used in code examples; no real microdata should be committed.
