#' Run Infomap for multilayer networks
#'
#' Run Infomap for multilayer networks using a \code{multilayer} class object.
#' Returns the value of the map equation and a tibble with module affiliations
#' that includes additional node metadata (if exists).
#'
#' @param M An object of class \code{multilayer}.
#' @param infomap_executable Name of Infomap standalone file (default is
#'   Infomap).
#' @param flow_model See details in
#'   \href{https://www.mapequation.org/infomap/#ParamsAlgorithm}{https://www.mapequation.org/infomap/#ParamsAlgorithm}.
#' @param silent Run in silent mode (argumnt --silent in Infomap).
#' @param trials Number of trials to run (argumnt -N in Infomap).
#' @param seed Seed value for random number generation (argumnt --seed in
#'   Infomap).
#' @param relax Should dynamics of movement between layers be fully encoded by
#'   interlayer edges, or should they be relaxed. See details.
#' @param multilayer_relax_rate Probability to relax the constraint to move only
#'   in the current layer.
#' @param multilayer_relax_limit Number of neighboring layers in each direction
#'   to relax to. If negative, relax to any layer.
#' @param multilayer_relax_limit_up Number of neighboring layers with higher id
#'   to relax to. If negative, relax to any layer. Useful for temporal networks.
#' @param multilayer_relax_limit_down Number of neighboring layers with lower id
#'   to relax to. If negative, relax to any layer. Useful for temporal networks.
#' @param temporal_network Is this a temporal network? See details.
#' @param run_standalone Should the function run Infomap's stand-alone file? Defaults to true. See details.
#' @param remove_auxilary_files Should auxilary files be removed when finished running?
#' @param ... additional Infomap arguments as detailed in
#'   \href{https://www.mapequation.org/infomap/#Parameters}{https://www.mapequation.org/infomap/#Parameters}
#'
#' @details Currently only works with two-level solutions (no modules within
#'   modules).
#'
#'   When relax=F, Infomap uses an input format that gives full control of the
#'   dynamics, explicitly using interlayer edges, and no other movements are
#'   encoded. This uses the extended edge list format and you have to specify
#'   all intra-layer and inter-layer links explicitly.
#'
#'   However, it is often useful to consider a dynamics in which a random walker
#'   moves within a layer and with a given relax rate jumps to another layer
#'   without recording this movement, such that the constraints from moving in
#'   different layers can be gradually relaxed. This is obtained with a
#'   different input format that explicitly divides the links into intra-layer
#'   and inter-layer links. To use relaxation, you only specify intralayer edges
#'   (use `intra_output_extended=F` in `create_multilayer_object`) and the links
#'   between layers are generated automatically by inter-layer relaxation
#'   (parameter `multilayer-relax-rate`). Relaxing between layers can also be
#'   constraied by interlayer links. For this, include interlayer links and set
#'   `inter_output_extended=F` in `create_multilayer_object`. Relaxing requires
#'   specification of relax rates and limits. When these are not specified,
#'   Infomap uses defaults as detailed
#'   \href{https://www.mapequation.org/infomap/#Parameters}{here}.
#'
#'   If the multilayer is a temporal network, modules can be renamed to be
#'   placed in temporal order of appearance. This is done with
#'   \code{temporal_network=T}.
#'   
#'   \code{run_standalone}: Infomap is run as a stand-alone file. On some machines, especially Windows, it is impossible to install 
#'   that file or it gives an error. In that case you can use the auxilary file produced by the function, called
#'   \code{infomap_multilayer.txt} to run Infomap online, download the results and parse them back. 
#'   The function will wait to parse the results.
#'
#' @return An object of class \code{infomap_multilayer}
#'
#' @seealso \code{create_multilayer_object, multilayer, infomap_multilayer}
#'
#' @export
#'
#' @examples
#'  # Examples are available on the our website 
#'  # https://ecological-complexity-lab.github.io/infomap_ecology_package/multilayer_relax_emln.html
#' 
#'
## @import dplyr
## @import magrittr
## @importFrom readr write_delim read_lines read_delim parse_number
## @importFrom stringr str_count
## @importFrom tidyr separate
#'   
run_infomap_multilayer <- function(M,
                                   infomap_executable='Infomap',
                                   flow_model=NULL,
                                   silent=T,
                                   trials=100,
                                   seed=NULL,
                                   relax=F,
                                   multilayer_relax_rate=0.1,
                                   multilayer_relax_limit=NULL,
                                   multilayer_relax_limit_up=NULL,
                                   multilayer_relax_limit_down=NULL,
                                   temporal_network=F,
                                   run_standalone=T,
                                   remove_auxilary_files=T,
                                   ...){
  #infomap_ecology_v2
  # Check if there are interlayer links
  if (!"inter" %in% names(M)){
  if (any(M$extended_ids$layer_from != M$extended_ids$layer_to) && relax == FALSE) {
    # Create a sub-dataframe 'inter' with interlayer links
    M$inter <- as.data.frame(M$extended_ids[M$extended_ids$layer_from != M$extended_ids$layer_to, ])
    M$inter <- as.tbl(M$inter)
    M$inter <- M$inter %>% mutate_all(as.numeric)}
  } else {
    # Set 'inter' to NULL if there are no interlayer links
    inter <- NULL
  }
  
  
  # Create a sub-dataframe 'intra' with intralayer links and change column name
  intra <- NULL
  if (!"intra" %in% names(M) && relax == T) {
  intra <- M$extended_ids[M$extended_ids$layer_from == M$extended_ids$layer_to, c("layer_from", "node_from", "node_to", "weight")]
  colnames(intra)[1] <- "layer"
  } else if (!"intra" %in% names(M) && relax == F){
    intra <- M$extended_ids[M$extended_ids$layer_from == M$extended_ids$layer_to & as.numeric(M$extended_ids$weight) != 0, ]
  }
  
  if (!is.null(intra)) {
    M$intra <- as.data.frame(intra)
    M$intra <- M$intra %>% as.tbl() %>% mutate_all(as.numeric)
  }
  
  ### END infomap_ecology_v2
  
  if(check_infomap(infomap_executable)==F){stop('Error in Infomap stand-alone file.')}
  if(class(M)!='multilayer'){stop('M must be of class multilayer')}

  # Infomap arguments
  arguments <- paste('--tree -2 -N ',trials, sep='')
  arguments <- ifelse(!is.null(seed), paste(arguments, '--seed',seed), arguments)
  arguments <- ifelse(!is.null(flow_model), paste(arguments, '-f',flow_model), arguments)
  arguments <- ifelse(silent, paste(arguments, '--silent'), arguments)
  arguments <- paste(arguments,...)

  # If using interlayer edges to determine flow
  if (relax==F){
    print('Using interlayer edge values to determine flow between layers.')
    # Write file for Infomap
    write_lines('*Multilayer', 'infomap_multilayer.txt')
    write_delim(M$intra, 'infomap_multilayer.txt', delim = ' ', append = T)
    write_delim(M$inter, 'infomap_multilayer.txt', delim = ' ', append = T)
  } else { # If using relax rates
    if (ncol(M$intra)==5){stop('Cannot use relax rates with extended format of intralayer edges. See function create_multilayer_object.')}
    print('Using global relax to determine flow between layers.')
    # Write file for Infomap
    write_lines('*Intra', 'infomap_multilayer.txt')
    write_delim(M$intra, 'infomap_multilayer.txt', delim = ' ', append = T)
    if(!is.null(M$inter)){
      if (ncol(M$inter)==5){stop('Cannot use relax rates with extended format of interlayer edges. See function create_multilayer_object.')}
      print('Global relax will be constrained by interlayer edges.')
      write_lines('*Inter', 'infomap_multilayer.txt', append = T)
      write_delim(M$inter, 'infomap_multilayer.txt', delim = ' ', append = T)
    }
    # Add arguments for relax rates and limits
    arguments <- ifelse(!is.null(multilayer_relax_rate), paste(arguments, '--multilayer-relax-rate',multilayer_relax_rate), arguments)
    arguments <- ifelse(!is.null(multilayer_relax_limit), paste(arguments, '--multilayer-relax-limit',multilayer_relax_limit), arguments)
    arguments <- ifelse(!is.null(multilayer_relax_limit_up), paste(arguments, '--multilayer-relax-limit-up',multilayer_relax_limit_up), arguments)
    arguments <- ifelse(!is.null(multilayer_relax_limit_down), paste(arguments, '--multilayer-relax-limit-down',multilayer_relax_limit_down), arguments)
  }
  
  # Run Infomap
  call <- paste('./',infomap_executable,' infomap_multilayer.txt . ', arguments, sep='')
  
  # If running within R
  if (run_standalone==T){
    print(call)
    system(call)
  } else {
    print('Please run Infomap online at https://www.mapequation.org/infomap/ using the following arguments (copy-paste):')
    print(arguments)
    invisible(readline(prompt="After running, download statenodes results and press [ENTER] when done"))
    if (!file.exists('network_states.tree')){stop('Result file network_states.tree was not found. Did you download results?')}
    file.rename(from = 'network_states.tree', to = 'infomap_multilayer_states.tree')
  }
  # Get L
  L_output <- parse_number(read_lines('infomap_multilayer_states.tree')[6])
  #Read infomap's output file
  modules <- suppressMessages(read_delim('infomap_multilayer_states.tree', delim = ' ', skip = 11, col_names = c('path', 'flow', 'name', 'state_id', 'node_id', 'layer_id')))
  # Parse modules
  modules %<>% 
    filter(flow > 0) %>%
    select(path, node_id, layer_id, flow) %>%
    separate(path, into = c("module", "leaf_id"), sep = ":") %>% 
    mutate_at(.vars = 1:4, as.integer) %>% 
    full_join(M$nodes, "node_id") %>% 
    select(node_id, starts_with("module"),  everything(), -leaf_id) %>% 
    arrange(node_id, layer_id)
  
  ### infomap_ecology_v2
  if (any(is.na(modules$module))) {
    print ('No modules were assigned nodes that lacked flow: ')
    print (modules[is.na(modules$module), c("node_id", "node_name")])
    #delete rows with NA values in the modules$module 
    modules <- modules[!is.na(modules$module), ]
    }
  ### END infomap_ecology_v2
  
  # For temporal networks, need to rename modules to be in a temporal order
  # because Infomap gives names by flow and not by order of appearence.
  if (temporal_network){
    print('Reorganizing modules...')
    renamed_moduels <- modules %>%
      distinct(module,layer_id) %>%
      arrange(module,layer_id)
    x <- c(1,table(renamed_moduels$module))
    module_birth_layers <- renamed_moduels %>% slice(cumsum(x)) %>% arrange(layer_id,module)
    module_renaming <- data.frame(module=module_birth_layers$module, module_renamed = 1:max(module_birth_layers$module))
    modules %<>%
      left_join(module_renaming, 'module') %>%
      select(-module) %>%
      rename(module=module_renamed)
  }
  
  if (remove_auxilary_files){
    print('Removing auxilary files...')
    file.remove('infomap_multilayer_states.tree')
    file.remove('infomap_multilayer.txt')
    file.remove('infomap_multilayer.tree')
  }
  # Output
  print(paste('Partitioned into ', max(modules$module),' modules.', sep=''))
  out <- list(call=call, L=L_output, m=max(modules$module), modules=modules)
  class(out) <- 'infomap_multilayer'
  return(out)
}

