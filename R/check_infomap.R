#' Check if Infomap's standalone file is installed.
#'
#' Attempts to run Infomap via the \code{system} command to make sure it works propoerly.
#'
#' @return FALSE and an error if Infomap is not installed correctly. TRUE (and version number) if it is.
#'
#' @examples 
#' check_infomap()
#' 
#' @param x The name of the Infomap executable file.
#' @details For now, this package depends on Infomap's stand-alone version. Futre versions or another package will incorporate Infomap directly into R.
#'
#' @export

check_infomap <- function(x='Infomap'){
    out <- attempt(system(paste('./',x,' -V',sep='')), msg = 'Infomap not installed correctly. See www.mapequation.org for instructions on how to install.')
    if (out==0) {
      return(T)
    } else {
      return(F)
    }
}
