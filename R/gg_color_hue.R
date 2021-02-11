#' Generate colors for ggplot
#' @param n See package metafolio
#' @param hue_min See package metafolio
#' @param hue_max See package metafolio
#' @param tune1 See package metafolio
#' @param tune2 See package metafolio
#' 
#' @details Taken from package metafolio. See details there

gg_color_hue <- function(n, hue_min = 10, hue_max = 280, tune1 = 62, tune2 = 100) {
  hues = seq(hue_min, hue_max, length=n+1)
  hcl(h=hues, l=tune1, c=tune2)[1:n]
}