#' Run Infomap for monolayer networks
#'
#' Run Infomap for monolayer networks using an \code{infomap_link_list} class
#' object created with \code{create_infomap_linklist}. Returns the value of the
#' map equation and a tibble with modules that includes additional node metadata
#' (if exists).
#'
#' @param x An object of class \code{infomap_link_list}.
#' @param infomap_executable Name of Infomap standalone file.
#' @param flow_model See details
#'   \href{https://www.mapequation.org/infomap/#ParamsAlgorithm}{here}.
#' @param silent Run in silent mode (argumnt --silent in Infomap).
#' @param trials Number of trials to run (argumnt -N in Infomap).
#' @param two_level Do not use hierarchical partitioning (argumnt -2 in
#'   Infomap). See details.
#' @param seed Seed value for random number generation (argumnt --seed in
#'   Infomap).
#' @param ... additional Infomap arguments as detailed
#'   \href{https://www.mapequation.org/infomap/#Parameters}{here}.
#'
#' @details All of Infomap's arguments are detailed in
#'   \href{https://www.mapequation.org/infomap/#Parameters}{https://www.mapequation.org/infomap/#Parameters}.
#'
#'
#'
#'
#'
#'
#'
#'
#'
#'
#'   Note on hierarchical partitioning: In Infomaps tree output, the \code{path}
#'   column is a tree-like format, like that: 1:3:4:2. The last integer after
#'   the colon indicates the ID of the leaf in the module, and not the ID of the
#'   node. In this example, the node is the 2nd leaf in module 4 which is nested
#'   in module 3 which is nested in module 1. \code{run_infomap_monolayer}
#'   automatically parses this output to levels. In this example, there are 3
#'   module levels and the last is the leaf level. This will create columns:
#'   \code{module_level1, module_level2, module_level3, module_level4}. The
#'   column \code{levels} will show 3 because it ignires the leaf level. In case
#'   a node has fewwer levels because its node is not partitioned, then the
#'   missing levels will show an NA value. Continuing this example, a second
#'   node in the same network with a path 2:1:5 will be the 5th leaf in module 1
#'   of module 2. The values for this node will be: \code{module_level1=2, module_level2=1, module_level3=5, module_level4=NA}.
#'
#' @return A list: \itemize{ \item \code{L} The value of the map equation \item
#'   \code{modules} A tibble with node id, module affiliations and node attributes if they exist. }
#'
#' @seealso \code{create_monolayer_object, monolayer}
#'
#' @export
#' @import dplyr
#' @import magrittr
#' @importFrom readr write_delim read_lines read_delim parse_number
#' @importFrom stringr str_count
#' @importFrom tidyr separate
#'
run_infomap_monolayer <- function(x, infomap_executable='Infomap', flow_model=NULL, silent=F, trials=100, two_level=T, seed=123, ...){
  if(check_infomap(infomap_executable)==F){stop('Error in Infomap standalone file.')}
  if(class(x)!='infomap_link_list'){stop('x must be of class monolayer')}

  # Infomap arguments
  arguments <- paste('--seed ',seed, ' -N ',trials,' -f ',flow_model,sep='')
  arguments <- ifelse(silent, paste(arguments, '--silent'), arguments)
  arguments <- ifelse(two_level, paste(arguments, '--two-level'), arguments)
  arguments <- paste(arguments,...)

 # Write temporary file for Infomap
  write_delim(x$edge_list_infomap, 'infomap.txt', delim = ' ', col_names = F)
  # Run Infomap
  cat('running Infomap:');cat('\n')
  cat(   paste('./',infomap_executable, ' infomap.txt . -i link-list --tree ',arguments,sep=''));cat('\n')
  system(paste('./',infomap_executable, ' infomap.txt . -i link-list --tree ',arguments,sep=''))
  # Get the map equation value, L
  L <- parse_number(read_lines('infomap.tree')[5])
  # Read module results from Infomap
  modules <- suppressMessages(read_delim('infomap.tree', delim = ' ', skip = 7, col_names = c('path', 'flow', 'name', 'node_id')))

  # Get the number of levels. Necessary for hierarchical modularity
  num_levels=max(str_count(modules$path, ':'))
  # Get the modules
  modules %<>%
    select(node_id, path) %>%
    mutate(levels=str_count(path, pattern  = ':') ) %>%
    select(node_id, levels, path) %>%
    separate(path, into=paste('module_level',1:(num_levels+1),sep=''), sep = ':') %>%
    mutate_all(as.integer) %>%
    full_join(x$nodes, 'node_id') %>%
    select(node_id, node_name, levels, starts_with('module_level'), everything()) %>%
    arrange(node_id)

  print('Removing auxilary files...')
  file.remove('infomap.txt')
  file.remove('infomap.tree')

  print(paste('Partitioned into ', max(modules$module_level1),' modules in ',num_levels,' levels.', sep=''))
  return(list(L=L, modules=modules))
}
