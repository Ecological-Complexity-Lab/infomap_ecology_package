# Flow models

### Data set
Weighted directed networks of pollen transfer from [Tur C, Sáez A, Traveset A, Aizen MA. Evaluating the effects of pollinator-mediated interactions using pollen transfer networks: evidence of widespread facilitation in south Andean plant communities. Ecol Lett. 2016;19: 576–586](https://onlinelibrary.wiley.com/doi/abs/10.1111/ele.12594).

In infomapecology:
```R
data(Tur2016)
```

### Input
A [link-list](https://www.mapequation.org/infomap/#InputLinkList).

### R Code
```R
tur2016_altitude <- tur2016 %>% filter(altitude==2000) %>% select(from=donor,to=receptor,weight=no.grains)
network_object <- create_monolayer_object(tur2016_altitude, directed = T, bipartite = F)
res_dir <- run_infomap_monolayer(network_object, infomap_executable='Infomap',
                                 flow_model = 'directed',
                                 silent=T,trials=100, two_level=T, seed=200952, ...='-k --markov-time 50')
res_rawdir <- run_infomap_monolayer(network_object, infomap_executable='Infomap',
                                    flow_model = 'rawdir',
                                    silent=T,trials=100, two_level=T, seed=200952, ...= '-k --markov-time 50')

res_dir <- res_dir$modules
res_rawdir <- res_rawdir$modules


# Compare the results using normalised mutual information
N <- res_dir %>% # Create confusion matrix
  select(-module_level2) %>%
  inner_join(res_rawdir %>% select(node_id,module_level1), by='node_id') %>%
  arrange(module_level1.x,module_level1.y) %>%
  group_by(module_level1.y) %>% select(module_level1.x) %>% table()

# These two different modes of flow can result in different partitions.
NMI(N)

```

### Infomap
Under the hood, the function `run_infomap_monolayer` runs:

For **real measured** flows:
```C++
./Infomap infomap.txt . -i link-list --tree --seed 200952 -N 100 -f rawdir --two-level -k --markov-time 50
```

For **constraints** on flows:
```C++
./Infomap infomap.txt . -i link-list --tree --seed 200952 -N 100 -f directed --two-level -k --markov-time 50
```

Explanation of key arguments:
* `-f directed` indicates flow on a directed network. The visitation rates of nodes is obtained with a PageRank algorithm based on the direction and weight of edges.
* `-f rawdir` or `-f directed`: In a `rawdir` flow model the visitation rates of nodes is determined without a PageRank algorithm but rather by the given direction and weight of edges. In a `directed` flow model edge weights are assumed to be constraints on flow, and a PageRank algorithm is run first to determine flow.
* `-k` includes the self-loops.
* `--markov-time 50` scales link flow to change the cost of moving between modules. Higher values results in fewer modules. We used it here to create modules with more nodes for pedagogic reasons, to be able to have modules that would be distinguishable between the different flow models.


### Output
A [tree file](https://www.mapequation.org/infomap/#OutputTree) is produced by Infomap, but is parsed by `run_infomap_monolayer` from infomapecology (in R: `?run_infomap_monolayer`).
