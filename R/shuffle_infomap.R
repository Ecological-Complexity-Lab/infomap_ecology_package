#' Shuffle a network and return linklists for Infomap (beta)
#'
#' Shuffles the network according to a predefined algorithm and return a list of
#' linklists that can be analyzed by Infomap.
#'
#' @details This function is used internally by
#'   \code{run_infomap_monolayer}, but can also be run independently
#'   Currently only supports bipartite networks and shuffling methods from the
#'   vegan package as defined in \code{vegan::commsim}.
#'
#' @param x An object of class \code{infomap_link_list} or \code{monolayer}.
#' @param shuff_method Method to shuffle the network. See details.
#' @param nsim How many shuffled networks to create?
#' @param ... Additional parameters for shuffling passed to \code{simulate}, such as burnin. See \code{nullmodel} in package \code{vegan}.
#'
#' @return A list of linklists that can be used by Infomap.
#' 
#' @seealso Functions \code{commsim, nullmodel} in package \code{vegan}.
#'
#' @examples 
#' network_object <- create_monolayer_object(bipartite::memmott1999, bipartite = T, directed = F, group_names = c('A','P'))
#' shuffled <- shuffle_infomap(network_object, shuff_method='curveball', nsim=50, burnin=2000)
#'
#' @export
#' 
## @importFrom magrittr '%<>%' '%>%'
## @importFrom dplyr left_join select
## @importFrom vegan nullmodel commsim
## @importFrom igraph graph.incidence


shuffle_infomap <- function(x, shuff_method='r00', nsim=1000, ...){
  print('Shuffling...')
  null <- vegan::nullmodel(x$mat, shuff_method)
  shuffled <- simulate(null, nsim = nsim, ...)
  shuffled_linklist <- NULL
  for (i in 1:nsim){
    g <- graph.incidence(t(shuffled[,,i]), weighted = T)
    link_list <- as_tibble(igraph::as_data_frame(g, "edges"))
    link_list %<>%
      left_join(x$nodes, by=c('from' = 'node_name')) %>%
      left_join(x$nodes, by=c('to' = 'node_name')) %>%
      select(from=node_id.x, to=node_id.y, weight)
    shuffled_linklist[[i]] <- link_list
  }
  return(shuffled_linklist)
}
