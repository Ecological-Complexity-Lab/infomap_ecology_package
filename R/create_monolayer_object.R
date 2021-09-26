#' Creates a monolayer network object.
#'
#' Automatically identifies if the input is a matrix or an edge list and creates
#' a \code{monolayer} object.
#'
#' @param x input data in the format of a matrix, edge list or an igraph object.
#' @param directed Is the network directed?
#' @param bipartite Is the network bipartite? Ignored when the input is an igraph object.
#' @param group_names For bipartite networks: name of the groups in the columns
#'   and rows, respectively (e.g., parasites and hosts).
#' @param node_metadata Following the igraph method of \code{graph.data.frame}.
#'   Must have a column called node_name with names matching those in x.
#'
#' @return A \code{monolayer} object.
#'
#' @seealso \code{list_to_matrix, matrix_to_list_unipartite,
#'   , monolayer}. Also functions \code{graph.incidence,
#'   graph.adjacency, graph.data.frame} in the \code{igraph} package.
#'
#' @details Converts between edge list and matrix formats and creates a
#'   monolayer object. It a wrapper function for
#'   \code{list_to_matrix, matrix_to_list_unipartite, matrix_to_list_bipartite}. Node metadata can only be included with an edge list input.
#'
#' @examples
#' # A bipartite network from package bipartte
#' x <- create_monolayer_object(bipartite::memmott1999, bipartite = TRUE, 
#' directed = FALSE, group_names = c('Animals','Plants'))
#' 
#' # A bipartite network as an igraph object
#' 
#' # Generate a random bipartite network in igraph
#' g <- igraph::sample_bipartite(10,16,p=0.3, type = 'gnp', directed = TRUE, mode = 'in') 
#' V(g)$name <- letters # name the nodes
#' V(g)$gender <- sample(c('F','M'), size = 26, replace = TRUE) # Add a node attribute
#' E(g)$weight=runif(ecount(g)) # Add edge weights
#' plot(g, layout=layout.bipartite)
#' create_monolayer_object(g, group_names = c('Parasites','Hosts'))
#'
#'
#'
#'
#' @export
## @import dplyr
## @importFrom igraph graph.incidence V
## @import magrittr
create_monolayer_object <- function(x, directed=NULL, bipartite=NULL, group_names=c('set_cols','set_rows'), node_metadata=NULL){
  
  # Input is a matrix
  if ('matrix'%in%class(x)){
    if(bipartite){
      print('Input: a bipartite matrix')
      out <- matrix_to_list_bipartite(x, group_names = group_names)
    } else {
      out <- matrix_to_list_unipartite(x, directed = directed)
    }
  }
  
  # Input is an edge list
  if ('data.frame'%in%class(x)){
    if (bipartite){print('Input: a bipartite edge list')}
    if (!bipartite){print('Input: an unipartite edge list')}
    out <- list_to_matrix(x, directed, bipartite, group_names, node_metadata = node_metadata)
  }
  
  # Input is an igrpah object
  if('igraph'%in%class(x)){
    print('Input: an igraph object:')
    print(x)
    g <- x
    mode <- ifelse(is.bipartite(g),'B','U')
    
    node_list <- igraph::as_data_frame(g, what = 'vertices') %>%
      mutate(node_id=1:vcount(g)) %>% 
      rename(node_name=name) %>% 
      select(node_id, node_name, everything())
    
    if(mode=='B'){
      node_list$node_group <- NA
      node_list$node_group[node_list$type==T] <- group_names[1]
      node_list$node_group[node_list$type==F] <- group_names[2]
      mat <- igraph::as_incidence_matrix(g,names = T, attr = 'weight', sparse = F)
    } else {
      mat <- igraph::as_adjacency_matrix(g, type = 'both', attr = 'weight', sparse = F)
    }
    
    out <- list(mode=mode,
                directed=is.directed(g),
                nodes=node_list,
                mat= mat, 
                edge_list=as_tibble(igraph::as_data_frame(g, 'edges')), 
                igraph_object=g)
  }
  
  # Add additional node attributes
  if (!is.null(node_metadata)){
    out$nodes %<>% left_join(node_metadata)
  }
  # Create an edge list with IDs instead of node names
  out$edge_list_ids <- 
    out$edge_list %>% 
    left_join(out$nodes, by=c('from' = 'node_name')) %>%  
    left_join(out$nodes, by=c('to' = 'node_name')) %>%  
    dplyr::select(-from, -to) %>% 
    dplyr::select(from=node_id.x, to=node_id.y, weight)
  return(out)
}
