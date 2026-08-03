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
8. `07-Inferencia_Bayesiana.Rmd`
9. `08-Diagnostico_Validacion.Rmd` — Diagnóstico y Validación del Modelo
10. `09-Calibracion_Benchmarking.Rmd` — Calibración y Benchmarking Subnacional
11. `10-Conclusiones.Rmd` — Conclusiones y Recomendaciones Institucionales
12. `11-references.Rmd` — References

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

**Current priority (next stage):** Chapters 5 and 6 currently use fabricated data (`set.seed()`, `rnorm()`, `rpois()`) so their chunks are runnable without real inputs. The active goal is migrating these examples to **real, publicly available data** (open aggregate/microdata portals from DANE, INE, DGEEC, or similar official sources) so the analyses and their narrative reflect genuine results — not simulated placeholders. This does not relax the no-real-microdata-committed rule; use public aggregates or properly licensed open data. Chapter 7's Stan examples are currently illustrative (not executed) because `rstan`/`bayesplot`/`loo` are not installed in this environment — fitting the model on real data will also require installing those (plus Rtools) and re-running the chunks for genuine posterior output (summaries, $\hat R$/ESS, PPC plot, LOO/WAIC).

## Established Conventions (do not revert without discussion)

These were deliberate decisions made while drafting Chapters 5–7; see `README.md`'s "Registro de Cambios" for full context.

- **Prior terminology:** always "distribución previa" / "distribuciones previas" in Spanish prose — never "a priori".
- **No Negative Binomial:** the book never uses or mentions the negative binomial model anywhere; the author does not use it. Don't reintroduce it as a contrast/alternative.
- **θ and prior scale notation (Ch. 6):** $\boldsymbol{\theta} = (\boldsymbol{\beta}, \boldsymbol{\gamma}, \sigma, \sigma_U)$. Priors are written with generic large-variance ("non-informative") hyperparameters $\tau_\beta^2$, $\tau_U^2$, $\tau_\sigma$ rather than hardcoded numbers, with a note that the Stan implementation (Ch. 7) fixes $\tau_\beta^2=1$, $\tau_U^2=1$, $\tau_\sigma=2.5$. $\sigma$ keeps a half-Cauchy prior (not half-normal) — heavier tails, standard choice for a scale parameter.
- **Segment-count vs. density notation (Ch. 2, 5, 6):** $D = |\mathcal{S}|$ is the *cardinality* of the segment set (matches Stan's `D_obs`/`D_tot`). Population density by area is $\text{DP}_i$ (never bare $D_i$, which collides with the cardinality). Density by housing structure is $\delta_i$. All three are explicitly disambiguated wherever they could be confused.
- **Numbered "Código X.Y" code boxes:** wrap a chunk with `::: {.exercise #cod-<id> name="Título"}` ... `:::` and cross-reference via `` \@ref(exr:cod-<id>) `` (the `exr` theorem-kind is relabeled to "Código " in `_bookdown.yml`). **Never** wrap a chunk that has its own `fig.cap` this way — LaTeX cannot nest a float inside a tcolorbox and the PDF build will fail. Such chunks stay unwrapped and get their own numbered Figura instead.
- **Multi-format tables:** always set `format` explicitly in `knitr::kable()` (`"latex"` / `"html"` / `"pipe"` based on `knitr::is_latex_output()` / `is_html_output()`) — omitting it causes duplicate table numbering when piped into `kableExtra::kable_styling()`. Skip `kable_styling()` entirely when format is `"pipe"` (Word) — it emits raw HTML that breaks the `.docx` render.
- **Multi-line equations:** never leave a blank line inside a `$$...$$` block (including inside `\begin{aligned}...\end{aligned}`) — it breaks PDF compilation with "allowed only in math mode" because pandoc stops treating the block as math at the blank line.
- **GitHub Pages:** `docs/.nojekyll` must always exist (committed) so GitHub Pages serves the bookdown output directly instead of failing during Jekyll processing.
