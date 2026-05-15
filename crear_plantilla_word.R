# ================================================================
# Genera word_template.docx para el libro MBP-ALC
# Requiere: install.packages(c("officer", "flextable"))
#
# Uso:
#   source("crear_plantilla_word.R")
#   Luego descomentar reference_docx en _output.yml
# ================================================================

library(officer)

# --- Colores CEPAL -----------------------------------------------
navy  <- "#1B2A4A"
blue  <- "#2563EB"
gray  <- "#4A5568"
white <- "#FFFFFF"
ltbg  <- "#F8FAFC"

# --- Crear documento base ----------------------------------------
doc <- read_docx()

# Fuente base del documento
doc <- officer::body_set_default_section(
  doc,
  officer::prop_section(
    page_size   = page_size(orient = "portrait", width = 21 / 2.54, height = 29.7 / 2.54),
    page_margins = page_mar(top = 2.5, bottom = 3, left = 3, right = 2.2, gutter = 0),
    type        = "continuous"
  )
)

# --- Función auxiliar para agregar estilos -----------------------
add_para_style <- function(doc, style_name, ...) {
  tryCatch(
    officer::styles_info(doc),
    error = function(e) NULL
  )
  doc
}

# --- Construir estilos de párrafo --------------------------------

# Normal / cuerpo
doc <- officer::body_add_par(doc, "Texto de cuerpo de muestra.", style = "Normal")

# Título del documento
title_fp <- fp_text(
  font.size    = 28,
  bold         = TRUE,
  font.family  = "Calibri",
  color        = navy
)

# Encabezado 1
h1_fp <- fp_text(
  font.size    = 18,
  bold         = TRUE,
  font.family  = "Calibri",
  color        = navy
)

# Encabezado 2
h2_fp <- fp_text(
  font.size    = 14,
  bold         = TRUE,
  font.family  = "Calibri",
  color        = navy
)

# Encabezado 3
h3_fp <- fp_text(
  font.size    = 12,
  bold         = TRUE,
  font.family  = "Calibri",
  color        = gray
)

# Cuerpo
body_fp <- fp_text(
  font.size    = 11,
  font.family  = "Palatino Linotype",
  color        = "#1A202C"
)

# Código
code_fp <- fp_text(
  font.size    = 9,
  font.family  = "Courier New",
  color        = "#991B1B",
  shading.color = ltbg
)

# --- Párrafo de título -------------------------------------------
doc <- officer::body_add_fpar(
  doc,
  fpar(
    ftext("Modelos Bayesianos de Población para ALC", title_fp),
    fp_p = fp_par(
      text.align = "left",
      padding.bottom = 6,
      border.bottom  = fp_border(color = blue, width = 2)
    )
  )
)

doc <- officer::body_add_par(doc, "")

# --- Párrafo de subtítulo ----------------------------------------
subtitle_fp <- fp_text(
  font.size   = 14,
  font.family = "Calibri",
  color       = gray,
  italic      = TRUE
)

doc <- officer::body_add_fpar(
  doc,
  fpar(ftext("Implementación, Validación y Aplicación Subnacional", subtitle_fp))
)

doc <- officer::body_add_par(doc, "")

# --- Autor -------------------------------------------------------
author_fp <- fp_text(font.size = 11, font.family = "Calibri", color = gray)
doc <- officer::body_add_fpar(
  doc,
  fpar(ftext("Andrés Gutiérrez · Stalyn Guerrero", author_fp))
)

doc <- officer::body_add_par(doc, "")
doc <- officer::body_add_par(doc, "")

# --- Encabezado 1 de muestra -------------------------------------
doc <- officer::body_add_fpar(
  doc,
  fpar(
    ftext("1  Capítulo de Ejemplo", h1_fp),
    fp_p = fp_par(
      padding.top    = 14,
      padding.bottom = 4,
      border.bottom  = fp_border(color = blue, width = 1.5)
    )
  )
)

# --- Encabezado 2 ------------------------------------------------
doc <- officer::body_add_fpar(
  doc,
  fpar(
    ftext("1.1  Sección de Ejemplo", h2_fp),
    fp_p = fp_par(
      padding.top    = 10,
      padding.bottom = 3,
      border.bottom  = fp_border(color = "#E2E8F0", width = 0.5)
    )
  )
)

# --- Encabezado 3 ------------------------------------------------
doc <- officer::body_add_fpar(
  doc,
  fpar(ftext("1.1.1  Subsección de Ejemplo", h3_fp))
)

# --- Párrafo de cuerpo -------------------------------------------
doc <- officer::body_add_fpar(
  doc,
  fpar(
    ftext(
      paste(
        "Párrafo de cuerpo de muestra. Los modelos bayesianos jerárquicos ofrecen un marco",
        "probabilístico para combinar múltiples fuentes de información en la estimación",
        "subnacional de población."
      ),
      body_fp
    ),
    fp_p = fp_par(line_spacing = 1.15, text.align = "justify")
  )
)

doc <- officer::body_add_par(doc, "")

# --- Bloque de código --------------------------------------------
doc <- officer::body_add_fpar(
  doc,
  fpar(
    ftext("N_i <- sum(N_ise)", code_fp),
    fp_p = fp_par(
      shading.color  = ltbg,
      padding        = 8,
      border         = fp_border(color = blue, width = 1.5, side = "left")
    )
  )
)

# --- Guardar documento -------------------------------------------
out_file <- "word_template.docx"
print(doc, target = out_file)

cat(
  "\n[OK] Plantilla generada:", out_file,
  "\nActivar en _output.yml descomentando: reference_docx: word_template.docx\n"
)
