#' Adjacency matrix to edge list conversion
#'
#' Convert an adjacency matrix to an edge list.
#'
#' @details Assigns column and row names if those do not exist. Cannot handle node attributes/metadata.
#'
#' @param x An adjacency or incidence matrix.
#' @param directed Is the network directed?
#'
#' @return A \code{monolayer} object
#'
#' @seealso \code{create_monolayer_object, monolayer}
#'
#' @examples 
#' # Generate a matrix with radnom weighted interactions
#' x <- matrix(rbinom(100,1,0.6),10,10)
#' x <- x*round(runif(100,1,5),0)
#' # run
#' matrix_to_list_unipartite(x, directed = T)
#' 
#' @export
## @import dplyr
## @importFrom igraph is.directed graph.adjacency degree
## @import magrittr

matrix_to_list_unipartite <- function(x, directed){
  # Assign column and row names if missing
  if (is.null(rownames(x)) && is.null(colnames(x))) {print('Assigning missing row and column names'); rownames(x) <- colnames(x) <- paste('X',1:nrow(x),sep='')}
  if (is.null(rownames(x)) && !is.null(colnames(x))) {print('Rows renamed as columns'); rownames(x) <- colnames(x)}
  if (!is.null(rownames(x)) && is.null(colnames(x))) {print('Columns renamed as rows'); colnames(x) <- rownames(x)}
  # Or make sure they are identical
  if(!identical(rownames(x),colnames(x))){message('Rows and columns do not have the same names or are not in the same order! Proceed with caution!')}

  g <- graph.adjacency(t(x), weighted = T, mode = ifelse(directed, 'directed','undirected')) # For some reason igraph considers the from to be ther rows. Need to transpose the matrix
  # summary(g)
  if(any(igraph::degree(g)==0)){print('Some nodes have no interactions. They will appear in the node table but not in the edge list')}
  l_unip <- as_tibble(igraph::as_data_frame(g, 'edges'))

  nodes <- rownames(x)
  node_list <- tibble(node_id=1:length(nodes),node_name=nodes)
  out <- list(mode='U', directed=igraph::is.directed(g), nodes=node_list, mat=x, edge_list=l_unip, igraph_object=g)
  class(out) <- "monolayer"
  return(out)
}
