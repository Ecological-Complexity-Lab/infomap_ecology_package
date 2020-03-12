\name{multilayer class}
\alias{multilayer}
\title{An object of class multilayer}

\value{
A list with:
\itemize{
  \item intra: An extended edge list of intralayer edges, with the format \code{layer_from node_from layer_to node_to weight}, but in which layer_from=layer_to. All nodes and layers are depicted with IDs, not names.
  \item An extended edge list of interlayer edges, with the format \code{layer_from node_from layer_to node_to weight}, but in which layer_from!=layer_to. All nodes and layers are depicted with IDs, not names.
  \item nodes: a tibble with metadata on the nodes (name, type, other attributes). The first column, \code{node_id} contains the IDs that correspond to columns \code{node_from} and \code{node_to} in \code{intra} and \code{inter}.
  \item layers: Metadata on layers (e.g., name of patch or species). The first column, \code{layer_id} contains the IDs that correspond to columns \code{layer_from} and \code{layer_to} in \code{intra} and \code{inter}.
}
}
\description{
A network object of class multilayer contains all the necessary information and R objects to ru Infomap on a multilayer network and to parse the results in a meaningful way using node and layer metadata.
}
\seealso{
\code{create_multilayer_object}
}

