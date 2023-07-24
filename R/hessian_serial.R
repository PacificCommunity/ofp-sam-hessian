#' Hessian Serial
#'
#' Prepare working directory for serial Hessian calculation.
#'
#' @param original.dir directory containing a converged model run.
#' @param working.dir directory where Hessian run will be prepared.
#'
#' @return Files in working directory after preparation.
#'
#' @examples
#' \dontrun{
#' hessian_serial("z:/yft/2023/model_runs/diagnostic")
#' }
#'
#' @importFrom FLR4MFCL finalPar
#' @importFrom tools file_path_sans_ext
#'
#' @export

hessian_serial <- function(original.dir, working.dir=basename(original.dir))
{
  # 1  Required files
  parfile <- basename(finalPar(run.dir))
  species <- file_path_sans_ext(grep("\\.frq$", dir(run.dir), value=TRUE))
  agelenfile <- paste0(species, ".age_length")
  frqfile <- paste0(species, ".frq")
  tagfile <- paste0(species, ".tag")
  req <- c(parfile, "condor.sub", "condor_run.sh", "doitall.sh", "labels.tmp",
           "mfcl.cfg", "mfclo64", agelenfile, frqfile, tagfile)

  # 2  Remove unnecessary files
  file.remove(dir(run.dir, full=TRUE)[!(dir(run.dir) %in% req)])

  # 3  Prepare doitall
  doitall <-
    c("#!/bin/sh", "",
      paste("mfclo64", frqfile, parfile, "junk1 -file - <<HESS", collapse=" "),
      "  1 1 1",
      "  1 145 1    # compute Hessian",
      "  1 145 5    # produce correlation report",
      "HESS")

  # 4  Write doitall to file
  con <- file(file.path(run.dir, "doitall.sh"), "wb")
  writeLines(doitall, con)
  close(con)

  invisible(dir(run.dir))
}
