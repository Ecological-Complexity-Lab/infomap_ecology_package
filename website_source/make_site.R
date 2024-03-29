#devtools::install_github('Ecological-Complexity-Lab/infomap_ecology_package', force=T)
library(infomapecology)
remotes::install_github("rlesur/klippy")

#setwd("/Users/shai/GitHub/ecomplab/emln_package")
setwd("/Users/shirlyf/Documents/GitHub/infomap_ecology_package")

# Make the website
rmarkdown::render_site(input = 'website_source')

#rmarkdown::render("website_source/monolayer/bipartite.Rmd", output_format = "html_document", output_dir = "website_source/docs/monolayer/")
#rmarkdown::render("website_source/monolayer/monolayer_heirarchical.Rmd", output_format = "html_document", output_dir = "website_source/docs/monolayer/")



# Remove unnecesary files
unlink('docs/', recursive = TRUE, force = FALSE)
file.copy('website_source/docs/', '.', recursive = T)
unlink('website_source/analysis_example_files/', recursive = TRUE, force = FALSE)
unlink('website_source/docs/', recursive = TRUE, force = FALSE)
