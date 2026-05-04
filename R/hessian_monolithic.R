#' Hessian Monolithic
#'
#' Prepare a Hessian monolithic model run by adding Hessian flags to an existing
#' \verb{doitall.sh} script.
#'
#' @param original.dir directory containing input files for a model run.
#' @param working.dir directory where Hessian run will be prepared.
#' @param overwrite whether to remove existing working directory.
#' @param quiet whether to suppress messages.
#'
#' @details
#' The default value of \code{working.dir = NULL} creates a local working
#' directory with the same name as \code{original.dir} but with a prefix
#' \verb{Hess_}.
#'
#' @return Working directory name where files have been prepared.
#'
#' @note
#' The term \emph{monolithic} refers to a \verb{doitall.sh} script that first
#' fits a model and then calculates the Hessian.
#'
#' A monolithic calculation takes a longer time run than a \verb{stand-alone} or
#' \emph{parallel} Hessian calculation.
#'
#' @examples
#' \dontrun{
#' hessian_monolithic("z:/yft/2023/model_runs/diagnostic")
#' }
#'
#' @importFrom tools file_path_sans_ext
#' @importFrom utils tail
#'
#' @export

hessian_monolithic <- function(original.dir, working.dir=NULL, overwrite=FALSE,
                               quiet=FALSE)
{
  # 1  Create working directory
  if(is.null(working.dir))
    working.dir <- paste0("Hess_", basename(original.dir))
  if(!quiet)
    cat("Preparing", basename(working.dir), "... ")

  # 2  List required files
  species <- file_path_sans_ext(grep("\\.frq$", dir(original.dir), value=TRUE))
  agelenfile <- paste0(species, ".age_length")
  frqfile <- paste0(species, ".frq")
  inifile <- paste0(species, ".ini")
  tagfile <- paste0(species, ".tag")
  files <- c("condor.sub", "condor_run.sh", "doitall.sh", "labels.tmp",
             "mfcl.cfg", "mfclo64", agelenfile, frqfile, inifile, tagfile)

  # 3  Copy required files to working directory
  if(dir.exists(working.dir) && !overwrite)
    stop("working.dir already exists, consider overwrite=TRUE")
  unlink(working.dir, recursive=TRUE)
  dir.create(working.dir)
  suppressWarnings(file.copy(file.path(original.dir, files), working.dir,
                             copy.date=TRUE))  # some files could be missing

  # 4  Prepare script
  doitall <- readLines(file.path(working.dir, "doitall.sh"))
  n <- tail(grep("[0-9][0-9]\\.par", doitall), 1)
  parfile <- sub(".*frq [0-9][0-9]\\.par ", "", doitall[n])
  parfile <- sub(" .*", "", parfile)
  doitall.hessian <- c(doitall, "",
                       paste("mfclo64", frqfile, parfile,
                             "hessian -switch 2", "1 1 1", "1 145 1"),
                       paste("mfclo64", frqfile, parfile,
                             "hessian -switch 2", "1 1 1", "1 145 5"))

  # 5  Write script to file
  con <- file(file.path(working.dir, "doitall.sh"), "wb")
  writeLines(doitall.hessian, con)  # must have Unix line endings
  close(con)
  Sys.chmod(file.path(working.dir, "doitall.sh"), "755")
  if(!quiet)
    cat("done", fill=TRUE)

  invisible(working.dir)
}
