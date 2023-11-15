#' A wrapper to install Infomap's standalone file.
#'
#' Downloads the latest binary release version from MapEquation according to the 
#' machine's operating system (Windows/MacOS/Linux). Unix based OS users have 
#' the option to download the latest version in development from the git. 
#' In that case it clones the GitHub repository and runs \code{make} via R's
#' \code{system} command. This is merely a wrapper for commands that can be 
#' easily run in the terminal.
#
#' @param target_folder Where to install Infomap. Defaults to R's current
#'   working directory (\code{getwd()}). 
#'   Note: avoid using special characters or spaces in the folder's path.
#'
#' @param source The source to download Infomap from. Relevant only for Unix based operating systems.
#'  "git" to download the latest version from development, 
#'  "binary" (default) to download the latest release version. 
#'  
#' @return FALSE and an error if Infomap is not installed correctly. TRUE (and
#'   version number) if it is.
#'
#' @details For now, this package depends on Infomap's stand-alone version.
#'   Future versions or another package will incorporate Infomap directly into R. 
#'   Therefore it is necessary to install infomap, in the same folder where the code is Run. 
#'   If it is already installed, then it will be replaced by the newest version.
#'   For full instructions see \href{https://ecological-complexity-lab.github.io/infomap_ecology_package/installation}{here}
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
    return(check_infomap('Infomap'))
  }
  
  # ------ function body ------
  # validate path and set it as wd
  oldwd <- getwd()
  if (is.null(target_folder)) {target_folder <- getwd()
  }else if (dir.exists(target_folder)) {setwd(target_folder)
  }else{
    warning("Invalid directory name.")
    return(F)
  }
  
  unlink("Infomap.zip")
  unlink("Infomap")
  source_url <- "https://github.com/mapequation/infomap/releases/download/v2.7.1/"
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
    } else if (source=='git') {
      res <- install_from_github(target_folder)
      setwd(oldwd)
      return(res)
    } else{
      print("Invalid Infomap source. See description for more details.")
      setwd(oldwd)
      return(F)
    }
  }
  
  url <- paste(source_url, file_name, sep = "")
  destfile <- paste(target_folder, "/Infomap.zip", sep = "")
  download.file(url, destfile)
  
  # unzip downloaded file
  if (os=="windows") {
    unzip(destfile, overwrite = TRUE)
  } else { # this is a unix based os
    # unzip the infomap file 
    # (using the unzip function doesnt prepuce the right permissions to run the exec)
    attempt(system(paste("unzip -o ", destfile, sep="")), 
            msg = "unzip using commandline failed")
  }
  unlink("Infomap.zip")

  # attempt to run infomap, if it doesnt work, download no omp version
  is_working <- check_infomap()

  if (is_working) {
    # return to the previous directory
    setwd(oldwd)
    return(TRUE)
  } else {
    print("OpenMP Infomap check was unsuccessfull. Downloading no OpenMP Infomap.")
    name_parts <- unlist(str_split(file_name, "\\."))
    file_name_new <- paste(name_parts[1], "-noomp.", name_parts[2], sep = "")
    url_noomp <- paste(source_url, file_name_new, sep = "")
    download.file(url_noomp, destfile)
    attempt(system(paste("unzip -o ", destfile, sep="")),
            msg = "unzip using commandline failed")
    is_working <- check_infomap()
    # return to the previous directory
    setwd(oldwd)
    if (is_working) {
      warning("Warning: No OpenMP Infomap version was installed. 
          This restricts parallel processing. For more information see https://www.mapequation.org/infomap/#Install.")
      return(TRUE)
    } else {
      warning("Infomap not installed correctly. 
          See https://www.mapequation.org/infomap/#Install. for instructions on how to install.")
      return(FALSE)
    }
  }
}
