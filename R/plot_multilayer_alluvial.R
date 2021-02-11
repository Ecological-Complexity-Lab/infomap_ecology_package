#' Alluvial plot for multilayer network
#'
#' @param x An object of class \code{infomap_multilayer}.
#' @param module_labels Should module labels be presented
#'
#' @details Use ggplot and ggalluvial to plot an alluvial plot that shows the flow of nodes between modules. Very useful for temporal networks. Because the output is
#'   a ggplot object it can be further manipulated with standard ggplot2.
#'    
#' @return An object of class \code{ggplot}.
#'
#' @seealso \code{ggplot2, ggalluvial, infomap_monolayer}
#'
#' @examples 
#' emln <- create_multilayer_object(extended = siberia1982_7_links,
#'  nodes = siberia1982_7_nodes, intra_output_extended = TRUE, inter_output_extended = TRUE)
#'  
#' emln_modules <- run_infomap_multilayer(M=emln, relax = FALSE, 
#' flow_model = 'directed', silent = TRUE, trials = 100, seed = 497294,
#'  temporal_network = TRUE)
#' 
#' # Plot alluvial diagram
#' plot_multilayer_alluvial(emln_modules, module_labels = FALSE)
#' 
#' # Can also modify the plot
#' plot_multilayer_alluvial(emln_modules, module_labels = FALSE)+
#'    geom_stratum(linetype='dashed', color='gray')+
#'    scale_x_continuous(breaks=seq(0,6,1))+
#'    scale_y_continuous(breaks=seq(0,70,5))+
#'    labs(y='Number of species')+
#'    theme_bw()+
#'    theme(legend.position = "none",
#'          panel.grid = element_blank(),
#'          axis.text = element_text(color='black', size = 20),
#'          axis.title = element_text(size=20))
#'      
#' @export
#'
## @import ggalluvial
## @import ggplot2
plot_multilayer_alluvial <- function(x, module_labels=F){
  if(class(x)!='infomap_multilayer'){stop('x must be of class infomap_multilayer')}
  p <- ggplot(x$modules, 
              aes(x=layer_id, stratum=as.factor(module),
                  alluvium=node_id, 
                  label=as.factor(module), 
                  fill=as.factor(module)))+
        ggalluvial::geom_flow(stat = "alluvium", lode.guidance = "frontback", color =  "darkgray")+
        ggalluvial::geom_stratum() +
        labs(x='Layer', y='Number of nodes')+
        theme_bw()
  if (module_labels){
    p <- p+geom_text(stat = "stratum")
  }
  return(p)
}

