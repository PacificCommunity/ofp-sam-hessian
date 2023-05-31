local.dir <- "c:/x/yft/hessian"

library(help="TAF")
help(package="TAF")
help("TAF")
help("TAF-package")
?TAF
?"TAF-package"

run_hessian <- function(local.dir, ...)
{
  condor_submit(local.dir=local.dir, ...)
}
