#' A wrapper to install Infomap's standalone file.
#'
#' Clones the GitHub repository and runs \code{make} via R's \code{system}
#' command. This is merely a wrapper for commands that can be easily run in the
#' terminal.
#'
#' @param target_folder Where to install infomap. Defaults to R's current
#'   working directory (\code{getwd()}).
#'
#' @return FALSE and an error if Infomap is not installed correctly. TRUE (and
#'   version number) if it is.
#'
#' @details For now, this package depends on Infomap's stand-alone version.
#'   Futre versions or another package will incorporate Infomap directly into R. Therefore it is necessary to install infomap, in the same folder where the code is Run. If it is already installed, then it will be replaced by the newest version.
#'   
#' @examples
#' \dontrun{
#' install_infomap()
#' }
#' 
#' @export
install_infomap <- function(target_folder=NULL){
  unlink('Infomap')
  if (is.null(target_folder)){target_folder <- getwd()}
  setwd(target_folder)
  system('git clone https://github.com/mapequation/infomap.git')
  setwd(paste(getwd(),'/infomap',sep=''))
  message ('Running make...')
  system('make')
  file.copy(from = 'Infomap', to = paste(target_folder,'/Infomap_f',sep=''), overwrite = T)
  setwd(target_folder)
  message('Finishing...')
  system('rm -rf infomap')
  file.rename('Infomap_f', 'Infomap')

  # Check installation
  out <- attempt(system('./Infomap -V'), msg = 'Infomap not installed correctly. See www.mapequation.org for instructions on how to install.')
  if (out==0) {
    return(T)
  } else {
    return(F)
  }
}
