#' Hessian Split
#'
#' Prepare Hessian split subdirectories for parallel computations.
#'
#' @param original.dir directory containing a converged model run.
#' @param working.dir directory where Hessian subdirectories will be created.
#' @param njobs number of parallel jobs to create.
#' @param overwrite whether to remove existing subdirectories.
#'
#' @return Names of subdirectories created.
#'
#' @examples
#' \dontrun{
#' hessian_split("z:/yft/2023/model_runs/diagnostic", njobs=16)
#' }
#'
#' @importFrom tools file_path_sans_ext
#' @importFrom FLR4MFCL finalPar
#'
#' @export

hessian_split <- function(original.dir, working.dir=basename(original.dir),
                          njobs, overwrite=FALSE)
{
  # 1  Find MFCL input files
  frqfile <- dir(original.dir, pattern="\\.frq$")
  if(length(frqfile) != 1)
    stop("'original.dir' must contain one .frq file")
  parfile.full <- finalPar(original.dir, quiet=TRUE)
  parfile <- basename(parfile.full)
  species <- file_path_sans_ext(frqfile)
  files <- c(parfile, "condor.sub", "mfcl.cfg", "mfclo64",
             paste0(species, ".", c("age_length", "frq", "tag")))

  # 2  Create empty directories
  model <- basename(original.dir)
  job <- formatC(seq_len(njobs), width=nchar(njobs), flag="0")  # leading zeros
  dirs <- paste0("hessian_", model, "_", job)
  dirs <- file.path(working.dir, dirs)
  if(any(dir.exists(dirs)) && overwrite)
    unlink(dirs, recursive=TRUE)
  if(any(dir.exists(dirs)) && !overwrite)
  {
    stop("'", dirs[dir.exists(dirs)][1],
         "' already exists, consider overwrite=TRUE")
  }
  sapply(dirs, dir.create, recursive=TRUE, showWarnings=FALSE)

  # 3  Calculate cutting points
  npar <- read_npar(parfile.full)
  ind <- ceiling(seq(0, npar, length.out=njobs+1))  # 0 1000 2000 3000 4000
  beg <- ind[-length(ind)] + 1                      # 1 1001 2001 3001
  end <- ind[-1]                                    # 1000 2000 3000 4000

  # 4  Prepare parall_hess
  parall.hess <- c(njobs, npar, paste(beg, collapse=" "))

  # 5  Prepare scripts
  condor.run <- readLines(file.path(original.dir, "condor_run.sh"))
  condor.run <- gsub("doitall", "dohessian_split", condor.run)
  dohessian.split <- c("#!/bin/bash", "",
                       paste("mfclo64", frqfile, parfile, "hessian -switch 3",
                             "1 145 1", "1 223", beg, "1 224", end))

  # 6  Prepare tempdir
  # Many times faster to copy once from Penguin instead of njobs times
  tempdir.hessian <- file.path(tempdir(), "hessian")
  unlink(tempdir.hessian, recursive=TRUE)
  dir.create(tempdir.hessian)
  suppressWarnings(file.copy(file.path(original.dir, files), tempdir.hessian,
                             copy.date=TRUE))  # some files could be missing

  # 7  Populate directories
  for(i in seq_along(dirs))
  {
    file.copy(dir(tempdir.hessian, full.names=TRUE), dirs[i], copy.date=TRUE)
    con <- file(file.path(dirs[i], "condor_run.sh"), "wb")
    writeLines(condor.run, con)          # must have Unix line endings
    close(con)
    con <- file(file.path(dirs[i], "dohessian_split.sh"), "wb")
    writeLines(dohessian.split[i], con)  # must have Unix line endings
    close(con)
    con <- file(file.path(dirs[i], "parall_hess"), "wb")
    writeLines(parall.hess, con)         # must have Unix line endings
    close(con)
  }
  unlink(tempdir.hessian, recursive=TRUE)

  dirs
}
