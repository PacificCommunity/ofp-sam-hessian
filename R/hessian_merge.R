#' Hessian Gather
#'
#' Gather parallel Hessian computations from Condor and rename \verb{.hes}
#' files.
#'
#' @param working.dir local directory containing Hessian subdirectories with
#'        MFCL input files, but not Hessian output files.
#' @param top.dir top directory on Condor submitter machine containing parallel
#'        Hessian computations.
#' @param \dots passed to \code{\link{condor_download}}.
#'
#' @return Remote directory names with the job id as a name attribute.
#'
#' @examples
#' \dontrun{
#' session <- ssh_connect("servername")
#' hessian_download("c:/x/yft/hessian")
#' }
#'
#' @importFrom condor condor_dir condor_download
#'
#' @export

hessian_download <- function(working.dir, top.dir="condor_hessian", ...)
{
  jobs <- condor_dir(top.dir=top.dir)

  # Ensure all jobs are finished
  if(any(jobs$status != "finished"))
  {
    print(jobs)
    stop("all jobs must have status 'finished'")
  }

  for(i in seq_along(nrow(jobs)))
  {
    condor_download(run.dir=jobs$dir[i],
                    local.dir=file.path(working.dir, jobs$dir[i]),
                    top.dir=top.dir, create.dir=TRUE, overwrite=TRUE)
  }

  invisible(jobs)
}
