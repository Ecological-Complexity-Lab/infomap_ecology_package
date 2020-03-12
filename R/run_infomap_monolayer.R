#' Run Infomap for monolayer networks
#'
#' Run Infomap for monolayer networks using a \code{monolayer} class object, or
#' using an external file. Returns the value of the map equation and a tibble
#' with modules, If using a \code{monolayer} object, also returns a tibble with
#' module affiliations that includes additional node metadata (if exists).
#'
#' @param x A monolayer object. Ignored if an input file is provided.
#' @param infomap_executable Name of Infomap standalone file (default is Infomap).
#' @param input_file Name of an external input file. Overrides x
#' @param flow_model See details in https://www.mapequation.org/infomap/#ParamsAlgorithm.
#' @param silent Run in silent mode (argumnt --silent in Infomap)
#' @param trials Number of trials to run (argumnt -N in Infomap)
#' @param two_level Do not use hierarchical partitioning (argumnt -2 in Infomap)
#' @param seed Seed value for random number generation (argumnt --seed in Infomap)
#' @param ... additional Infomap arguments as detailed in https://www.mapequation.org/infomap/#Parameters.
#'
#' @return A list:
#' \itemize{
#'   \item \code{L} The value of the map equation
#'   \item \code{modules} A tibble with node IDs. For each node, the number of module levels (e.g., 2 levels if it belongs to module 3 within module 2), and module affiliation, by levels.
#'   \item \code{module_affiliation} A tibble with node id, name, module affiliations and node attributes (metadata).
#' }
#' @seealso \code{create_network_object, monolayer}
#'
#'
#' @export
#' @import dplyr
#' @import magrittr
#' @importFrom readr write_delim read_lines read_delim parse_number
#' @importFrom stringr str_count
#' @importFrom tidyr separate
#'
run_infomap_monolayer <- function(x, infomap_executable='Infomap', input_file=NULL, flow_model=NULL, silent=F, trials=20, two_level=T, seed=123, ...){
  if(check_infomap(infomap_executable)==F){stop('Error in Infomap')}
  if(class(x)!='infomap_link_list'){stop('x must be of class monolayer')}

  # Infomap arguments
  arguments <- paste('--seed ',seed, ' -N ',trials,' -f ',flow_model,sep='')
  arguments <- ifelse(silent, paste(arguments, '--silent'), arguments)
  arguments <- ifelse(two_level, paste(arguments, '--two-level'), arguments)
  arguments <- paste(arguments,...)

  # If an input file is provided:
  if(!is.null(input_file)){
    cat('running Infomap:');cat('\n')
    cat(paste('./',infomap_executable,' ',input_file,' . -i link-list --tree ',arguments,sep=''));cat('\n')
    system(paste('./',infomap_executable,' ',input_file,' . -i link-list --tree ',arguments,sep=''))
    L_output <- read_lines(paste(str_split(input_file,'\\.')[[1]][1],'.tree',sep=''))[5] # Get the map equation value, L
    # Read module results from Infomap
    modules <- suppressMessages(read_delim(paste(str_split(input_file,'\\.')[[1]][1],'.tree',sep=''), delim = ' ', skip = 7, col_names = c('path', 'flow', 'name', 'node_id')))
  } else {
    # Write file for Infomap
    write_delim(x$edge_list_infomap, 'infomap.txt', delim = ' ', col_names = F)
    # Run Infomap
    cat('running Infomap:');cat('\n')
    cat(paste('./',infomap_executable, ' infomap.txt . -i link-list --out-name infomap_out --tree ',arguments,sep=''));cat('\n')
    system(paste('./',infomap_executable, ' infomap.txt . -i link-list --out-name infomap_out --tree ',arguments,sep=''))
    # Get the map equation value, L
    L_output <- read_lines('infomap_out.tree')[5]
    # Read module results from Infomap
    modules <- suppressMessages(read_delim('infomap_out.tree', delim = ' ', skip = 7, col_names = c('path', 'flow', 'name', 'node_id')))
  }
  print(L_output)
  L <- parse_number(L_output)
  # Get the number of levels. Especially necessary for hierarchical modularity
  num_levels=max(str_count(modules$path, ':'))
  # Get the modules
  modules %<>%
    select(node_id, path) %>%
    mutate(levels=str_count(path, pattern  = ':') ) %>%
    select(node_id, levels, path) %>%
    separate(path, into=paste('module_level',1:(num_levels+1),sep=''), sep = ':') %>%
    mutate_all(as.integer)
  # mutate_at(vars(starts_with("module_level")), as.integer) # convert to an integer instead of  cahracter

  if (is.null(input_file)){
    suppressMessages(
      module_affiliation <- x$nodes %>%
        inner_join(modules) %>%
        select(node_id, node_name, starts_with('module_level'), everything(), -levels) %>%
        arrange(node_id)
    )
  } else {
    module_affiliation <- NULL
  }
  print(paste('Partitioned into ', max(modules$module_level1),' modules in ',num_levels,' levels.', sep=''))
  return(list(L=L, modules=modules, module_affiliation=module_affiliation))
}
