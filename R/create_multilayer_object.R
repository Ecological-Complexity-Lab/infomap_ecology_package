#' Create a multilayer network object
#'
#' Takes an edge list input with node IDs and returns a multilayer object that
#' includes the intralayer edges, interlayer edges (if there are), and metadata
#' on nodes and layers.
#'
#' @param extended An extended edge list input of the format \code{layer_from
#'   node_from layer_to node_to weight}, that contains all intralayer, and
#'   (optionally) interlayer edges. If supplied, then \code{intra} and
#'   \code{inter} are ignored. Should only contain node and layer IDs.
#' @param intra An edge list of the format \code{layer node_from node_to
#'   weight}. Should only contain node and layer IDs.
#' @param inter An edge list of the format \code{layer_from node_from layer_to
#'   node_to weight}. Should only contain node and layer IDs. Defaults to NULL,
#'   assuming the network does not have interlayer edges.
#' @param nodes A data frame with node metadata. First column must be node_id
#'   with IDs corresponding to those in \code{extended}, \code{intra} or
#'   \code{inter}.
#' @param layers A data frame with layer metadata. First column must be layer_id
#'   with IDs corresponding to those in \code{extended}, \code{intra} or
#'   \code{inter}.
#' @param intra_output_extended Defaults to \code{TRUE}, see details.
#' @param inter_output_extended Defaults to \code{TRUE}, see details.
#'
#' @details \code{extended, intra, inter} must only contain node IDs. Any
#'   details on nodes and layers that link to these IDs should be provided in
#'   \code{nodes} and \code{layers}.
#'
#'   Intralayer edges can have either an extended format of \code{layer_from
#'   node_from layer_to node_to weight} or a non-extended Intra/Inter format of \code{layer
#'   node_from node_to weight}.
#'
#'   Interlayer edges too can have either an extended format of \code{layer_from
#'   node_from layer_to node_to weight} or a non-extended format of
#'   \code{layer_from node layer_to weight}. **However, in Infomap, a non-extended format is
#'   ONLY valid for coupling interlayer edges using a relax rate, which connects between different
#'   realizations of the same physical nodes in diffrent layers. When interlayer
#'   edges are between different physical nodes use the extended format.**
#'
#' @examples
#' data("siberia1982_7_links") # Links are an extended edge list
#' data("siberia1982_7_nodes") # nodes
#'
#' # Information on layers
#' layers <- tibble(layer_id=1:6, year=1982:1987)
#'
#' # Create a multilayer object with an extended list.
#' emln <- create_multilayer_object(extended = siberia1982_7_links,
#'  nodes = siberia1982_7_nodes,
#'  intra_output_extended = T,
#'  inter_output_extended = T,
#'  layers=layers)
#'
#' # Create a multilayer object with a non-extended Intra/Inter type link list.
#' emln <- create_multilayer_object(extended = siberia1982_7_links,
#'  nodes = siberia1982_7_nodes,
#'  intra_output_extended = F,
#'  inter_output_extended = F,
#'  layers=layers)
#'
#' # If one wants to ignore interlayer edges
#' emln$inter <- NULL
#'
#'
#' @return A \code{multilayer} object
#'
#' @seealso \code{multilayer}
#'
#' @export
#' @import dplyr
#' @import magrittr

create_multilayer_object <- function(extended=NULL, intra=NULL, inter=NULL, nodes=NULL, intra_output_extended=T, inter_output_extended=T, layers=NULL){
  if(!is.null(layers)){
    if(names(layers)[1]!='layer_id') {stop('First column in layers must be named layer_id')}
  }
  if(names(nodes)[1]!='node_id') {stop('First column in nodes must be named layer_id')}
  
  
  if (!is.null(extended)){
    intra <- extended %>% filter(layer_from==layer_to)
    inter <- extended %>% filter(layer_from!=layer_to)
    # If there are no interlayer edges
    if (nrow(inter)==0){inter <- NULL}

    # Set the output formats
    if (intra_output_extended==F){intra %<>% select(layer=layer_from, node_from, node_to, weight)}
    if (!is.null(inter) && inter_output_extended==F){inter %<>% select(layer_from, node=node_from, layer_to, weight)}

  } else {
    # for extended output of intralayer edges
    if (intra_output_extended) {intra %<>% select(layer_from=layer, node_from, layer_to=layer, node_to, weight)}
    if (!is.null(inter) && inter_output_extended==F){inter %<>% select(layer_from, node=node_from, layer_to, weight)}
  }
  
   
  out <- list(intra=intra,
              inter=inter,
              nodes=nodes,
              layers=layers)
  class(out) <- 'multilayer'
  return(out)
}
