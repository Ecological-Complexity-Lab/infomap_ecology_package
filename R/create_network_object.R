#' Convert between edge lists and matrices for monolayer networks
#'
#' Automatically identifies if the input is a matrix or edge list and creates a \code{monolayer} object.
#' A wrapper function for \code{list_to_matrix, matrix_to_list}
#'
#' @param x An input list or matrix that must have node names.
#' @param directed is the network directed
#' @param bipartite is network bipartite
#' @param group_names for bipartite networks: name of the groups in the columns and rows (e.g., parasites and hosts)
#' @param node_metadata Following the igraph method of \code{graph.data.frame}. Must have a column called node_name with names matching those in x.
#' @return A \code{monolayer} object
#' @seealso \code{list_to_matrix, matrix_to_list, monolayer}
#'
#' @export
#' @import dplyr
#' @importFrom igraph graph.incidence V
#' @import magrittr

# x is  node_metadata must
#
create_network_object <- function(x, directed=NULL, bipartite=NULL, group_names=c('set_cols','set_rows'), node_metadata=NULL){
  if ('matrix'%in%class(x) & bipartite){
    print('Input: a bipartite matrix')
    out <- matrix_to_list_bipartite(x, group_names = group_names)
  }
  if ('matrix'%in%class(x) & !bipartite){
    print('Input: an unipartite matrix')
    out <- matrix_to_list_unipartite(x, directed = directed)
  }
  if (!'matrix'%in%class(x)){
    if (bipartite){print('Input: a bipartite edge list')}
    if (!bipartite){print('Input: an unipartite edge list')}
    out <- list_to_matrix(x, directed, bipartite, group_names, node_metadata = node_metadata)
  }
  if (!is.null(node_metadata)){
    out$nodes %<>% left_join(node_metadata)
  }
  return(out)
}
