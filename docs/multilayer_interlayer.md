### Data set
A temporal multilayer network. Each layer is a host-parasite bipartite network. Intralayer edges between a parasite species and a host species are the number of parasite individuals divided by the number of host individuals. Interlayer coupling edges connect each physical node to itself in the next layer (e.g., host A in layer 1 to host A in layer 2), and are calculated as the number of individuals in layer l+1 divided by the number of individuals in layer l. They therefore represent population dynamics. Interlayer edges only go one way (_l-->l+1_) because time flow one way. We represented the undirected edges within each layer as directed edges that go both ways (with the same weight) to be able to have a directed flow. This does not affect the calculation of L. This data set was taken from [_Pilosof S, Porter MA, Pascual M, Kéfi S. The multilayer nature of ecological networks. Nature Ecology & Evolution. 2017;1: 0101_](https://www.nature.com/articles/s41559-017-0101?proof=true19).

Data sets in infomapecology:
```R
# Get data
data("siberia1982_7_links")
data("siberia1982_7_nodes")
```

### Input
A [general multilayer link-list](https://www.mapequation.org/infomap/#InputMultilayer). This multilayer format gives full control of the dynamics, and no other movements are encoded. **When using this input format, it is expected that interlayer edges will be provided, otherwise there will be no inter-layer links in the final state network.**

```Python
*Multilayer
#layer node layer node weight
1 1 1 23 0.15853658536585366
1 1 1 25 0.024390243902439025
1 1 1 27 0.0975609756097561
... some more links...
4 61 4 17 0.009433962264150943
4 62 4 17 0.009433962264150943
4 63 4 17 0.03773584905660377
... some more links...
3 78 4 78 0
4 78 5 78 0
5 78 6 78 1.5
```

### R Code
The description of functions `create_multilayer_object` and `run_infomap_multilayer` in the `infomapecology` package contains everything you need to know. Plotting is done using two dedicated functions: `plot_multilayer_modules` and `plot_multilayer_alluvial`.

```R
# Create a multilayer object
NEE2017 <- create_multilayer_object(extended = siberia1982_7_links, nodes = siberia1982_7_nodes, intra_output_extended = T, inter_output_extended = T)

#Run infomap
NEE2017_modules <- run_infomap_multilayer(M=NEE2017, relax = F, flow_model = 'directed', silent = T, trials = 100, seed = 497294, temporal_network = T)

#Module persistance
modules_persistence <- NEE2017_modules$modules %>%
  group_by(module) %>%
  summarise(b=min(layer_id), d=max(layer_id), persistence=d-b+1) %>%
  count(persistence) %>%
  mutate(percent=(n/max(NEE2017_modules$module$module))*100)

# 1. Modules' persistence
plot_multilayer_modules(NEE2017_modules, type = 'rectangle', color_modules = T)+
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

#2. Species flow through modules in time
plot_multilayer_alluvial(NEE2017_modules, module_labels = F)+
  scale_x_continuous(breaks=seq(0,6,1))+
  scale_y_continuous(breaks=seq(0,70,5))+
  labs(y='Number of species')+
  theme_bw()+
  theme(legend.position = "none",
        panel.grid = element_blank(),
        axis.text = element_text(color='black', size = 20),
        axis.title = element_text(size=20))
```

### Infomap
Under the hood, the function `run_infomap_multilayer` runs:
```C++
./Infomap infomap_multilayer.txt . -2 --seed 497294 -N 100 -i multilayer -f directed --silent
```

Explanation of key arguments:
* `-i multilayer` indicates a multilayer input format, which is automatically recognised as a [general multilayer link-list](https://www.mapequation.org/infomap/#InputMultilayer).
* `-f directed` indicates flow on a directed network. The visitation rates of nodes is obtained with a PageRank algorithm based on the direction and weight of edges. This includes interlayer edges.

### Output
For multilayer network the output file has a `_states` suffix, with the following format. Note the state_id column. For example, node 6 in layer 5 has a state_id of 377 (last line). The state_ids are created by Infomap but not used in our R code.

```python
# path flow name state_id node_id layer_id
1:1 0.000779105 "0" 0 1 1
1:2 0.000364122 "8" 8 44 1
1:3 0.00193867 "67" 67 1 2
1:4 0.00109331 "77" 77 44 2
1:5 0.00413471 "135" 135 1 3
1:6 0.000184892 "143" 143 36 3
1:7 0.00194127 "148" 148 44 3
         ...
38:2 0.0201909 "325" 325 34 6
38:3 0.0192017 "349" 349 6 6
38:4 0.000541133 "350" 350 38 6
39:1 0 "377" 377 6 5
```

This output is parsed by `run_infomap_multilayer` to obtain a table in which each state node (combination of a physical node in a layer) is assigned to a module. This can be obtained by:
```R
NEE2017_modules$modules
```
