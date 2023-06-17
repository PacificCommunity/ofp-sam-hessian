#' Hessian Merge
#'
#' Gather \verb{.hes} files from parallel computations into one directory.
#'
#' @param working.dir local directory containing Hessian subdirectories.
#' @param top.dir top directory on Condor submitter machine containing parallel
#'        Hessian computations.
#' @param \dots passed to \code{\link{condor_download}}.
#'
#' @return Data frame showing downloaded jobs.
#'
#' @examples
#' \dontrun{
#' session <- ssh_connect("servername")
#' hessian_merge("c:/x/yft/hessian")
#' }
#'
#' @importFrom condor condor_dir condor_download
#'
#' @export

hessian_merge <- function(working.dir, top.dir="condor_hessian", ...)
{
  jobs <- condor_dir(top.dir=top.dir)

  # Ensure all jobs are finished
  if(any(jobs$status != "finished"))
  {
    print(jobs)
    stop("all jobs must have status 'finished'")
  }

  for(i in seq_len(nrow(jobs)))
  {
    cat("* Gathering ", jobs$dir[i], "\n", sep="")
    condor_download(run.dir=jobs$dir[i],
                    local.dir=file.path(working.dir, jobs$dir[i]),
                    top.dir=top.dir, create.dir=TRUE, overwrite=TRUE)
  }

  invisible(jobs)
}
