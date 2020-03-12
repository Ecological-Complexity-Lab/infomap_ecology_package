#' Create a link list for Infomap
#'
#' Takes a monolayer object and returns a link list and a tibble with nodes.
#'
#' @param x A monolayer object created by, e.g., create_network_object
#' @param make_directed for undirected networks, create two sets of edges
#' @param write_to_file write the link list into a file.
#' @param output_file the name of the output file (default is 'infomap_link_list.txt')
#' @return A list
#' \itemize{
#'   \item \code{edge_list_infomap} A link list (format: from, to, weight) formatted for Infomap, with node IDs
#'   \item \code{nodes} A tibble with node IDs, names and possibly other attributes.
#' }
#' @export
#' @import dplyr
#' @import magrittr

create_infomap_linklist <- function(x, make_directed=F, write_to_file=F, output_file='infomap_link_list.txt'){
  if(class(x)!='monolayer'){stop('x must be of class monolayer')}
  # prepare an edge list for infomap.
  edge_list <- x$edge_list
  nodes <- x$nodes
  edge_list %<>%
    left_join(nodes, by=c('from' = 'node_name')) %>%
    left_join(nodes, by=c('to' = 'node_name')) %>%
    select(from=node_id.x, to=node_id.y, weight)
  if(write_to_file){
    print(paste('Link list written to: ',output_file,sep=''))
    write_delim(edge_list, output_file, delim = ' ', col_names = F)
  }
  out <- list(edge_list_infomap=edge_list, nodes=nodes)
  class(out) <- 'infomap_link_list'
  return(out)
}
