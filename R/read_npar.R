#' Read Number of Parameters
#'
#' Read the number of estimated parameters from a \file{.par} file.
#'
#' @param parfile name of \file{.par} file to read from.
#'
#' @return Number of parameters as an integer.
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