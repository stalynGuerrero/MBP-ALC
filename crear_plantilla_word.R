# ================================================================
# Genera word_template.docx para el libro MBP-ALC
#
# Estrategia: partir de la plantilla de referencia NATIVA de pandoc
# (la que ya contiene los nombres de estilo que Word/pandoc esperan:
# Title, Subtitle, Author, Date, heading 1..6, Body Text, Hyperlink,
# Caption, etc.) y reescribir las DEFINICIONES de esos estilos
# (fuente, color, tamaño) directamente en el XML (word/styles.xml y
# word/theme/theme1.xml), para que --reference-doc de pandoc herede
# la paleta y tipografías del libro (Cambria/Calibri, navy/azul CEPAL)
# ya usadas en preamble.tex y style.css.
#
# NOTA IMPORTANTE: rellenar un .docx con párrafos de muestra (como en
# versiones anteriores de este script) NO funciona como reference_docx,
# porque pandoc solo lee las DEFINICIONES de estilo con nombre del
# catálogo styles.xml, no el contenido de párrafos existentes.
#
# La edición se hace con reemplazos de texto/regex sobre el XML en
# lugar de construir nodos con xml2, por robustez y facilidad de
# depuración.
#
# Requiere: install.packages(c("officer", "rmarkdown"))
#
# Uso:
#   source("crear_plantilla_word.R")
#   Luego descomentar reference_docx en _output.yml
# ================================================================

library(officer)

# --- Colores y fuentes CEPAL (coherentes con preamble.tex y style.css) ---
navy <- "1B2A4A"  # cepalnavy
blue <- "2563EB"  # cepalblue / accent1
gray <- "4A5568"  # cepalgray
ltbg <- "F8FAFC"  # cepalltbg (fondo de código)

font_headings <- "Calibri"  # coherente con \\setsansfont{Calibri} + titlesec en preamble.tex
font_body     <- "Cambria"  # coherente con \\setmainfont{Cambria} en preamble.tex
font_code     <- "Consolas" # coherente con \\setmonofont{Consolas} en preamble.tex

# --- 1. Generar la plantilla de referencia nativa de pandoc -----------
base_docx <- file.path(tempdir(), "pandoc_reference_base.docx")
system2(
  rmarkdown::pandoc_exec(),
  c("-o", shQuote(base_docx), "--print-default-data-file", "reference.docx")
)
stopifnot(file.exists(base_docx))

# --- 2. Abrir con officer para obtener el directorio descomprimido ----
doc <- officer::read_docx(base_docx)
pkg_dir <- doc$package_dir

# --- 3. Editar el esquema de tema (fuentes y color de acento) ---------
theme_path <- file.path(pkg_dir, "word", "theme", "theme1.xml")
theme_xml  <- paste(readLines(theme_path, warn = FALSE, encoding = "UTF-8"), collapse = "\n")

replace_srgb <- function(content, tag, hex) {
  pattern <- sprintf('(<a:%s>\\s*<a:srgbClr val=")[0-9A-Fa-f]{6}("\\s*/>\\s*</a:%s>)', tag, tag)
  sub(pattern, paste0("\\1", hex, "\\2"), content, perl = TRUE)
}

theme_xml <- replace_srgb(theme_xml, "dk2",     navy)  # texto oscuro secundario del tema
theme_xml <- replace_srgb(theme_xml, "accent1", blue)  # color de acento usado por encabezados

theme_xml <- sub(
  '(<a:majorFont>\\s*<a:latin typeface=")[^"]*(")',
  paste0("\\1", font_headings, "\\2"), theme_xml, perl = TRUE
)
theme_xml <- sub(
  '(<a:minorFont>\\s*<a:latin typeface=")[^"]*(")',
  paste0("\\1", font_body, "\\2"), theme_xml, perl = TRUE
)

writeLines(theme_xml, theme_path, useBytes = TRUE)

# --- 4. Editar el catálogo de estilos con nombre ----------------------
styles_path <- file.path(pkg_dir, "word", "styles.xml")
styles_xml  <- paste(readLines(styles_path, warn = FALSE, encoding = "UTF-8"), collapse = "\n")

# Reemplaza el contenido del bloque <w:style ... w:styleId="ID">...</w:style>
# aplicando `transform_fn` solo dentro de ese bloque.
replace_style_block <- function(content, style_id, transform_fn) {
  pattern <- sprintf('(?s)<w:style\\b[^>]*w:styleId="%s"[^>]*>.*?</w:style>', style_id)
  m <- regexpr(pattern, content, perl = TRUE)
  if (m[1] == -1) return(content)
  block     <- regmatches(content, m)
  new_block <- transform_fn(block)
  regmatches(content, m) <- new_block
  content
}

# Fija (o inserta) el color de texto dentro de un bloque de estilo,
# eliminando referencias a color de tema para que sea determinista.
set_block_color <- function(block, hex) {
  if (grepl("<w:color ", block, fixed = TRUE)) {
    sub('<w:color[^/]*/>', sprintf('<w:color w:val="%s" />', hex), block, perl = TRUE)
  } else if (grepl("<w:rPr>", block, fixed = TRUE)) {
    sub("<w:rPr>", sprintf('<w:rPr><w:color w:val="%s" />', hex), block, fixed = TRUE)
  } else if (grepl("<w:rPr\\s*/>", block, perl = TRUE)) {
    sub("<w:rPr\\s*/>", sprintf('<w:rPr><w:color w:val="%s" /></w:rPr>', hex), block, perl = TRUE)
  } else {
    sub("</w:style>", sprintf('<w:rPr><w:color w:val="%s" /></w:rPr></w:style>', hex), block, fixed = TRUE)
  }
}

heading_ids <- c(
  "Title", "TitleChar",
  "Heading1", "Heading1Char", "Heading2", "Heading2Char",
  "Heading3", "Heading3Char", "Heading4", "Heading4Char",
  "Heading5", "Heading5Char", "Heading6", "Heading6Char"
)
for (id in heading_ids) {
  styles_xml <- replace_style_block(styles_xml, id, function(b) set_block_color(b, navy))
}

muted_ids <- c("Subtitle", "SubtitleChar", "Author", "Date")
for (id in muted_ids) {
  styles_xml <- replace_style_block(styles_xml, id, function(b) set_block_color(b, gray))
}

styles_xml <- replace_style_block(styles_xml, "Hyperlink", function(b) set_block_color(b, blue))

# --- 5. Estilo de código (bloques de código de los capítulos) ---------
# pandoc asigna el estilo de párrafo "SourceCode" a los bloques de
# código resaltado en salida .docx; si no existe en la plantilla de
# referencia, se agrega aquí con la tipografía y sombreado del libro.
if (!grepl('w:styleId="SourceCode"', styles_xml, fixed = TRUE)) {
  source_code_style <- paste0(
    '<w:style w:type="paragraph" w:customStyle="1" w:styleId="SourceCode">',
    '<w:name w:val="Source Code" />',
    '<w:basedOn w:val="Normal" />',
    '<w:qFormat />',
    '<w:pPr>',
    '<w:spacing w:before="120" w:after="120" />',
    '<w:shd w:val="clear" w:fill="', ltbg, '" />',
    '</w:pPr>',
    '<w:rPr>',
    '<w:rFonts w:ascii="', font_code, '" w:hAnsi="', font_code, '" w:cs="', font_code, '" />',
    '<w:sz w:val="18" />',
    '<w:szCs w:val="18" />',
    '</w:rPr>',
    '</w:style>'
  )
  styles_xml <- sub("</w:styles>", paste0(source_code_style, "</w:styles>"), styles_xml, fixed = TRUE)
}

writeLines(styles_xml, styles_path, useBytes = TRUE)

# --- 6. Reempaquetar como word_template.docx --------------------------
out_file <- "word_template.docx"
print(doc, target = out_file)

cat(
  "\n[OK] Plantilla generada:", out_file,
  "\nActivar en _output.yml descomentando: reference_docx: word_template.docx\n"
)
