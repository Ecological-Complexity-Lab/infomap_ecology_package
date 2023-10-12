#'Plot histograms for randomizations
#'
#'@details Use ggplot to plot two histograms for the values of the map equation
#'  L and the number of modules. Dashed line is the observed value. Because
#'  returned objects are ggplot objects, they can be modified.
#'
#'@param x An object of class \code{infomap_monolayer}.
#'@param colors The fill colors of the histograms.
#'@param plotit Also show the plots?
#'
#'@return A list with objecst of class \code{ggplot}:
#'\itemize{
#'\item L_plot: Histogram for the map equation
#'\item m_plot: Histogram for the number of modules
#'}
#'
#'@seealso \code{ggplot2, infomap_monolayer}
#'
#'
#' @examples
#' \dontrun{
#' network_object <- create_monolayer_network(bipartite::memmott1999, 
#' bipartite = TRUE, directed = FALSE, group_names = c('Animals','Plants'))
#' infomap_object <- run_infomap_monolayer(network_object, 
#'       infomap_executable='Infomap',
#'       flow_model = 'undirected',
#'       silent=TRUE, trials=20, two_level=TRUE, seed=123, 
#'       signif = TRUE, shuff_method = 'r00', nsim = 50)
#' 
#' #get plots and plot them
#' x <- plot_signif(infomap_object, plotit = TRUE)
#' 
#' # Can modify the plots with ggplot2
#' x$L_plot+
#' theme_bw()+
#' theme(legend.position='none', 
#'      axis.text = element_text(size=20), 
#'      axis.title = element_text(size=20))
#'
#' }
#'@export
#'
##@import dplyr
##@import magrittr
##@import ggplot2
plot_signif <- function(x, colors=c('plum','tomato4'), plotit=T){
  if(class(x)!='infomap_monolayer'){stop('x must be of class infomap_monolayer')}
  p1 <- tibble(L_sim=x$L_sim) %>%
    ggplot(aes(L_sim))+
    geom_histogram(fill=colors[1])+
    geom_vline(xintercept = x$L, linetype='dashed')+
    labs(x='Map equation L', y='Number shuffled networks')
  p2 <- tibble(m_sim=x$m_sim) %>%
    ggplot(aes(m_sim))+
    geom_histogram(fill=colors[2])+
    geom_vline(xintercept = x$m, linetype='dashed')+
    labs(x='Number of modules', y='Number shuffled networks')
  # Show plots?
  if (plotit){print(cowplot::plot_grid(p1,p2,align = 'vh'))}
  
  return(list(L_plot=p1, m_plot=p2))
}

