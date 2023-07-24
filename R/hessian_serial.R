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

  # 3  Prepare scripts
  condor.run <- readLines(file.path(working.dir, "condor_run.sh"))
  condor.run <- gsub("doitall", "dohessian_serial", condor.run)
  dohessian.serial <- c("#!/bin/bash", "",
                        paste("mfclo64", frqfile, parfile,
                              "hessian -switch 2", "1 1 1", "1 145 1"),
                        paste("mfclo64", frqfile, parfile,
                              "hessian -switch 2", "1 1 1", "1 145 5"))

  # 4  Write scripts to files
  con <- file(file.path(working.dir, "condor_run.sh"), "wb")
  writeLines(condor.run, con)        # must have Unix line endings
  close(con)
  con <- file(file.path(working.dir, "dohessian_serial.sh"), "wb")
  writeLines(dohessian.serial, con)  # must have Unix line endings
  close(con)

  invisible(dir(working.dir))
}
