#' Host-parasite temporal multilayer network: nodes
#'
#' This data set contains information about the nodes of a temporal multilayer
#' network representing the infection  of  22  small mammalian  host  species by
#' 56  ectoparasite  species  during  6 consecutive summers in Siberia
#' (1982–1987).
#'
#' @details The data set is in an extentded edge list format (layer_from
#'   node_from layer_to node_to weight). It contains both intralayer and
#'   interlayer edges.  Each layer is a host-parasite bipartite network.
#'   Intralayer edges between a parasite species and a host species are the
#'   number of parasite individuals divided by the number of host individuals.
#'   Interlayer coupling edges connect each physical node to itself in the next
#'   layer (e.g., host A in layer 1 to host A in layer 2), and are calculated as
#'   the number of individuals in layer l+1 divided by the number of individuals
#'   in layer l. They therefore represent population dynamics. Interlayer edges
#'   only go one way (_l-->l+1_) because time flow one way. We represented the
#'   undirected edges within each layer as directed edges that go both ways
#'   (with the same weight) to be able to have a directed flow. This does not
#'   affect the calculation of the map equation.
#'
#'   See \code{siberia1982_7_links} for the ede list.
#'
#' @docType data
#'
#' @usage data(siberia1982_7_nodes)
#' data(siberia1982_7_links)
#'
#' @keywords datasets
#'
#' @references Krasnov BR, Matthee S, Lareschi M, Korallo-Vinarskaya NP, Vinarski MV. Co-occurrence of ectoparasites on rodent hosts: null model analyses of data from three continents. Oikos. 2010;119: 120–128.
#'
#' Pilosof S, Fortuna MA, Vinarski MV, Korallo-Vinarskaya NP, Krasnov BR. Temporal dynamics of direct reciprocal and indirect effects in a host-parasite network. J Anim Ecol. 2013;82: 987–996.
#'
#' Pilosof S, Porter MA, Pascual M, Kéfi S. The multilayer nature of ecological networks. Nature Ecology & Evolution. 2017;1: 0101.
#'
#'
#' @seealso \code{siberia1982_7_links}
#'
#' @examples
#' data(siberia1982_7_links)
#' data(siberia1982_7_nodes)
#' create_multilayer_object(extended = siberia1982_7_links, nodes = siberia1982_7_nodes)
"siberia1982_7_nodes"
