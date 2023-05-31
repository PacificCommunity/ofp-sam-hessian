#' Hessian Submit
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
#' hessian_submit("c:/x/yft/hessian")
#' }
#'
#' @importFrom condor condor_submit
#'
#' @export

hessian_submit <- function(working.dir, top.dir="condor_hessian", ...)
{
  for(i in 1)
    condor_submit(local.dir=working.dir, top.dir=top.dir, ...)
}
