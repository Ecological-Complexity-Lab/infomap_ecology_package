#' Check if Infomap's standalone file is installed.
#'
#' Attempts to run Infomap via the \code{system} command.
#'
#' @return An error if Infomap is not installed correctly, or version number of it is.
#'
#' @details For now, this package depends on Infomap's stand-alone version. We are working on incorporating Infomap directly into the package.
#'
#' @importFrom attempt attempt
#' @export

check_infomap <- function(x='Infomap'){
    out <- attempt(system(paste('./',x,' -V',sep='')), msg = 'Infomap not installed correctly. See www.mapequation.org for instructions on how to install.')
    if (out==0) {
      return(T)
    } else {
      return(F)
    }
}
