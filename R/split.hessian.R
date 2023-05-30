original.dir <- file.path("z:/yft/2023/model_runs/stepwise",
                          "04_CatchCond/04b_Catch_Cond_New_CPUE")
working.dir <- "c:/x/yft/hessian"
njobs <- 4
force <- FALSE

library(FLR4MFCL)  # finalPar

read.npar <- function(parfile)
{
  txt <- readLines(parfile)
  line <- which(txt == "# The number of parameters") + 1
  npar <- as.integer(txt[line])
  npar
}

# split.hessian
# run.hessian
# check.hessian
# merge.hessian

split.hessian <- function(original.dir, working.dir, njobs, force=FALSE)
{
  # 1  Find MFCL input files
  frqfile <- dir(original.dir, pattern="\\.frq$")
  if(length(frqfile) != 1)
    stop("'original.dir' must contain one .frq file")
  parfile.full <- finalPar(original.dir, quiet=TRUE)
  parfile <- basename(parfile.full)
  species <- file_path_sans_ext(frqfile)

  # 2  Create empty directories
  dirs <- paste0("hess_", seq_len(njobs))
  dirs <- file.path(working.dir, dirs)
  if(any(dir.exists(dirs)))
    stop("'", dirs[dir.exists(dirs)][1], "' already exists")
  sapply(dirs, dir.create)

  # 3  Calculate cutting points
  npar <- read.npar(parfile.full)
  ind <- ceiling(seq(0, npar, length.out=njobs+1))  # 0 1000 2000 3000 4000
  beg <- ind[-length(ind)] + 1                      # 1 1001 2001 3001
  end <- ind[-1]                                    # 1000 2000 3000 4000

  # 4  Prepare scripts
  condor.run <- readLines(file.path(original.dir, "condor_run.sh"))
  condor.run <- gsub("doitall", "dohessian_calc", condor.run)
  dohessian.calc <- paste("mfclo64", frqfile, parfile,
                          "hessian -switch 3 1 145 1",
                          "1 223", beg, "1 224", end, "&")

  # 5  Populate directories
  files <- c(parfile, "condor.sub", "mfcl.cfg", "mfclo64",
             paste0(species, ".", c("age_length", "frq", "tag")))
  for(i in seq_along(dirs))
  {
    suppressWarnings(file.copy(file.path(original.dir, files), dirs[i],
                               copy.date=TRUE))
    writeLines(condor.run, file.path(dirs[i], "condor_run.sh"))
    writeLines(dohessian.calc[i], file.path(dirs[i], "dohessian_calc.sh"))
  }
  invisible(dirs)
}
