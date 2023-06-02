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
#' session <- ssh_connect("servername")
#' hessian_submit("c:/x/yft/hessian")
#' }
#'
#' @importFrom condor condor_submit
#'
#' @export

hessian_submit <- function(working.dir, top.dir="condor_hessian", ...)
{
  dirs <- dir(working.dir, full.names=TRUE)
  dirs <- dirs[order(as.integer(gsub(".*_([0-9]+)", "\\1", dirs)))]  # sort
  for(i in seq_along(dirs))
  {
    cat("Submitting ", basename(dirs[i]), "\n", sep="")
    condor_submit(local.dir=dirs[i], top.dir=top.dir, ...)
  }
}
