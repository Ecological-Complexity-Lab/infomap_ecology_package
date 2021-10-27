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
## @import attempt
## @import stringr
install_infomap <- function(target_folder=NULL, source="binary"){

  # -------Auxilary functions----
  get_os <- function(){
    sysinf <- Sys.info()
    if (!is.null(sysinf)){
      os <- sysinf['sysname']
      if (os == 'Darwin') # macOS is called Darwin due to legacy reasons
        os <- "osx"
    } else { ## mystery machine that doesn't implement Sys.info()
      os <- .Platform$OS.type
      if (grepl("^darwin", R.version$os))
        os <- "osx"
      if (grepl("linux-gnu", R.version$os))
        os <- "linux"
    }
    tolower(os)
  }
  install_from_github <- function(target_folder){
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
  
  # 'source' can be one of the following = c('git','binary')
  unlink("Infomap.zip")
  unlink("Infomap")
  source_url <- "https://github.com/mapequation/infomap/releases/download/v1.7.1/" 
  os <- get_os()
  
  #get file name by OS
  if (os=="windows") {
    file_name <- "infomap-win.zip"
  } else { 
    if (source=='binary') {
      if (os=="osx") {
        file_name <- "infomap-mac.zip"
      } else if (os=="linux") {
        file_name <- "infomap-ubuntu.zip" # need to check that it works
      }
    } else {
      return(infomapecology::install_infomap())
    }
  }
  
  url <- paste(source_url, file_name, sep = "")
  destfile <- paste(getwd(), "/Infomap.zip", sep = "")
  download.file(url, destfile)
  
  # unzip downloaded file
  if (os=="windows") {
    unzip(destfile, overwrite = TRUE)
  } else { # this is a unix based os
    # unzip the infomap file 
    # (using the unzip function doesnt prepuce the right permissions to run the exec)
    attempt(system("unzip -o Infomap.zip"), 
            msg = "unzip using commandline failed")
  }
  
  # attempt to run infomap, if it doesnt work, download no omp version
  is_working <- infomapecology::check_infomap()
  if (is_working) {
    return(TRUE)
  } else {
    print("OpenMP Infomap check was unsuccessfull. Downloading no OpenMP Infomap.")
    name_parts <- unlist(str_split(file_name, "\\."))
    file_name_new <- paste(name_parts[1], "-noomp.", name_parts[2], sep = "")
    url_new <- paste(source_url, file_name_new, sep = "")
    download.file(url, destfile)
    attempt(system(paste("unzip -o Infomap.zip", sep = "")),
            msg = "unzip using commandline failed")
    is_working <- infomapecology::check_infomap()
    if (is_working) {
      print("Warning: No omp infomap version was installed. 
          This restricts parallel processing. For more information see https://www.mapequation.org/infomap/#Install.")
      return(TRUE)
    } else {
      print("Infomap not installed correctly. 
          See https://www.mapequation.org/infomap/#Install. for instructions on how to install.")
      return(FALSE)
    }
  }
  
}
