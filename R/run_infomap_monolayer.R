#' Run Infomap for monolayer networks with an option to compare to randomized
#' networks
#'
#' Run Infomap for monolayer networks. Returns the value of the map equation (L)
#' and a tibble with modules that includes additional node metadata (if exists).
#' Can also compare L_obs to that obtained from shuffled versions of the
#' network.
#'
#' @note This is a beta version, that should eventually replace
#'   \code{run_infomap_monolayer}.
#'
#' @param x An object of class \code{monolayer}.
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
#' @param signif Should a comparison for non-random versions of the network be
#'   performed?
#' @param shuff_method Method to shuffle the network. See details.
#' @param nsim How many shuffled networks to create?
#' @details All of Infomap's arguments are detailed in
#'   \href{https://www.mapequation.org/infomap/#Parameters}{https://www.mapequation.org/infomap/#Parameters}.
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
#'   column \code{levels} will show 3 because it ignores the leaf level. In case
#'   a node has fewer levels because its node is not partitioned, then the
#'   missing levels will show an NA value. Continuing this example, a second
#'   node in the same network with a path 2:1:5 will be the 5th leaf in module 1
#'   of module 2. The values for this node will be: \code{module_level1=2,
#'   module_level2=1, module_level3=5, module_level4=NA}.
#'
#'   If significance is \code{TRUE} then the network will be shuffled according
#'   to \code{shuff_method}. \code{shuff_method} can be either a list of already
#'   shuffled networks, produced for example with \code{shuffle_infomap}, or a
#'   shuffling method from \code{vegan::commsim}. Currently only supports
#'   shuffling for bipartite networks from the vegan package as defined in
#'   \code{vegan::commsim}. If special arguments such as burnin or thinin are
#'   needed for shuffling (e.g., for sequential algorithms), then first run
#'   \code{shuffle_infomap} separtely and provide the result as a list to
#'   \code{shuff_method}. This is because the ... argument passes additional
#'   arguments to Infomap, and not to \code{shuffle_infomap}. Significance is
#'   estimate as a 1-tailed test:
#'
#'   P_value = sum(L_sim<L)/nsim
#'
#'   This is the same common method to calculate significance for modularity,
#'   only that the goal is to minimize the map equation.
#'
#'   x is an object of class monolayer that is internally converted to an object of class \code{infomap_link_list}.
#'
#' @return An object of class \code{infomap_monolayer}.
#'
#' @seealso \code{create_monolayer_object, monolayer, shuffle_infomap, infomap_monolayer}
#'
#' @export
#' @import dplyr
#' @import magrittr
#' @importFrom readr write_delim read_lines read_delim parse_number
#' @importFrom stringr str_count
#' @importFrom tidyr separate
#'   
run_infomap_monolayer <- function(x, infomap_executable='Infomap', flow_model=NULL, silent=F, trials=100, two_level=T, seed=123, signif=F, shuff_method=NULL, nsim=1000, verbose=T, ...){
  
  # Check stuff and prepare
  if(check_infomap(infomap_executable)==F){stop('Error in Infomap standalone file.')}
  if(class(x)!='monolayer'){stop('x must be of class monolayer')}
  if (verbose){ print('Creating a link list...') }
  obs <- create_infomap_linklist(x) # obs = Observed network
  nodes <- x$nodes
  
  # Run Infomap for observed
  
  # Infomap arguments
  arguments <- paste('--seed ',seed, ' -N ',trials,' -f ',flow_model,sep='')
  arguments <- ifelse(silent, paste(arguments, '--silent'), arguments)
  arguments <- ifelse(two_level, paste(arguments, '--two-level'), arguments)
  arguments <- paste(arguments,...)
  call <- paste('./',infomap_executable, ' infomap.txt . -i link-list --tree ',arguments,sep='')
  
  # Write temporary file for Infomap
  write_delim(obs$edge_list_infomap, 'infomap.txt', delim = ' ', col_names = F)
  # Run Infomap
  if (verbose){ cat('running: ');cat(call);cat('\n') }
  system(call)
  tmp <- str_split(read_lines('infomap.tree')[5], 'levels')
  num_levels <- parse_number(tmp[[1]][1]) # Get number of levels
  m <- parse_number(tmp[[1]][2]) # Get number of modules
  L <- parse_number(read_lines('infomap.tree')[6]) # Get the map equation value, L
  # Read module results from Infomap
  modules <- suppressMessages(read_delim('infomap.tree', delim = ' ', skip = 8, col_names = c('path', 'flow', 'name', 'node_id')))
  # Get the modules
  suppressWarnings( # Need to suppress warnings because with hierarchical modules there are NA generated.
    modules %<>%
      select(node_id, path) %>%
      mutate(levels=str_count(path, pattern  = ':') ) %>%
      select(node_id, levels, path) %>%
      separate(path, into=paste('module_level',1:(num_levels+1),sep=''), sep = ':') %>%
      mutate_all(as.integer) %>%
      full_join(obs$nodes, 'node_id') %>%
      select(node_id, node_name, levels, starts_with('module_level'), everything()) %>%
      arrange(node_id)
  )
  # Prepare first output, before significance testing
  out <- list(call=call, L=L, m=m, modules=modules, edge_list=x$edge_list, L_sim=NULL, m_sim=NULL, pvalue=NULL)
  
  if (signif){
    if(class(x)!='monolayer'){stop('x must be of class monolayer to test for non-random patterns.')}
    
    if (class(shuff_method)=='list'){
      shuffled_linklist <- shuff_method # If list with shulled networks is provided.
      nsim <- length(shuffled_linklist)
    } else { 
      shuffled_linklist <- shuffle_infomap(x, shuff_method=shuff_method, nsim=nsim) # Otherwise, shuffle according to arguments.
    }
    # Run Infomap for shuffled
    L_sim <- m_sim <- NULL
    for (i in 1:nsim){
      write_delim(shuffled_linklist[[i]], 'infomap.txt', delim = ' ', col_names = F) # Write temporary file for Infomap
      if (verbose){ print(paste('Running Infomap on shuffled network ',i,'/',nsim,sep=''))}
      system(call) # Run Infomap
      L_sim <- c(L_sim, parse_number(read_lines('infomap.tree')[6])) # Get the map equation value, L
      m_sim <- c(m_sim, parse_number(str_split(read_lines('infomap.tree')[5], 'levels')[[1]][2])) # Get number of modules
    }
    
    out$L_sim <- L_sim
    out$m_sim <- m_sim
    out$pvalue <- sum(L_sim<L)/nsim 
    if(out$pvalue==0){warning(paste('pvalue is not really 0, it is <',1/nsim,sep=''))}
  }
  
  if (verbose){ print('Removing auxilary files...') }
  file.remove('infomap.txt')
  file.remove('infomap.tree')
  
  class(out) <- 'infomap_monolayer'
  return(out)
}
