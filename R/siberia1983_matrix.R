#' Siberia 1983 host-parasite temporal matrix
#' 
#' Host-parasite temporal multilayer network.
#' This data set contains the matrices of a temporal multilayer
#' network representing the infection of 22 small mammalian host species by
#' 56 ectoparasite species during 6 consecutive summers in Siberia
#' (1982–1987).
#' 
#' @details The data set is in an matrix format.Each layer is a host-parasite bipartite network.
#'   Intralayer edges between a parasite species and a host species are the
#'   number of parasite individuals divided by the number of host individuals.
#'   Interlayer coupling edges connect each physical node to itself in the next
#'   layer (e.g., host A in layer 1 to host A in layer 2), and are calculated as
#'   the number of individuals in layer l+1 divided by the number of individuals
#'   in layer l. They therefore represent population dynamics. Interlayer edges
#'   only go one way (_l-->l+1_) because time flow one way. 
#'   
#'   See \code{siberia_nodes} for information about the nodes.
#'   
#'   See \code{siberia_interlayer} for information about the interlayer edges.
#'
#' @format A numeric matrix with rows representing host species and columns representing parasite species.
#'
#' @source Simulated data for illustration purposes.
#'
#' @docType data
#'
#' @usage data(siberia1983_matrix)
#' 
#' @references Krasnov BR, Matthee S, Lareschi M, Korallo-Vinarskaya NP, Vinarski MV. Co-occurrence of ectoparasites on rodent hosts: null model analyses of data from three continents. Oikos. 2010;119: 120–128.
#'
#' Pilosof S, Fortuna MA, Vinarski MV, Korallo-Vinarskaya NP, Krasnov BR. Temporal dynamics of direct reciprocal and indirect effects in a host-parasite network. J Anim Ecol. 2013;82: 987–996.
#'
#' Pilosof S, Porter MA, Pascual M, Kéfi S. The multilayer nature of ecological networks. Nature Ecology & Evolution. 2017;1: 0101.
#'
#'
#' @examples
#' data(siberia1982_matrix)
#' data(siberia1983_matrix)
#' data(siberia1984_matrix)
#' data(siberia1985_matrix)
#' data(siberia1986_matrix)
#' data(siberia1987_matrix)
#' data(siberia_nodes)
#' data(siberia_interlayer)
#' 
#' # Create a multilayer object
#' layer_attrib <- tibble(layer_id=1:6, layer_name=c('1982','1983','1984','1985','1986','1987'))                                     
#' 
#' multilayer_siberia <- create_multilayer_network(list_of_layers = list(siberia1982_matrix,
#'                                                                       siberia1983_matrix,
#'                                                                       siberia1984_matrix,
#'                                                                       siberia1985_matrix,
#'                                                                       siberia1986_matrix,
#'                                                                       siberia1987_matrix),
#'                                                 layer_attributes = layer_attrib,
#'                                                 bipartite = T,
#'                                                 directed = F, physical_node_attributes = siberia_nodes )

siberia1983_matrix <- matrix(c(1, 0, 1, 0, 0, 1, 1, 1, 0, 1, 0, 0), nrow = 3, ncol = 4)


# Export the dataset using data()
#' @export
data(siberia1983_matrix)
