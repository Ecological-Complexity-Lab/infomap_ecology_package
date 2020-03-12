#' Create a multilayer network object
#'
#' The object includes the intralayer edges, interlayer edges (if there are), and metadata on nodes and layers.
#' The purpose of this package is to provide a wrapper for Infomap, and not to fully handle multilayer network objects. Therefore, converting and preparing the multilayer object is done by the user. A dedicated package for multilayer networks that handles data from scratch is in the works.
#'
#' @param extended An extended edge list of the format \code{layer_from node_from layer_to node_to weight}, that contains all intra- and inter-layer edges. If supplied, then intra and inter are ignored. Should only contain node and layer IDs.
#' @param intra An edge list of the format \code{layer node_from node_to weight}. Should only contain node and layer IDs.
#' @param inter An edge list of the format \code{layer_from node_from layer_to node_to weight}. Should only contain node and layer IDs. Defaults to NULL, assuming the network does not have interlayer edges.
#' @param nodes A data frame with node metadata. First column must be node_id with IDs corresponding to those in \code{extended}, \code{intra} or \code{inter}.
#' @param layers A data frame with layer metadata. First column must be layer_id with IDs corresponding to those in \code{extended}, \code{intra} or \code{inter}.
#'
#' @return A \code{multilayer} object
#'
#' @seealso \code{multilayer}
#'
#' @export
#' @import dplyr
#' @import magrittr

# x is  node_metadata must
#
create_multilayer_object <- function(extended, intra=NULL, inter=NULL, nodes=NULL, layers=NULL){
  if (!is.null(extended)){
    if (any(!is.null(intra),!is.null(intra))){stop('Cannot provide both extended and intra/inter')}
    intra <- extended %>% filter(layer_from==layer_to)
    inter <- extended %>% filter(layer_from!=layer_to)
    if (nrow(inter)==0){inter <- NULL}
  } else {
    intra %<>% select(layer_from=layer, node_from, layer_to=layer, node_to, weight)
  }
  out <- list(intra=intra,
              inter=inter,
              nodes=nodes,
              layers=layers)
  class(out) <- 'multilayer'
  return(out)
}
