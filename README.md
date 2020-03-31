## infomapecology: A package for running Infomap, inspired by ecological networks

The package contains functions that prepare monolayer and multilayer networks
for analysis with Infomap, run Infomap from within R and parse the results
back to R. It is inspired by analysis of ecological networks but is
suitable for other areas of research as well. The package also includes several data sets of ecological networks.

## Install Infomap
We use Infomap version 1 as a stand-alone file. Future versions (or a different
package) will integrate Infomap directly intro R. On Linux/MacOs, you can install Infomap via the `install_infomap` function in the package (see next section), or follow the instructions on how to download, install and use Infomap in [https://www.mapequation.org](https://www.mapequation.org).

For Windows, try this:
1. Install  miniconda Python 3 from here: https://docs.conda.io/en/latest/miniconda.html. You may also need Visual Studio (https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2017). If so, choose Workload: Desktop Development with C++.
2. Open Windows’ powershell.
3. type: `pip install infomap`.

This will create a file called `infomap`. In the anaconda terminal you can type `where infomap` to find the file. 

An alternative is to install a local Linux environment like Ubuntu from the Microsoft Store.

**Important notes:**
1. The best practice is to compile Infomap under the file name "Infomap" and place it in the
same working folder in which the R code is run.
2. Though technically Infomap can run on Windows as detailed above, I find that this is not always so easy to do. If you don't manage to install it, Linux/MacOS are the best options.

## Install the R package
The package was built under R 3.6.3 and requires `attempt, igraph, bipartite, magrittr, tidyverse`.

```R
# Install  (if not installed) and load necessary packages
package.list=c("attempt", "cowplot", "igraph", "ggalluvial","magrittr","metafolio","tidyverse","vegan", "devtools")
loaded <-  package.list %in% .packages()
package.list <-  package.list[!loaded]
installed <-  package.list %in% .packages(TRUE)
if (!all(installed)) install.packages(package.list[!installed], repos="http://cran.rstudio.com/")
invisible(lapply(package.list, library, character.only = TRUE, verbose=F))

# Install infomapecology 
devtools::install_github('Ecological-Complexity-Lab/infomap_ecology_package', force=T)
library(infomapecology)

# Check the version. Should be at least 0.1.1.1
packageDescription('infomapecology')

# Install infomap if you have not done so externally (see previous section in this readme)
setwd('where your Infomap file and R script will live')
install_infomap()

# Check Infomap is running
setwd('where your Infomap file and R script now live')
check_infomap() # Make sure file can be run correctly. Should return TRUE
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
# Prepare data
data(otago_nodes)
data(otago_links)
otago_nodes_2 <- otago_nodes %>%
  filter(StageID==1) %>%
  select(node_name=WorkingName, node_id_original=NodeID, WorkingName,StageID, everything())
anyDuplicated(otago_nodes_2$node_name)
otago_links_2 <- otago_links %>%
  filter(ConsumerSpecies.StageID==1) %>%
  filter(ResourceSpecies.StageID==1) %>%
  select(from=ResourceNodeID, to=ConsumerNodeID) %>%
  left_join(otago_nodes_2, by=c('from'='node_id_original')) %>%
  select(from, node_name, to) %>%
  left_join(otago_nodes_2, by=c('to'='node_id_original')) %>%
  select(from=node_name.x, to=node_name.y) %>%
  mutate(weight=1)

# Prepare network objects and run infomap
# Some species will have only incoming or outgoing links, so the next line will result in a warning.
network_object <- create_monolayer_object(otago_links_2, directed = T, bipartite = F, node_metadata = otago_nodes_2)
infomap_input <- create_infomap_linklist(network_object)
infomap_object <- run_infomap_monolayer(infomap_input, infomap_executable='Infomap',
                                        flow_model = 'directed',
                                        silent=T,trials=100, two_level=F, seed=200952)
```

## Multilayer network with interlayer edges
Use the temporal network from Pilosof S, Porter MA, Pascual M, Kéfi S. The multilayer nature of ecological networks. Nature Ecology & Evolution. 2017;1: 0101.
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

### Multilayer without interlayer edges and a relax rate
```R
# Get data
NEE2017 <- create_multilayer_object(extended = siberia1982_7_links, nodes = siberia1982_7_nodes, intra_output_extended = F, inter_output_extended = F)

# Ignore interlayer edges
NEE2017$inter <- NULL

# Run Infomap
modules_relax_rate <- run_infomap_multilayer(NEE2017, relax = T, silent = T, trials = 50, seed = 497294, multilayer_relax_rate = 0.15, multilayer_relax_limit_up = 1, multilayer_relax_limit_down = 0, temporal_network = T)
```
