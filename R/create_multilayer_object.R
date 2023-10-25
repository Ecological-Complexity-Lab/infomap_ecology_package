#' Create a multilayer network object
#'
#' Takes an edge list input with node IDs and returns a multilayer object that
#' includes the intralayer edges, interlayer edges (if there are), and metadata
#' on nodes and layers.
#'
#' @param extended An extended edge list input of the format \code{layer_from
#'   node_from layer_to node_to weight}, that contains all intralayer, and
#'   (optionally) interlayer edges. If supplied, then \code{intra} and
#'   \code{inter} are ignored. Nodes and layers should be specified by IDs, not names.
#' @param intra An edge list of the format \code{layer node_from node_to
#'   weight}. Nodes and layers should be specified by IDs, not names.
#' @param inter An extended edge list of the format \code{layer_from node_from
#'  layer_to node_to weight}. Nodes and layers should be specified by IDs, not names. Defaults to NULL,
#'   assuming the network does not have interlayer edges.
#' @param nodes A data frame with node metadata. First column must be node_id
#'   with IDs corresponding to those in \code{extended}, \code{intra} or
#'   \code{inter}.
#' @param layers A data frame with layer metadata. First column must be layer_id
#'   with IDs corresponding to those in \code{extended}, \code{intra} or
#'   \code{inter}.
#' @param intra_output_extended Defaults to \code{TRUE}. Should the intralayer edges be written in the extended edge list format. 
#'   Set as \code{FALSE} for running with relax_rate instead of with interlayer edges.
#' @param write_to_file Write the edge list to a text file? Convenient to copy-paste into the online version of infomap.
#' @param filename_prefix The name of the file. Extension will always be .txt and the file is space-delimited.
#' 
#'
#' @details \code{extended, intra, inter} must only contain node IDs. Any
#'   node and layer attributes that link to these IDs should be provided in
#'   \code{nodes} and \code{layers}.
#'
#'   Intralayer edges can have either an extended format of \code{layer_from
#'   node_from layer_to node_to weight} or a non-extended format of \code{layer
#'   node_from node_to weight}.
#'
#'   Interlayer edges must have an extended format of \code{layer_from
#'   node_from layer_to node_to weight}. This is because a non-extended format (\code{layer_from
#'   node_from layer_to weight}) is ONLY valid for interlayer edges that connect between different
#'   realizations of the same physical nodes in different layers (coupling interlayer links). To avoid
#'   confusion we do not allow this format.
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
#'  intra_output_extended = TRUE,
#'  layers=layers)
#'
#' # Create a multilayer object with a non-extended Intra/Inter type link list.
#' emln <- create_multilayer_object(extended = siberia1982_7_links,
#'  nodes = siberia1982_7_nodes,
#'  intra_output_extended = FALSE,
#'  layers=layers)
#'
#' # To ignore interlayer edges:
#' emln$inter <- NULL
#'
#'
#' @return A \code{multilayer} object
#'
#' @seealso \code{multilayer}
#'
#' @export
## @import dplyr
## @import magrittr

create_multilayer_object_toDelete <- function(extended=NULL, intra=NULL, inter=NULL, nodes=NULL, intra_output_extended=T, layers=NULL, write_to_file=F, filename_prefix=NULL){
  if(!is.null(layers)){
    if(names(layers)[1]!='layer_id') {stop('First column in layers must be named layer_id')}
  }
  if(names(nodes)[1]!='node_id') {stop('First column in nodes must be named node_id')}
  
  if (!is.null(extended)){
    if(names(extended)[5]!='weight') {stop('5th column should be "weight"')}
    
    intra <- extended %>% filter(layer_from==layer_to)
    inter <- extended %>% filter(layer_from!=layer_to)
    # If there are no interlayer edges
    if (nrow(inter)==0){inter <- NULL}
    
    # Set the output formats
    if (intra_output_extended==F){intra %<>% select(layer=layer_from, node_from, node_to, weight)}
    # Write edge list to a txt file
    if (write_to_file==T){write_delim(extended, paste(filename_prefix,'.txt',sep=''), delim = ' ')}
  } else {
    if (!is.null(intra)){if(names(intra)[4]!='weight') {stop('4th column in Intralayer edge list should be weight')}}
    if (!is.null(inter)){if(names(inter)[5]!='weight') {stop('5th column in Interlayer edge list should be weight')}}
    
    # for non-extended output of intralayer edges
    if (intra_output_extended) {intra %<>% select(layer_from=layer, node_from, layer_to=layer, node_to, weight)}
    # Write edge list to a txt file
    write_delim(intra, paste(filename_prefix,'.txt',sep=''), delim = ' ')
    if (!is.null(inter)){write_delim(inter, paste(filename_prefix,'.txt',sep=''), delim = ' ', append = T)}
  }
  
  out <- list(intra=intra,
              inter=inter,
              nodes=nodes,
              layers=layers)
  class(out) <- 'multilayer'
  return(out)
}
