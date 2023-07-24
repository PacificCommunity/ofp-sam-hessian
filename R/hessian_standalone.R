#' Hessian Stand-Alone
#'
#' Prepare working directory for Hessian stand-alone calculation, starting from
#' a converged model run.
#'
#' @param original.dir directory containing a converged model run.
#' @param working.dir directory where Hessian run will be prepared.
#' @param overwrite whether to remove existing working directory.
#'
#' @details
#' The default value of \code{working.dir = NULL} creates a local working
#' directory with the same name as \code{original.dir} but with a prefix
#' \verb{Hess_}.
#'
#' @return Working directory name where files have been prepared.
#'
#' @note
#' The term \emph{stand-alone} refers to a calculation of the Hessian that
#' starts from a converged model.
#'
#' A stand-alone calculation takes a shorter time to run than a
#' \emph{monolithic} run, where an extended \verb{doitall.sh} script first fits
#' a model and then calculates the Hessian.
#'
#' A stand-alone calculation takes a longer time to run than a \emph{parallel}
#' Hessian calculation, where computations are run simultaneously on many cores.
#'
#' @examples
#' \dontrun{
#' hessian_standalone("z:/yft/2023/model_runs/diagnostic")
#' }
#'
#' @importFrom FLR4MFCL finalPar
#' @importFrom tools file_path_sans_ext
#'
#' @export

hessian_standalone <- function(original.dir, working.dir=NULL, overwrite=FALSE,
                               quiet=FALSE)
{
  # 1  Create working directory
  if(is.null(working.dir))
    working.dir <- paste0("Hess_", basename(original.dir))
  if(!quiet)
    cat("Preparing", basename(working.dir), "... ")

  # 2  List required files
  parfile <- basename(finalPar(original.dir))
  species <- file_path_sans_ext(grep("\\.frq$", dir(original.dir), value=TRUE))
  agelenfile <- paste0(species, ".age_length")
  frqfile <- paste0(species, ".frq")
  tagfile <- paste0(species, ".tag")
  files <- c(parfile, "condor.sub", "condor_run.sh", "doitall.sh", "labels.tmp",
             "mfcl.cfg", "mfclo64", agelenfile, frqfile, tagfile)

  # 3  Copy required files to working directory
  if(dir.exists(working.dir) && !overwrite)
    stop("working.dir already exists, consider overwrite=TRUE")
  unlink(working.dir, recursive=TRUE)
  dir.create(working.dir)
  suppressWarnings(file.copy(file.path(original.dir, files), working.dir,
                             copy.date=TRUE))  # some files could be missing

  # 4  Prepare scripts
  condor.run <- readLines(file.path(working.dir, "condor_run.sh"))
  condor.run <- gsub("doitall", "dohessian_standalone", condor.run)
  dohessian.standalone <- c("#!/bin/bash", "",
                            paste("mfclo64", frqfile, parfile,
                                  "hessian -switch 2", "1 1 1", "1 145 1"),
                            paste("mfclo64", frqfile, parfile,
                                  "hessian -switch 2", "1 1 1", "1 145 5"))

  # 5  Write scripts to files
  con <- file(file.path(working.dir, "condor_run.sh"), "wb")
  writeLines(condor.run, con)            # must have Unix line endings
  close(con)
  con <- file(file.path(working.dir, "dohessian_standalone.sh"), "wb")
  writeLines(dohessian.standalone, con)  # must have Unix line endings
  close(con)
  if(!quiet)
    cat("done", fill=TRUE)

  invisible(working.dir)
}
