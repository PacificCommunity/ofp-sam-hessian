#' Hessian Merge
#'
#' Gather \verb{.hes} files from parallel computations into one directory.
#'
#' @param working.dir local directory containing Hessian subdirectories.
#' @param quiet whether to suppress messages.
#'
#' @return Directory containing the \verb{.hes} files, ready to merge.
#'
#' @examples
#' \dontrun{
#' hessian_merge("z:/yft/2023/model_runs/hessian/diagnostic")
#' }
#'
#' @importFrom tools file_path_sans_ext
#' @importFrom FLR4MFCL finalPar
#'
#' @export

hessian_merge <- function(working.dir, quiet=FALSE)
{
  if(!quiet)
    cat("*", basename(working.dir), fill=TRUE)

  # 1  Create merge directory
  merge.dir <- file.path(working.dir, "merge")
  unlink(merge.dir, recursive=TRUE)
  dir.create(merge.dir)

  # 2  Copy .hes files from stripe dirs into working dir
  from <- dir(working.dir, pattern="\\.hes$", full.names=TRUE, recursive=TRUE)
  to <- file.path(merge.dir, paste0(basename(from), "_", seq_along(from)))
  for(i in seq_along(from))
  {
    if(!quiet)
      cat(" ", basename(to)[i], fill=TRUE)
    file.copy(from[i], to[i], overwrite=TRUE, copy.date=TRUE)
  }

  # 3  Copy additional required model files from 1st run directory
  parfile <- basename(finalPar(first.dir))
  species <- file_path_sans_ext(basename(from))[1]
  agelenfile <- paste0(species, ".age_length")
  frqfile <- paste0(species, ".frq")
  tagfile <- paste0(species, ".tag")
  first.dir <- dirname(from)[1]
  files <- file.path(first.dir, c(parfile, "mfcl.cfg", "mfclo64", "parall_hess",
                                  agelenfile, frqfile, tagfile))
  file.copy(files, merge.dir, overwrite=TRUE, copy.date=TRUE)

  # 4  Prepare script
  dohessian.merge <-
    c("#!/bin/bash", "",
      paste("mfclo64", frqfile, parfile, "hessian -switch 1 1 145 11"),
      paste("mfclo64", frqfile, parfile, "hessian -switch 1 1 145 5"))

  # 5  Write script to file
  con <- file(file.path(merge.dir, "dohessian_merge.sh"), "wb")
  writeLines(dohessian.merge, con)  # must have Unix line endings
  close(con)

  invisible(merge.dir)
}
