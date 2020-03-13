## infomapecology: A package for running Infomap, inspired by ecological networks

The package contains functions that prepare monolayer and multilayer networks
for analysis with Infomap, run Infomap from within R and parse the results
back to R. It is inspired by analysis of ecological networks but is
suitable for other areas of research as well. The package also includes several data sets of ecological networks.

## Install Infomap
We use Infomap version 1 as a stand-alone file. Future versions (or a different
package) will integrate Infomap directly intro R. Complete instructions on how
to download, install and use Infomap can be found in
[https://www.mapequation.org](https://www.mapequation.org). **The best
practice is to compile Infomap under the file name "Infomap" and place it in the
same working folder in which the R code is run.**

Note: though technically Infomap can run on Windows, I find that this is not always so easy to do, as you need some Linux environemnt installed within Windows. **I strongly recommend working within Linux or MacOS**.

## Install the R package
Make sure you have the latest version of R and packages `attempt, igraph, magrittr, tidyverse` (tidyverse should include `readr` and `stringr`). then Run:

```R
install.packages("devtools") # If you don't have it already
devtools::install_github('Ecological-Complexity-Lab/infomap_ecology_package', force=T)
library(infomapecology)
setwd('where your Infomap file and R script live')
check_infomap() # Make sure file can be run correctly.
```

## Examples

### Bipartite network
```R
library(bipartite)
data(memmott1999)
network_object <- create_monolayer_object(memmott1999, bipartite = T, directed = F, group_names = c('A','P'))
infomap_input <- create_infomap_linklist(network_object)
infomap_object <- run_infomap_monolayer(infomap_input, infomap_executable='Infomap',
                                        flow_model = 'undirected',
                                        silent=T, trials=20, two_level=T, seed=123)
```

### Food web with hierarchical structure

```R
data(otago_nodes)
data(otago_links)
otago_nodes %<>%
  filter(StageID==1) %>%
  select(node_name=WorkingName, node_id_original=NodeID, WorkingName,StageID, everything())
anyDuplicated(otago_nodes$node_name)
otago_links %<>%
  filter(ConsumerSpecies.StageID==1) %>%
  filter(ResourceSpecies.StageID==1) %>%
  select(from=ResourceNodeID, to=ConsumerNodeID) %>%
  left_join(otago_nodes, by=c('from'='node_id_original')) %>%
  select(from, node_name, to) %>%
  left_join(otago_nodes, by=c('to'='node_id_original')) %>%
  select(from=node_name.x, to=node_name.y) %>%
  mutate(weight=1)

# Prepare network objects and run infomap
network_object <- create_monolayer_object(otago_links, directed = T, bipartite = F, node_metadata = otago_nodes)
infomap_input <- create_infomap_linklist(network_object)
infomap_object <- run_infomap_monolayer(infomap_input, infomap_executable='Infomap',
                                        flow_model = 'directed',
                                        silent=T,trials=100, two_level=F, seed=200952)
```

## Multilayer network with interlayer edges
```R
NEE2017 <- create_multilayer_object(extended = siberia1982_7_links, nodes = siberia1982_7_nodes, intra_output_extended = T, inter_output_extended = T)

#Run infomap for a temporal network
NEE2017_modules <- run_infomap_multilayer(M=NEE2017, relax = F, flow_model = 'directed', silent = T, trials = 100, seed = 497294, temporal_network = T)

#Module persistance
modules_persistence <- NEE2017_modules$modules %>%
  group_by(module) %>%
  summarise(b=min(layer_id), d=max(layer_id), persistence=d-b+1) %>%
  count(persistence) %>%
  mutate(percent=(n/max(NEE2017_modules$module$module))*100)
  
#Module persistance
modules_persistence <- NEE2017_modules$modules %>%
  group_by(module) %>%
  summarise(b=min(layer_id), d=max(layer_id), persistence=d-b+1) %>%
  count(persistence) %>%
  mutate(percent=(n/max(NEE2017_modules$module$module))*100)

# Plot
NEE2017_modules$modules %>%
  group_by(module) %>%
  summarise(b=min(layer_id), d=max(layer_id), persistence=d-b+1, size=n_distinct(node_id)) %>%
  ggplot() +
  geom_rect(aes(xmin=b, xmax=d+0.05, ymin=module, ymax=module+0.5, fill=size))+
  scale_x_continuous(breaks=seq(0,6,1))+
  scale_y_continuous(breaks=seq(0,40,5))+
  theme_bw()+
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.title = element_text(size=20),
        axis.text = element_text(size = 20),
        legend.text =  element_text(size=15),
        legend.title = element_text(size=20))+
  labs(x='Layer', y='Module ID', fill='Module size')
```

