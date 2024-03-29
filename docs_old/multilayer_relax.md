# Temporal multilayer network with global relax rates

### Data set
A temporal multilayer network. Each layer is a host-parasite bipartite network. Intralayer edges between a parasite species and a host species are the number of parasite individuals divided by the number of host individuals. Interlayer edges are ignored. This data set was taken from [_Pilosof S, Porter MA, Pascual M, Kéfi S. The multilayer nature of ecological networks. Nature Ecology & Evolution. 2017;1: 0101_](https://www.nature.com/articles/s41559-017-0101?proof=true19).

Data sets in infomapecology:
```R
# Get data
data("siberia1982_7_links")
data("siberia1982_7_nodes")
```
### Input
A [multilayer link-list format](https://www.mapequation.org/infomap/#InputMultilayer). With this format, a random walker moves within a layer and with a given relax rate _r_ jumps to another layer without recording this movement, such that the constraints from moving in different layers can be gradually relaxed. If the `*Inter` exists, then interlayer edges can be used. However, if a relax rate is also used (Infomap input parameter `--multilayer-relax-rate`), the interlayer edges are ignored. Here we only include `*Intra`.

```Python
# A network in multilayer format
*Intra
#layer node node weight
1 1 23 0.15853658536585366
1 1 25 0.024390243902439025
1 1 27 0.0975609756097561
... some more cases ...
6 22 63 0.8181818181818182
6 22 67 0.09090909090909091
6 22 77 0.18181818181818182
```

### R Code
The description of functions `create_multilayer_object` and `run_infomap_multilayer` in the `infomapecology` package contains everything you need to know. The `for` loop performs a sensitivity analysis to examine how structure changes with increasing relax rates.

```R
# Create a multilayer object
NEE2017 <- create_multilayer_object(extended = siberia1982_7_links, nodes = siberia1982_7_nodes, intra_output_extended = F)

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
```

### Infomap
Under the hood, the function `run_infomap_multilayer` runs:
```C++
./Infomap infomap_multilayer.txt . -2 --seed 497294 -N 50 -i multilayer --multilayer-relax-rate 0.15 --multilayer-relax-limit-up 1 --multilayer-relax-limit-down 0 --silent
```

Explanation of key arguments:
* `-i multilayer` indicates a multilayer input format, which is automatically recognized as a multilayer link list (and not as a general link list).
* `--multilayer-relax-rate 0.15` defines the relax rate (here 0.15).
* `multilayer-relax-limit-up 1 --multilayer-relax-limit-down 0` limits relaxation to a single layer upwards (l to l+1), but never downwards, because time flows one-way.

### Output
For multilayer network the output file has a `_states` suffix, with the following format. This output is as in [Temporal multilayer network with interlayer edges](multilayer_interlayer.md). 

```R
# path flow name stateId physicalId layerId
1:1 0.000516265 "0" 0 1 1
1:2 0.000211504 "8" 8 44 1
1:3 0.000225137 "19" 19 75 1
1:4 0.000124064 "20" 20 76 1
```
This output is parsed by `run_infomap_multilayer` to obtain a table in which each state node (combination of a physical node in a layer) is assigned to a module. This can be obtained by (after running the code above):
```R
relaxrate_modules$modules
```
