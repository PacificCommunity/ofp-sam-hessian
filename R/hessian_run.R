#' Submit Hessian
#'
#' Submit parallel Hessian computations to Condor.
#'
#' @param working.dir local directory containing Hessian subdirectories.
#' @param top.dir top directory on Condor submitter machine for running parallel
#'        Hessian computations.
#' @param \dots passed to \code{\link{condor_submit}}.
#'
#' @return
#' Type of output.
#'
#' @examples
#' \dontrun{
#' run_hessian("c:/x/yft/hessian")
#' }
#'
#' @importFrom condor condor_submit
#'
#' @export

run_hessian <- function(working.dir, top.dir="condor_hessian", ...)
{
  for(i in 1)
    condor_submit(local.dir=working.dir, top.dir=top.dir, ...)
}
