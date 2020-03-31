#' Creates a monolayer network object.
#'
#' Automatically identifies if the input is a matrix or an edge list and creates
#' a \code{monolayer} object.
#'
#' @param x An input list or matrix that must have node names.
#' @param directed Is the network directed?
#' @param bipartite Is the network bipartite?
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
#' x <- create_monolayer_object(memmott1999, bipartite = T, directed = F, group_names = c('A','P'))
#' 
#' @export
#' @import dplyr
#' @importFrom igraph graph.incidence V
#' @import magrittr
create_monolayer_object <- function(x, directed=NULL, bipartite=NULL, group_names=c('set_cols','set_rows'), node_metadata=NULL){
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
