library(igraph)
library(bipartite)
library(tidyverse)
library(magrittr)
library(cowplot)
library(ggalluvial)
library(infomapecology)
library(visNetwork)

setwd('~/GitHub/infomap_ecology')

check_infomap()

# Simple bipartite network ------------------------------------------------
network_object <- create_monolayer_object(memmott1999, bipartite = T, directed = F, group_names = c('A','P'))
infomap_object <- run_infomap_monolayer(network_object, infomap_executable='Infomap',
                                        flow_model = 'undirected',
                                        silent=T, trials=20, two_level=T, seed=123)

# Plot the matrix (plotting function in beta)
plot_modular_matrix(infomap_object)

# Directed pollination network --------------------------------------------

# Import data
tur2016 <- read.csv("Data_Tur_et_al_2016_EcolLet.txt", sep = ";")

tur2016_altitude2000 <- tur2016 %>% 
  filter(altitude==2000) %>% 
  select("donor", "receptor", "total") %>% 
  group_by(donor, receptor) %>% 
  summarise(n=mean(total)) %>% 
  rename(from = donor, to = receptor, weight = n) %>% 
  ungroup() %>%   slice(c(-10,-13,-28)) # Remove singletons

network_object <- create_monolayer_object(tur2016_altitude2000, directed = T, bipartite = F)
loops <- run_infomap_monolayer(network_object, infomap_executable='Infomap',
                                    flow_model = 'rawdir',
                                    silent=T,trials=100, two_level=T, seed=200952, ...='--include-self-links')

no_loops <- run_infomap_monolayer(network_object, infomap_executable='Infomap',
                                               flow_model = 'rawdir',
                                               silent=T,trials=100, two_level=T, seed=200952)


modules_loops <- loops$modules 
modules_no_loops <- no_loops$modules

svg('/Users/shai/Dropbox (BGU)/Apps/Overleaf/A dynamical perspective on community detection in ecological networks/figures/Tur_loops_comparison.svg',8,8)
inner_join(modules_loops %>% select(node_id, node_name, flow_loops=flow), 
           modules_no_loops %>% select(node_id, node_name, flow_no_loops=flow)) %>%
  # mutate()
  ggplot(aes(x=flow_loops, y=flow_no_loops, label=node_name))+
  geom_point(size=8, color='#48A9A6')+
  scale_x_continuous(breaks = seq(0,0.25,0.05), limits = c(0,0.25))+
  scale_y_continuous(breaks = seq(0,0.25,0.05), limits = c(0,0.25))+
  geom_abline(linetype='dashed')+
  # geom_text(size=5)+
  labs(x='Relative flow (with self-links)', y='Relative flow (without self-links)')+
  theme_bw()+
  theme(panel.grid = element_blank(),
        panel.border = element_blank(),
        axis.line = element_line(color = 'black'),
        axis.text = element_text(size=24,color = 'black'),
        text=element_text(size=24,color = 'black'))
dev.off()

# Compare the results using normalised mutual information
N <- modules_loops %>% # Create confusion matrix
  select(-module_level2) %>%
  inner_join(modules_no_loops %>% select(node_id,module_level1), by='node_id') %>%
  arrange(module_level1.x,module_level1.y) %>%
  group_by(module_level1.y) %>% select(module_level1.x) %>% table()
NMI(N)


M <- max(loops$m,no_loops$m)
color_map <- tibble(module=1:M, color=
c("#ff8f80","#ffc374",
  "#a3d977","#99d2f2",
  "#b391b5","#f5b5c8",
  "#ffeca9","#99d5ca",
  "#c92d39","#b2b2b2",
  '#d1bcd2','#0c7cba','orange')
)

nodes_visNetwork <- 
  left_join(modules_loops %>% select(node_id, node_name, module_loops=module_level1),
            modules_no_loops %>% select(node_id, node_name, module_no_loops=module_level1)) %>% 
  left_join(color_map, by=c('module_loops' = 'module')) %>% 
  left_join(color_map, by=c('module_no_loops' = 'module')) %>% 
  select(id=node_id, label=node_name, 
         color.border=color.x, 
         color.highlight=color.x,
         color.background = color.y) %>% 
  mutate(shape='circle', borderWidth=8)
edges_visNetwork <- loops$edge_list %>% 
  mutate(width=log(weight)+1) %>%
  # mutate(width=weight) %>% 
  left_join(network_object$nodes, by=c('from'='node_name')) %>% 
  left_join(network_object$nodes, by=c('to'='node_name')) %>%
  rename(rem_f=from, rem_t=to, from=node_id.x, to=node_id.y) %>% 
  select(from, to, width, -rem_f, -rem_t) %>% 
  mutate(arrows='to', smooth=T, color='black') %>% 
  filter(from %in% nodes_visNetwork$id) %>% 
  filter(to %in% nodes_visNetwork$id)

nodes_visNetwork$label <- ''

# The function parts allows to drag and order manually 
visNetwork::visIgraphLayout(
  visNetwork(nodes_visNetwork, edges_visNetwork)  %>% 
    visEvents(selectNode = "function(properties) {alert('selected nodes ' + this.body.data.nodes.get(properties.nodes[0]).id);}")) %>% 
  visLayout(randomSeed = 123) 


# Directed food web with hierarchical clustering --------------------------
# change file names
interactions <- read.csv("kongsfjorden_linklist.csv")
nodes <- read.csv("kongsfjorden_metadata.csv")

nodes <- nodes %>%
  select(node_name=Species, node_id_original=NodeID, everything())

interactions<- interactions %>%
  select(from=consumer, to=resource) %>%
  mutate_if(is.factor, as.character) %>%
  mutate(weight=1)

# Prepare network objects
network_object <- create_monolayer_object(x=interactions, directed = T, bipartite = F, node_metadata = nodes)

# Run infomap without hieararchy
infomap_object <- run_infomap_monolayer(network_object, infomap_executable='Infomap',
                                        flow_model = 'directed',
                                        silent=T,trials=100, two_level=F, seed=123)


# Arrange for plotting
mods <-  infomap_object$modules
mods <- arrange(mods, module_level1, module_level2) %>% #, module_level3, module_level4) 
  select(node_name, module_level1,module_level2, Environment, Mobility, FeedingType) %>%
  distinct() %>%
  filter(module_level1 %in% c(1,2,3,4)) %>% 
  mutate(Mobility = as.character(Mobility))
mods$FeedingType[mods$FeedingType == "none"] <- "primary"

# Plot module level 1 
mods_lvl1_size <- mods %>% 
  group_by(module_level1,Mobility, FeedingType) %>% 
  summarise(n=n())
mods_lvl1 <- mods %>% 
  left_join(mods_lvl1_size) %>% 
  mutate(FeedingType = as.factor(FeedingType)) %>% 
  mutate(FeedingType = fct_relevel(FeedingType, "primary", "grazer","suspension feeder", "predator/scavenger", "predator"))
mods_lvl1 %>% 
  ggplot()+
  geom_point(aes(x=Mobility, y= FeedingType, size = n))+
  facet_wrap(vars(module_level1))+
  theme_bw()+
  labs(x='Mobility', y='Feeding Type', size = "Number of species")


# Plot submodule 1 of module level 1
mods_lvl2_size <- mods %>% 
  group_by(module_level2,Mobility, FeedingType) %>% 
  summarise(n=n())
mods_lvl2 <- mods %>% 
  left_join(mods_lvl2_size) %>% 
  filter(module_level1==1) %>% 
  mutate(FeedingType = as.factor(FeedingType)) %>% 
  mutate(FeedingType = fct_relevel(FeedingType, "primary", "grazer","suspension feeder", "predator/scavenger", "predator"))
mods_lvl2 %>% 
  ggplot()+
  geom_point(aes(x=Mobility, y= FeedingType, size = n))+
  facet_wrap(vars(module_level2))+
  theme_bw()+
  labs(x='Mobility', y='Feeding Type', size = "Number of species")



# Directed food web with node attributes -----------------------------------------
# Prepare data
data(otago_nodes)
data(otago_links)
otago_nodes_2 <- otago_nodes %>%
  filter(StageID==1) %>%
  select(node_name=WorkingName, node_id_original=NodeID, WorkingName,StageID, everything())
anyDuplicated(otago_nodes_2$node_name)
otago_links_2 <- otago_links %>%
  filter(LinkType=='Predation') %>% # Only include predation links
  filter(ConsumerSpecies.StageID==1) %>%
  filter(ResourceSpecies.StageID==1) %>%
  select(from=ResourceNodeID, to=ConsumerNodeID) %>%
  left_join(otago_nodes_2, by=c('from'='node_id_original')) %>%
  select(from, node_name, to) %>%
  left_join(otago_nodes_2, by=c('to'='node_id_original')) %>%
  select(from=node_name.x, to=node_name.y) %>%
  mutate(weight=1)

# Prepare network objects
# Some species will have only incoming or outgoing links, so the next line will result in a warning
network_object <- create_monolayer_object(x=otago_links_2, directed = T, bipartite = F, node_metadata = otago_nodes_2)

# Create an attribute -- attribute ID map
node_attribute_map <- otago_nodes_2 %>% distinct(OrganismalGroup) %>%
  mutate(attribute_id=1:n())

# Create a file with node attributes
node_attributes <-
  network_object$nodes %>%
  distinct(node_id, OrganismalGroup) %>%
  left_join(node_attribute_map) %>%
  select(-OrganismalGroup) %>%
  write_delim('otago_node_attributes.txt', delim = ' ', col_names = F)

# Run without metadata
infomap_object <- run_infomap_monolayer(network_object, infomap_executable='Infomap',
                                        flow_model = 'directed',
                                        silent=T,trials=20, two_level=T, seed=200952)

# Run with metadata and eta=0.7
infomap_object_metadata_07 <- run_infomap_monolayer(network_object, infomap_executable='Infomap',
                                                 flow_model = 'directed',
                                                 silent=T,trials=20, two_level=T, seed=200952,
                                                 ... = '--meta-data otago_node_attributes.txt --meta-data-rate 0.7')
# Run with metadata and eta=1.3
infomap_object_metadata_13 <- run_infomap_monolayer(network_object, infomap_executable='Infomap',
                                                 flow_model = 'directed',
                                                 silent=T,trials=20, two_level=T, seed=200952,
                                                 ... = '--meta-data otago_node_attributes.txt --meta-data-rate 1.3')


# Compare the modules with and without metadata
eta0 <- infomap_object$modules %>%
  group_by(module_level1) %>%
  summarise(n=n_distinct(OrganismalGroup)) %>%
  mutate(eta=0) %>%
  arrange(desc(n), module_level1)
eta07 <- infomap_object_metadata_07$modules %>%
  group_by(module_level1) %>%
  summarise(n=n_distinct(OrganismalGroup)) %>%
  mutate(eta=0.7) %>%
  arrange(desc(n), module_level1)
eta13 <- infomap_object_metadata_13$modules %>%
  group_by(module_level1) %>%
  summarise(n=n_distinct(OrganismalGroup)) %>%
  mutate(eta=1.3) %>%
  arrange(desc(n), module_level1)

pdf('/Users/shai/Dropbox (BGU)/Apps/Overleaf/A dynamical perspective on community detection in ecological networks/figures/comparison_eta_metadata1.pdf',12,8)
bind_rows(eta0, eta07, eta13) %>% 
  mutate(eta=factor(eta, levels=c('0','0.7','1.3'))) %>% 
  rename(num_OG=n, module_id=module_level1) %>% 
  group_by(num_OG, eta) %>%
  summarise(num_modules=n()) %>%
  ggplot(aes(x=num_OG, y=num_modules,fill=eta)) +
  geom_col(position = 'dodge', color='black', width=0.7) +
  scale_x_continuous(limits=c(0,18), breaks=0:18)+
  scale_y_continuous(limits=c(0,37), breaks=seq(0,36,by=3))+
  scale_fill_manual(values = c('#fc8d62','#8da0cb','#e78ac3'))+
  labs(x='Number of organismal groups', y='Number of modules', fill='eta')+
  theme_bw()+
  theme(panel.grid.minor = element_blank(),
        panel.border = element_blank(),
        axis.line = element_line(color = 'black'),
        legend.position = c(0.8,0.8),
        legend.text = element_text(size=24),
        legend.title = element_text(size=24),
        legend.key.size = unit(2, 'line'),
        axis.text = element_text(size=24),
        text=element_text(size=24))
dev.off()

num_mods <- infomap_object$m
num_mods_metadata_07 <- infomap_object_metadata_07$m

pdf('/Users/shai/Dropbox (BGU)/Apps/Overleaf/A dynamical perspective on community detection in ecological networks/figures/SI_comparison_eta_metadata.pdf',14,8)
cowplot::plot_grid(
  infomap_object$modules %>% group_by(module_level1, OrganismalGroup) %>% arrange(module_level1, OrganismalGroup) %>%
  count() %>%
    ggplot(aes(module_level1, OrganismalGroup, size=n))+geom_point(color='purple')+
    scale_size_area(max_size = 20)+
    scale_x_continuous(breaks = 1:num_mods)+
    labs(x='Module ID', y='Guild', title='Eta=0')+
    theme(legend.position = 'none'),
  infomap_object_metadata_07$modules %>% group_by(module_level1, OrganismalGroup) %>% arrange(module_level1, OrganismalGroup) %>%
    count() %>%
    ggplot(aes(module_level1, OrganismalGroup, size=n))+
    geom_point(color='orange')+
    scale_size_area(max_size = 20)+
    labs(x='Module ID', y='Guild', title='Eta=0.7')+
    scale_x_continuous(breaks = seq(1,num_mods_metadata_07,3))+
    theme(legend.position = 'none'),
  align = 'vh', labels=c('(a)','(b)'))
dev.off()

# Compare flow models --------------------------------------------
tur2016 <- read.csv("Data_Tur_et_al_2016_EcolLet.txt", sep = ";")
tur2016_altitude2000 <- tur2016 %>% 
  filter(altitude==2000) %>% 
  select("donor", "receptor", "total") %>% 
  group_by(donor, receptor) %>% 
  summarise(n=mean(total)) %>% 
  rename(from = donor, to = receptor, weight = n) %>% 
  ungroup() %>%
  slice(c(-10,-13,-28)) %>%  # Remove singletons
  filter(from!=to) # Remove self loops

network_object <- create_monolayer_object(tur2016_altitude2000, directed = T, bipartite = F)
res_dir <- run_infomap_monolayer(network_object, infomap_executable='Infomap',
                                 flow_model = 'directed',
                                 silent=T,trials=100, two_level=T, seed=200952)
res_rawdir <- run_infomap_monolayer(network_object, infomap_executable='Infomap',
                                    flow_model = 'rawdir',
                                    silent=T,trials=100, two_level=T, seed=200952)

res_dir_modules <- res_dir$modules %>% drop_na()
res_rawdir_modules <- res_rawdir$modules %>% drop_na()


# Compare the results using normalised mutual information
N <- res_dir_modules %>% # Create confusion matrix
  select(-module_level2) %>%
  inner_join(res_rawdir_modules %>% select(node_id,module_level1), by='node_id') %>%
  arrange(module_level1.x,module_level1.y) %>%
  group_by(module_level1.y) %>% select(module_level1.x) %>% table()

# These two different modes of flow can result in different partitions.
NMI(N)

pdf('/Users/shai/Dropbox (BGU)/Apps/Overleaf/A dynamical perspective on community detection in ecological networks/figures/MI_comparison_flow_modules.pdf',12,10)
res_dir_modules %>%
  select(-module_level2) %>%
  inner_join(res_rawdir_modules %>% select(node_id,module_level1), by='node_id') %>%
  arrange(module_level1.x,module_level1.y) %>%
  group_by(module_level1.x,module_level1.y) %>% count() %>%
  ggplot()+
    geom_point(aes(module_level1.x, module_level1.y, color=n), size=15)+
    scale_color_viridis_c()+
    scale_x_continuous(breaks=1:max(res_dir_modules$module_level1, na.rm = T))+
    scale_y_continuous(breaks=1:max(res_rawdir_modules$module_level1, na.rm = T))+
    labs(x='Module ID directed model', y='Module ID rawdir model')+
    theme_bw()+theme(text=element_text(size=30), panel.grid.minor = element_blank())
dev.off()


M <- max(res_dir$m,res_rawdir$m)
color_map_dir <- tibble(module=1:M, color=c("#ff8f80","#ffc374",
                                            "#a3d977","#99d2f2",
                                            "#b391b5","#f5b5c8",
                                            "#ffeca9"))
color_map_rawdir <- tibble(module=1:M, color=c("#99d5ca",
                                               "#c92d39","#b2b2b2",
                                               '#d1bcd2','#0c7cba','orange',"#23967f"))
nodes_visNetwork <- 
  left_join(res_dir_modules %>% select(node_id, node_name, module_directed=module_level1),
            res_rawdir_modules %>% select(node_id, node_name, module_rawdir=module_level1)) %>% 
  left_join(color_map_dir, by=c('module_directed' = 'module')) %>% 
  left_join(color_map_rawdir, by=c('module_rawdir' = 'module')) %>% 
  select(id=node_id, 
         label=node_name,
         color.border=color.x, 
         color.highlight=color.y,
         color.background = color.y) %>% 
  mutate(shape='circle', borderWidth=8)
edges_visNetwork <- res_dir$edge_list %>% 
  mutate(width=log(weight)+1) %>%
  # mutate(width=weight) %>% 
  left_join(network_object$nodes, by=c('from'='node_name')) %>% 
  left_join(network_object$nodes, by=c('to'='node_name')) %>%
  rename(rem_f=from, rem_t=to, from=node_id.x, to=node_id.y) %>% 
  select(from, to, width, -rem_f, -rem_t) %>% 
  mutate(arrows='to', smooth=T, color='black') %>% 
  filter(from %in% nodes_visNetwork$id) %>% 
  filter(to %in% nodes_visNetwork$id)

nodes_visNetwork$label <- ''

# The function parts allows to drag and order manually 
visNetwork::visIgraphLayout(
  visNetwork(nodes_visNetwork, edges_visNetwork)  %>% 
    visEvents(selectNode = "function(properties) {alert('selected nodes ' + this.body.data.nodes.get(properties.nodes[0]).id);}")) %>% 
  visLayout(randomSeed = 123) 


# Temporal multilayer network: interlayer edges ---------------------------

# Get data
data("siberia1982_7_links")
data("siberia1982_7_nodes")
NEE2017 <- create_multilayer_object(extended = siberia1982_7_links, nodes = siberia1982_7_nodes, intra_output_extended = T, inter_output_extended = T)

#Run infomap
NEE2017_modules <- run_infomap_multilayer(M=NEE2017, relax = F, flow_model = 'directed', silent = T, trials = 100, seed = 497294, temporal_network = T)

#Module persistance
modules_persistence <- NEE2017_modules$modules %>%
  group_by(module) %>%
  summarise(b=min(layer_id), d=max(layer_id), persistence=d-b+1) %>%
  count(persistence) %>%
  mutate(percent=(n/max(NEE2017_modules$module$module))*100)

#Percent of species that switched modules at least once:
module_switch <- NEE2017_modules$modules%>%
  group_by(species, module) %>%
  summarise() %>%
  group_by(species) %>%
  summarise(n_modules=n()) %>%
  mutate(switches=ifelse(n_modules>1, T, F))
count(module_switch, switches==T) %>%
  mutate(percent=(n/length(module_switch$species)*100))


# plots:

# 1. Modules' persistence
fig1 <- plot_multilayer_modules(NEE2017_modules, type = 'rectangle', color_modules = T)+
  labs(fill='Size')+
  scale_x_continuous(breaks=seq(0,6,1))+
  scale_y_continuous(breaks=seq(0,40,5))+
  scale_fill_viridis_c()+
  theme_bw()+
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.title = element_text(size=20),
        axis.text = element_text(size = 20),
        legend.text =  element_text(size=15),
        legend.title = element_text(size=20))

#2. Species flow through modules
fig2 <- plot_multilayer_alluvial(NEE2017_modules, module_labels = F)+
  scale_x_continuous(breaks=seq(0,6,1))+
  scale_y_continuous(breaks=seq(0,70,5))+
  labs(y='Number of species')+
  theme_bw()+
  theme(legend.position = "none",
        panel.grid = element_blank(),
        axis.text = element_text(color='black', size = 20),
        axis.title = element_text(size=20))
interlayer_grid <- cowplot::plot_grid(fig1, fig2, 
                                      ncol = 2,
                                      rel_widths = c(0.4,0.6), labels =c('(a)','(b)'), 
                                      label_size = 20, scale = 0.95)
pdf('/Users/shai/Dropbox (BGU)/Apps/Overleaf/A dynamical perspective on community detection in ecological networks/figures/interlayer_grid.pdf',14,8)
interlayer_grid
dev.off()

 # Temporal multilayer network: Global relax rates ---------

# Get data
NEE2017 <- create_multilayer_object(extended = siberia1982_7_links, nodes = siberia1982_7_nodes, intra_output_extended = F, inter_output_extended = F)

# Ignore interlayer edges
NEE2017$inter <- NULL

#Run Infomap and return the network's modular structure at increasing relax-rates.
relaxrate_modules <- NULL
for (r in seq(0.001,1, by = 0.0999)){
  print(r)
  modules_relax_rate <- run_infomap_multilayer(NEE2017, relax = T, silent = T, trials = 50, seed = 497294, multilayer_relax_rate = r, multilayer_relax_limit_up = 1, multilayer_relax_limit_down = 0, temporal_network = T)
  modules_relax_rate$modules$relax_rate <- r
  relaxrate_modules <- rbind(relaxrate_modules, modules_relax_rate$modules)
}

#plots
#1. Number of modules
fig3 <- relaxrate_modules %>%
  group_by(relax_rate, module) %>%
  summarise()%>%
  mutate(n_modules=length(relax_rate)) %>%
  group_by(relax_rate, n_modules) %>%
  summarise() %>%
  ggplot() +
  geom_line(aes(x = relax_rate, y=n_modules)) +
  geom_point(aes(x = relax_rate, y=n_modules))+
  scale_y_continuous(breaks=1:18, labels = 1:18, limits = c(1,18))+
  scale_x_continuous(breaks=seq(0,1,0.2))+
  theme_bw()+
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.title = element_text(size=15),
        axis.text = element_text(size = 15))+
  labs(x='Relax rate', y='Number of modules')

#2. Module presistence
presistence <- relaxrate_modules %>%
  group_by(relax_rate, module, layer_id) %>%
  summarise(n_species=n()) %>%
  group_by(relax_rate, module) %>%
  summarise(n_layers=n()) %>%
  ungroup()
avarage_presistance <- presistence %>%
  group_by(relax_rate) %>%
  mutate(avarage=mean(n_layers)) %>%
  group_by(relax_rate, avarage) %>%
  summarise()
fig4 <- ggplot()+
  geom_boxplot(data =  presistence, aes(x=relax_rate, y=n_layers, group=relax_rate),width = 1.1)+
  geom_line(data =  avarage_presistance, aes(x=relax_rate, y=avarage, color="red"))+
  geom_point(data =  avarage_presistance, aes(x=relax_rate, y=avarage, color="red"))+
  scale_y_continuous(breaks=seq(0,6,1))+
  scale_x_continuous(breaks=seq(0,1,0.2))+
  theme_bw()+
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.title = element_text(size=15),
        axis.text = element_text(size = 15),
        legend.position = 'none')+
  labs(x='Relax rate', y='Module persistence (# of layers)')

#3. Species flexibility
fig5 <- relaxrate_modules %>%
  group_by(relax_rate, species) %>%
  distinct(module) %>%
  summarise(n_modules=n()) %>%
  group_by(relax_rate, n_modules) %>%
  summarise(num_species=n())%>%
  mutate(precent=(num_species/78)*100) %>%
  ggplot()+
  geom_col(aes(x=relax_rate, y=precent, fill=n_modules))+
  scale_x_continuous(breaks=seq(0,1,0.2))+
  scale_y_continuous(labels = function(x) paste0(x, "%"))+
  scale_fill_viridis_c()+
  theme_bw()+
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.title = element_text(size=15),
        axis.text = element_text(size = 15),
        legend.text =  element_text(size=10),
        legend.title = element_text(size=15))+
  labs(x='Relax rate', y='Percent of all species', fill="Number\n of modules")


relaxrate_grid <- cowplot::plot_grid(fig3, fig4, fig5, ncol = 3,
                                     rel_widths = c(2,2,3),
                                     labels = c('(a)','(b)','(c)'),
                                     label_size = 20,
                                     scale=0.95)
pdf('/Users/shai/Dropbox (BGU)/Apps/Overleaf/A dynamical perspective on community detection in ecological networks/figures/relaxrate_grid_new.pdf',14,7)
relaxrate_grid
dev.off()


# Hypothesis testing with infomapecology ----------------------------------

network_object <- create_monolayer_object(memmott1999, bipartite = T, directed = F, group_names = c('A','P'))

# Run with shuffling
infomap_object <- run_infomap_monolayer(network_object, infomap_executable='Infomap',
                                        flow_model = 'undirected',
                                        silent=T, trials=20, two_level=T, seed=123, 
                                        signif = T, shuff_method = 'r00', nsim = 50)
# Plot histograms
plots <- plot_signif(infomap_object, plotit = T)
plot_grid(
  plots$L_plot+
    theme_bw()+
    theme(legend.position='none', 
          axis.text = element_text(size=20), 
          axis.title = element_text(size=20)),
  plots$m_plot+
    theme_bw()+
    theme(legend.position='none', 
          axis.text = element_text(size=20), 
          axis.title = element_text(size=20))
)

# Or can shuffle like this, if additional arguments are needed for the shuffling algorithm
shuffled <- shuffle_infomap(network_object, shuff_method='curveball', nsim=50, burnin=2000)
infomap_object <- run_infomap_monolayer(network_object, infomap_executable='Infomap',
                                        flow_model = 'undirected',
                                        silent=T, trials=20, two_level=T, seed=123, 
                                        signif = T, shuff_method = shuffled, nsim = 50)
plots <- plot_signif(infomap_object, plotit = F)
plot_grid(
  plots$L_plot+
    theme_bw()+
    theme(legend.position='none', 
          axis.text = element_text(size=20), 
          axis.title = element_text(size=20)),
  plots$m_plot+
    theme_bw()+
    theme(legend.position='none', 
          axis.text = element_text(size=20), 
          axis.title = element_text(size=20))
)

# Hypothesis testing ------------------------------------------------------
tur_network <- create_monolayer_object(tur2016_altitude2000, directed = T, bipartite = F)

# A dedicated function to shuffle the networks, considering the flow.
shuffle_tur_networks <- function(x){ # x is a network object
  m <- x$mat

  # Assign off-diagona values
  off_diagonal_lower <- m[lower.tri(m, diag = FALSE)]
  off_diagonal_upper <- m[upper.tri(m, diag = FALSE)]
  out <- matrix(0, nrow(m), ncol(m), dimnames = list(rownames(m), colnames(m)))
  out[lower.tri(out, diag = FALSE)] <- sample(off_diagonal_lower, size = length(off_diagonal_lower), replace = F)
  out[upper.tri(out, diag = FALSE)] <- sample(off_diagonal_upper, size = length(off_diagonal_upper), replace = F)

  # Re-assign the diagonal (left intact)
  diag(out) <- diag(m)


  # Sanity checks
  t1 <- setequal(out[upper.tri(out, diag = FALSE)], m[upper.tri(m, diag = FALSE)]) #Should be TRUE
  t2 <- setequal(out[lower.tri(out, diag = FALSE)], m[lower.tri(m, diag = FALSE)]) #Should be TRUE
  t3 <- identical(out[upper.tri(out, diag = FALSE)], m[upper.tri(m, diag = FALSE)]) #Should be FALSE
  t4 <- identical(out[lower.tri(out, diag = FALSE)], m[lower.tri(m, diag = FALSE)]) #Should be FALSE
  t5 <- all(table(m)==table(out))# Should be TRUE because it includes all the values, including diagonal
  if (any(c(t1,t2,!t3,!t4,t5)==F)){stop('One or more sanity checks failed')}
  return(out)
}

# Create a list with shuffled link lists
nsim <- 1000
shuffled <- NULL
for (i in 1:nsim){
  print(i)
  x <- shuffle_tur_networks(tur_network) #Shuffle the network
  x <- create_monolayer_object(x,directed = T,bipartite = F) # Create a monolayer object
  shuffled[[i]] <- create_infomap_linklist(x)$edge_list_infomap #Create a link-list
}  

# Use the shuffled link lists. 
tur_signif <- run_infomap_monolayer(tur_network, infomap_executable='Infomap',
                      flow_model = 'rawdir',
                      silent=T,
                      trials=100, two_level=T, seed=200952,
                      signif = T, shuff_method = shuffled)


print(tur_signif$pvalue)
sum(tur_signif$m_sim < res_rawdir$m)/nsim


plots <- plot_signif(tur_signif, plotit = F)
pdf('/Users/shai/Dropbox (BGU)/Apps/Overleaf/A dynamical perspective on community detection in ecological networks/figures/null_model_example.pdf',12,8)
plot_grid(
  plots$L_plot+
    theme_bw()+
    theme(legend.position='none', 
          axis.text = element_text(size=20), 
          axis.title = element_text(size=20)),
  plots$m_plot+
    theme_bw()+
    theme(legend.position='none', 
          axis.text = element_text(size=20), 
          axis.title = element_text(size=20))
)
dev.off()


