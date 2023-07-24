#' Hessian Serial
#'
#' Prepare working directory for serial Hessian calculation.
#'
#' @param original.dir directory containing a converged model run.
#' @param working.dir directory where Hessian run will be prepared.
#' @param overwrite whether to remove existing working directory.
#'
#' @return Filenames in working directory after preparation.
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

hessian_serial <- function(original.dir, working.dir=basename(original.dir),
                           overwrite=FALSE)
{
  # 1  List required files
  parfile <- basename(finalPar(original.dir))
  species <- file_path_sans_ext(grep("\\.frq$", dir(original.dir), value=TRUE))
  agelenfile <- paste0(species, ".age_length")
  frqfile <- paste0(species, ".frq")
  tagfile <- paste0(species, ".tag")
  files <- c(parfile, "condor.sub", "condor_run.sh", "doitall.sh", "labels.tmp",
             "mfcl.cfg", "mfclo64", agelenfile, frqfile, tagfile)

  # 2  Copy required files to working directory
  if(dir.exists(working.dir) && !overwrite)
    stop("working.dir already exists, consider overwrite=TRUE")
  unlink(working.dir, recursive=TRUE)
  dir.create(working.dir)
  suppressWarnings(file.copy(file.path(original.dir, files), working.dir,
                             copy.date=TRUE))  # some files could be missing

  # 3  Prepare doitall
  doitall <-
    c("#!/bin/sh", "",
      paste("mfclo64", frqfile, parfile, "junk1 -file - <<HESS", collapse=" "),
      "  1 1 1",
      "  1 145 1    # compute Hessian",
      "  1 145 5    # produce correlation report",
      "HESS")

  # 4  Write doitall to file
  con <- file(file.path(working.dir, "doitall.sh"), "wb")
  writeLines(doitall, con)
  close(con)

  invisible(dir(working.dir))
}
