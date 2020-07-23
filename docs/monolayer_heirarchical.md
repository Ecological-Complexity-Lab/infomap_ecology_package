### Data set
A binary directed food web from [Mouritsen KN, Poulin R, McLaughlin JP, Thieltges DW. Food web including metazoan parasites for an intertidal ecosystem in New Zealand: Ecological Archives E092-173. Ecology. 2011;92: 2006–2006.](https://esajournals.onlinelibrary.wiley.com/doi/abs/10.1890/11-0371.1)

In infomapecology:
```R
data(otago_nodes)
data(otago_links)
```

### Input
A [link-list](https://www.mapequation.org/code.html#Link-list-format).

### R Code
```R
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

# Prepare network objects and run infomap
# Some species will have only incoming or outgoing links, so the next line will result in a warning
network_object <- create_monolayer_object(x=otago_links_2, directed = T, bipartite = F, node_metadata = otago_nodes_2)
infomap_object <- run_infomap_monolayer(network_object, infomap_executable='Infomap',
                                        flow_model = 'directed',
                                        silent=T,trials=100, two_level=F, seed=200952)
```

### Infomap
Under the hood, the function `run_infomap_monolayer` runs:
```C++
./Infomap infomap.txt . -i link-list --tree --seed 200952 -N 100 -f directed --silent
```
* Here, the most important feature is **the lack of the argument** `-2` (or `--two-level`), which allows for hierarchical modules (the default in Infomap).
* `-f directed` indicates flow on a directed network.


### Output
A [tree file](https://www.mapequation.org/infomap/#OutputTree) is produced by Infomap, but is parsed by `run_infomap_monolayer` from infomapecology (in R: `?run_infomap_monolayer`). In addition, this data has node attributes, which are added to the final output. In this example: OrganismalGroup and NodeType. In this output excerpt, there are four nodes that belong to the 3rd submodule within top module 1. For these, `module_level3` is the leaf id. Modules 2 and 3 do not have sub-modules. Therefore, for these modules the the second level (`module_level2`) is the leaf id and `module_level3` shows an `NA` value.

|node_id|node_name|module_level1|module_level2|module_level3|OrganismalGroup|NodeType
|---|---|---|---|---|---|---|
|57|Nemertine 1|1|3|1|Nemertean|Taxon
|58|Nemertine 2|1|3|2|Nemertean|Taxon
|59|Nemertine 3|1|3|3|Nemertean|Taxon
|72|Geminosyllis sp.|1|3|4|Annelid|Taxon
|98|Green-lipped mussel|2|1|NA|Bivalve|Taxon
|140|Pea crab|2|2|NA|Crab|Taxon
|39|Ghost Shrimp|3|1|NA|Burrowing Shrimp|Taxon
|101|Yellow-eye mullet|3|2|NA|Fish|Taxon
|102|New Zealand spotty|3|3|NA|Fish|Taxon