#' Multi-Engine LaTeX Dependency Checker
#'
#' Scans for .sty files and attempts to identify the parent package
#' regardless of the underlying LaTeX distribution (TeX Live or MiKTeX).
#'
#' @param sty_list Character vector of style files (e.g., "zref-base.sty")
#'
#' @return A data frame with the file status and the required package name.
#' @export
check_latex_dependencies_multi <- function(sty_list) {
  
  # Determine the distribution type
  tex_info <- tryCatch({
    system2("pdflatex", "--version", stdout = TRUE, stderr = NULL)[1]
  }, error = function(e) "Unknown")
  
  is_miktex <- grepl("MiKTeX", tex_info, ignore.case = TRUE)
  dist_name <- if (is_miktex) "MiKTeX" else "TeX Live/Other"
  
  cli::cli_alert_info("Detected LaTeX Distribution: {dist_name}")
  
  results <- purrr::map_df(sty_list, function(sty) {
    # Check if file exists using kpsewhich (works on both)
    path <- system2("kpsewhich", sty, stdout = TRUE, stderr = NULL)
    is_installed <- length(path) > 0
    
    pkg_name <- NA_character_
    
    # If missing, find the owner package
    if (!is_installed) {
      if (is_miktex) {
        # MiKTeX specific lookup using mpm (MiKTeX Package Manager)
        pkg_search <- system2("mpm", c("--list-file-owners", sty), 
                              stdout = TRUE, stderr = NULL)
        if (length(pkg_search) > 0) pkg_name <- pkg_search[1]
      } else {
        # TeX Live specific lookup
        pkg_search <- system2("tlmgr", c("search", "--file", paste0("/", sty)), 
                              stdout = TRUE, stderr = NULL)
        if (length(pkg_search) > 0) pkg_name <- gsub(":.*", "", pkg_search[1])
      }
    }
    
    tibble::tibble(
      file = sty,
      installed = is_installed,
      required_package = pkg_name,
      path = if (is_installed) path[1] else "MISSING"
    )
  })
  
  # Summary and call to action
  missing_data <- results |> dplyr::filter(!installed)
  if (nrow(missing_data) > 0) {
    unique_pkgs <- unique(na.omit(results$required_package))
    
    if (is_miktex) {
      cat("\nRun this in your terminal to install missing MiKTeX packages:\n")
      cat("mpm --install", paste(unique_pkgs, collapse = " "), "\n\n")
    } else {
      cat("\nRun this in your terminal to install missing TeX Live packages:\n")
      cat("tlmgr install", paste(unique_pkgs, collapse = " "), "\n\n")
    }
  } else {
    cli::cli_alert_success("All style files are present and accounted for.")
  }
  
  return(results)
}


#List of Latex dependencies from Sam.

sty_list <- c(
  "pdfmanagement-testphase.sty", "tagpdf-base.sty", "latex-lab-testphase-latest.sty", 
  "tagpdf.sty", "tagpdf-mc-code-lua.sty", "latex-lab-testphase-names.sty", 
  "latex-lab-testphase-new-or-2.sty", "latex-lab-testphase-block.sty", 
  "latex-lab-kernel-changes.sty", "latex-lab-testphase-context.sty", 
  "latex-lab-testphase-sec.sty", "latex-lab-testphase-toc.sty", 
  "latex-lab-testphase-minipage.sty", "latex-lab-testphase-new-or-1.sty", 
  "latex-lab-testphase-graphic.sty", "latex-lab-testphase-float.sty", 
  "latex-lab-testphase-bib.sty", "latex-lab-testphase-text.sty", 
  "latex-lab-testphase-marginpar.sty", "latex-lab-testphase-title.sty", 
  "latex-lab-testphase-table.sty", "array.sty", "latex-lab-testphase-math.sty", 
  "latex-lab-testphase-firstaid.sty", "latex-lab-testphase-tikz.sty", 
  "pdfmanagement-firstaid.sty", "scrkbase.sty", "scrbase.sty", "scrlfile.sty", 
  "scrlfile-hook.sty", "scrlogo.sty", "keyval.sty", "tocbasic.sty", 
  "typearea.sty", "xcolor.sty", "xcolor-patches-tmp-ltx.sty", "amsmath.sty", 
  "amstext.sty", "amsgen.sty", "amsbsy.sty", "amsopn.sty", "amssymb.sty", 
  "amsfonts.sty", "iftex.sty", "expl3.sty", "unicode-math-luatex.sty", 
  "xparse.sty", "l3keys2e.sty", "fontspec.sty", "fontspec-luatex.sty", 
  "fontenc.sty", "fix-cm.sty", "lualatex-math.sty", "etoolbox.sty", 
  "lmodern.sty", "longtable.sty", "booktabs.sty", "calc.sty", "footnote.sty", 
  "graphicx.sty", "graphics.sty", "trig.sty", "babel.sty", "luatexbase.sty", 
  "ctablestack.sty", "selnolig.sty", "ifluatex.sty", "selnolig-english-patterns.sty", 
  "selnolig-english-hyphex.sty", "hyphenat.sty", "pdfcomment.sty", "xkeyval.sty", 
  "luatex85.sty", "datetime2.sty", "tracklang.sty", "zref-savepos.sty", 
  "zref-base.sty", "ltxcmds.sty", "infwarerr.sty", "kvsetkeys.sty", 
  "kvdefinekeys.sty", "pdftexcmds.sty", "etexcmds.sty", "auxhook.sty", 
  "refcount.sty", "ifthen.sty", "marginnote.sty", "ifpdf.sty", "soulpos.sty", 
  "hyperref.sty", "pdfescape.sty", "hycolor.sty", "nameref.sty", 
  "gettitlestring.sty", "kvoptions.sty", "stringenc.sty", "intcalc.sty", 
  "url.sty", "bitset.sty", "bigintcalc.sty", "wallpaper.sty", "eso-pic.sty", 
  "geometry.sty", "ifvtex.sty", "scrlayer-scrpage.sty", "scrlayer.sty", 
  "pdflscape.sty", "lscape.sty", "glossaries.sty", "mfirstuc.sty", "xfor.sty", 
  "datatool-base.sty", "glossary-hypernav.sty", "glossary-list.sty", 
  "glossary-long.sty", "glossary-tree.sty", "multirow.sty", "wrapfig.sty", 
  "float.sty", "colortbl.sty", "tabu.sty", "varwidth.sty", "threeparttable.sty", 
  "threeparttablex.sty", "environ.sty", "trimspaces.sty", "ulem.sty", 
  "makecell.sty", "caption.sty", "caption3.sty", "ltcaption.sty", 
  "anyfontsize.sty", "subcaption.sty", "bookmark.sty", "luamml.sty", 
  "luamml-patches-kernel.sty", "luamml-patches-amsmath.sty", "epstopdf-base.sty", 
  "soulutf8.sty", "soul.sty", "soul-ori.sty"
)


# Implementation: Use your specific list
# (Paste your list into a character vector first)

# Run the check
dependency_report <- check_latex_dependencies(sty_list)


