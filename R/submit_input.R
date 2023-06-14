#' Submit Input
#'
#' Submit Hessian input subdirectories to Condor for parallel computations.
#'
#' @param working.dir local directory containing Hessian subdirectories.
#' @param top.dir top directory on Condor submitter machine for running parallel
#'        Hessian computations.
#' @param \dots passed to \code{\link{condor_submit}}.
#'
#' @return Remote directory names with the job id as a name attribute.
#'
#' @examples
#' \dontrun{
#' session <- ssh_connect("servername")
#' submit_input("c:/x/yft/hessian")
#' }
#'
#' @importFrom condor condor_submit
#'
#' @export

submit_input <- function(working.dir, top.dir="condor_hessian", ...)
{
  # Examine directories
  dirs <- dir(working.dir, full.names=TRUE)
  dirs <- dirs[order(as.integer(gsub(".*_([0-9]+)", "\\1", dirs)))]  # sort
  n <- length(dirs)

  # Submit each model run directory to Condor, remembering job ids
  jobs <- character(n)
  ids <- integer(n)
  for(i in seq_len(n))
  {
    cat("Submitting ", basename(dirs[i]), "\n", sep="")
    job <- condor_submit(local.dir=dirs[i], top.dir=top.dir, ...)
    jobs[i] <- job
    ids[i] <- as.integer(names(job))
  }
  names(jobs) <- ids

  jobs
}
