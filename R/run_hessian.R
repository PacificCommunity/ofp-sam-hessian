local.dir <- "c:/x/yft/hessian"

run_hessian <- function(local.dir, ...)
{
  condor_submit(local.dir=local.dir, ...)
}
