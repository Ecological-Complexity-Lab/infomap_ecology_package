\name{monolayer class}
\alias{monolayer}
\title{An object of class monolayer}

\value{
A list with:
\itemize{
  \item mode: bipartite (B) or unipartite (U)
  \item directed: T/F
  \item nodes: a tibble with information on the nodes (name, id, type, other attributes)
  \item mat: the network in a matrix format
  \item edge_list: the network in an edge list format
  \item igraph_object: the igraph object of the network
}
}
\description{
A network object of class monolayer contains all the necessary information and R objects to perform future analyses on a monolayer network, and in particular analyses using Infomap.
}
\seealso{
\code{list_to_matrix, matrix_to_list_unipartite, matrix_to_list_bipartite, create_network_object}
}

