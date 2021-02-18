#' Plot modules across layers for multilayer networks
#'
#' @param x An object of class \code{infomap_multilayer}.
#' @param type Plot type, circles or rectangles. See details.
#' @param color_modules Color modules? See details.
#'
#' @details Type \code{circle} plots a circle per module-layer combination, with the radius proportional
#'   to the number of nodes in the module in the layer. Type \code{rectangle} plots a bar across all the layers a module spans. Only (or mostly) relevant for temporal networks.
#'
#'   For a circle plot, \code{color_modules} will give a different color for
#'   each module ID. For a rectangle plot, \code{color_modules} will color each
#'   module by the total number of nodes it contains (not per layer).
#'
#'  Because the output is a ggplot object it can be further manipulated with standard
#'   ggplot2.
#'
#' @return An object of class \code{ggplot}.
#'
#' @seealso \code{ggplot2, infomap_monolayer}
#'
#' @references Code was first developed for: Pilosof, S., Q. He, K. E. Tiedje,
#'   S. Ruybal-Pesántez, K. P. Day, and M. Pascual. 2019. Competition for hosts
#'   modulates vast antigenic diversity to generate persistent strain structure
#'   in Plasmodium falciparum. PLoS biology 17:e3000336.
#'
#' @examples
#' \dontrun{
#' emln <- create_multilayer_object(extended = siberia1982_7_links,
#'  nodes = siberia1982_7_nodes, intra_output_extended = TRUE, inter_output_extended = TRUE)
#'  
#' emln_modules <- run_infomap_multilayer(M=emln, relax = FALSE, 
#' flow_model = 'directed', silent = TRUE, trials = 100, seed = 497294, 
#' temporal_network = TRUE)
#'
# Rectangle-type plot
#'plot_multilayer_modules(emln_modules, type = 'rectangle', color_modules = TRUE)+
#'  scale_fill_viridis_c()
#'plot_multilayer_modules(emln_modules, type = 'rectangle', color_modules = FALSE)+
#'  geom_rect(fill='orange')
#'
#'# Circle-type plot
#'plot_multilayer_modules(emln_modules, type = 'circle', color_modules = TRUE)
#'
#'plot_multilayer_modules(emln_modules, type = 'circle', color_modules = FALSE)+
#' geom_point(aes(size=size), color='navy')
#'
#'# More examples to modify the plots
#'plot_multilayer_modules(emln_modules, type = 'rectangle', color_modules = TRUE)+
#'  scale_fill_viridis_c()+
#'  scale_x_continuous(breaks=seq(0,6,1))+
#'  scale_y_continuous(breaks=seq(0,40,5))+
#'  theme_bw()+
#'  theme(panel.grid.major = element_blank(),
#'        panel.grid.minor = element_blank(),
#'        axis.title = element_text(size=20),
#'        axis.text = element_text(size = 20),
#'        legend.text =  element_text(size=15),
#'        legend.title = element_text(size=20))
#' }
#' 
#' @export
#'
## @import ggalluvial
## @import ggplot2
plot_multilayer_modules <- function(x, type=c('circle', 'rectangle'), color_modules=T){
  if (type=='rectangle'){
    p <- x$modules %>% 
      group_by(module) %>%
      summarise(b=min(layer_id), #birth
                d=max(layer_id), # death
                persistence=d-b+1,
                size=n_distinct(node_id)) %>% # Number of species in the module
      ggplot(aes(xmin=b, xmax=d+0.05, ymin=module, ymax=module+0.5))+
      geom_rect()+
      labs(x='Layer', y='Module ID', fill='Module size')
    if (color_modules){ p <- p+geom_rect(aes(fill=size)) }
  }
  
  if (type=='circle'){
    p <- x$modules %>% 
      group_by(module, layer_id) %>%
      summarise(size=n_distinct(node_id)) %>% 
      ggplot(aes(x=layer_id, y=module))+
      labs(x='Layer', y='Module ID', fill='Module size')
    if (color_modules){
      p <- p+geom_point(aes(size=size, color=as.factor(module)))
    } else {
      p <- p+geom_point(aes(size=size))
    }
  }
  return(p)
}
