#' Read Number of Parameters
#'
#' Read the number of estimated parameters from a \file{.par} file.
#'
#' @param parfile name of \file{.par} file to read from.
#'
#' @return Number of parameters as an integer.
#'
#' @seealso
#' \code{\link[FLR4MFCL]{read.MFCLPar}} reads all the information contained in a
#' \file{.par} file, which takes substantially longer.
#'
#' @examples
#' \dontrun{
#' read_npar("10.par")
#' }
#'
#' @export

read_npar <- function(parfile)
{
  txt <- readLines(parfile)
  line <- which(txt == "# The number of parameters") + 1
  npar <- as.integer(txt[line])
  npar
}
