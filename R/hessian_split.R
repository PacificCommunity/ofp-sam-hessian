#' Hessian Split
#'
#' Split upcoming parallel Hessian computations into subdirectories.
#'
#' @param original.dir directory containing a converged model run.
#' @param working.dir directory where subdirectories will be created.
#' @param njobs number of parallel jobs to create.
#' @param force whether to remove existing subdirectories.
#'
#' @return Names of subdirectories created.
#'
#' @examples
#' \dontrun{
#' hessian_split("z:/yft/2023/model_runs/diagnostic", "c:/x/yft/hessian", 16)
#' }
#'
#' @importFrom tools file_path_sans_ext
#' @importFrom FLR4MFCL finalPar
#'
#' @export

hessian_split <- function(original.dir, working.dir, njobs, force=FALSE)
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
  dirs <- paste0("hess_", seq_len(njobs))
  dirs <- file.path(working.dir, dirs)
  if(any(dir.exists(dirs)) && force)
    unlink(dirs, recursive=TRUE)
  if(any(dir.exists(dirs)) && !force)
  {
    stop("'", dirs[dir.exists(dirs)][1],
         "' already exists, consider force=TRUE")
  }
  sapply(dirs, dir.create)

  # 3  Calculate cutting points
  npar <- read_npar(parfile.full)
  ind <- ceiling(seq(0, npar, length.out=njobs+1))  # 0 1000 2000 3000 4000
  beg <- ind[-length(ind)] + 1                      # 1 1001 2001 3001
  end <- ind[-1]                                    # 1000 2000 3000 4000

  # 4  Prepare scripts
  condor.run <- readLines(file.path(original.dir, "condor_run.sh"))
  condor.run <- gsub("doitall", "dohessian_calc", condor.run)
  dohessian.calc <- paste("#!/bin/bash\n\nmfclo64", frqfile, parfile,
                          "hessian -switch 3 1 145 1",
                          "1 223", beg, "1 224", end, "&")

  # 5  Prepare tempdir
  # Many times faster to copy once from Penguin instead of njobs times
  tempdir.hessian <- file.path(tempdir(), "hessian")
  unlink(tempdir.hessian, recursive=TRUE)
  dir.create(tempdir.hessian)
  suppressWarnings(file.copy(file.path(original.dir, files), tempdir.hessian,
                             copy.date=TRUE))  # some files could be missing

  # 6  Populate directories
  for(i in seq_along(dirs))
  {
    file.copy(dir(tempdir.hessian, full.names=TRUE), dirs[i], copy.date=TRUE)
    # Bash scripts must have Unix line endings
    con <- file(file.path(dirs[i], "condor_run.sh"), "wb")
    writeLines(condor.run, con)
    close(con)
    con <- file(file.path(dirs[i], "dohessian_calc.sh"), "wb")
    writeLines(dohessian.calc[i], con)
    close(con)
  }
  unlink(tempdir.hessian, recursive=TRUE)

  invisible(dirs)
}
