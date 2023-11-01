devtools::install_github('Ecological-Complexity-Lab/infomap_ecology_package', force=T)
remotes::install_github("rlesur/klippy")

#setwd("/Users/shai/GitHub/ecomplab/emln_package")
setwd("/Users/shirlyf/Documents/GitHub/infomap_ecology_package")

# Make the website
rmarkdown::render_site(input = 'website_source')

# Remove unnecesary files
unlink('docs_v2/', recursive = TRUE, force = FALSE)
file.copy('website_source/docs_v2/', '.', recursive = T)
unlink('website_source/analysis_example_files/', recursive = TRUE, force = FALSE)
unlink('website_source/docs_v2/', recursive = TRUE, force = FALSE)
