#' Alluvial plot for multilayer network
#'
#' @param x An object of class \code{infomap_multilayer}.
#'
#' @details Use ggplot and ggalluvial to plot an alluvial plot that shows the flow of nodes between modules. Very useful for temporal networks.
#'    
#' @return An object of class \code{ggplot}.
#'
#' @seealso \code{ggplot2, ggalluvial, infomap_monolayer}
#'
#' @export
#'
#' @import ggalluvial
#' @import ggplot2
plot_multilayer_alluvial <- function(x){
  if(class(x)!='infomap_multilayer'){stop('x must be of class infomap_multilayer')}
  p <- ggplot(x$modules, 
              aes(x=layer_id, stratum=as.factor(module),  alluvium=node_id, label=as.factor(module), fill=as.factor(module)))+
        geom_flow(stat = "alluvium",lode.guidance = "frontback",color =  "darkgray")+
        geom_stratum() +
        labs(x='Layer', y='Number of species')+
        theme_bw()
  return(p)
}

