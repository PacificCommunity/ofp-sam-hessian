#' Submit Splits
#'
#' Submit Hessian split subdirectories to Condor for parallel computations.
#'
#' @param working.dir local directory containing Hessian subdirectories.
#' @param top.dir top directory on Condor submitter machine for running parallel
#'        Hessian computations.
#' @param \dots passed to \code{\link{condor_submit}}.
#'
#' @return Data frame showing submitted jobs.
#'
#' @examples
#' \dontrun{
#' session <- ssh_connect("servername")
#' submit_splits()
#' }
#'
#' @importFrom condor condor_submit
#'
#' @export

submit_splits <- function(working.dir=".", top.dir="condor", ...)
{
  # Examine directories
  dirs <- dir(working.dir, full.names=TRUE)
  dirs <- dirs[dir.exists(dirs)]          # only dirs, not files
  dirs <- dirs[grep(".*_[0-9]+$", dirs)]  # dir names that end with _number
  dirs <- dirs[order(as.integer(gsub(".*_([0-9]+)", "\\1", dirs)))]  # sort

  # Submit each model run directory to Condor, remembering job ids
  jobs <- data.frame(dir=character(), job.id=integer())
  for(i in seq_along(dirs))
  {
    cat("Submitting ", basename(dirs[i]), "\n", sep="")
    job <- condor_submit(local.dir=dirs[i], top.dir=top.dir, ...)
    jobs[i,"dir"] <- as.character(job)
    jobs[i,"job.id"] <- as.integer(names(job))
  }

  jobs
}
