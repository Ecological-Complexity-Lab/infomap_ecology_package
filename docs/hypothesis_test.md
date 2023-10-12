# Hypothesis testing

## 1. Built in randomisation capabilities for bipartite networks

The function `run_infomap_monolayer` can use shuffling algorithms built into `vegan`. To use this, we need to set `signif=T` and provide a shuffling method to `shuff_method`. The shuffling methods are the ones detailed in `?vegan::commsim`.

```R
network_object <- create_monolayer_network(memmott1999, bipartite = T, directed = F, group_names = c('A','P'))

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
```

Another way is to provide `shuff_method` with a list containing already shuffled networks. You can for example use the function `shuffle_infomap` to produce shuffled networks with `vegan`. This is necessary on the shuffling algorithm from `?vegan::commsim` needs additional arguments such as burning.

```R
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
```
 

## 2. Dedicated randomisation algorithm for the Tur et al. 2016 data set.
You can also create your own shuffling algorithm and a list of shuffled link lists. As in this example.

```R
# Import data
data(tur2016)
tur2016_altitude2000 <- tur2016 %>% 
  filter(altitude==2000) %>% 
  select("donor", "receptor", "total") %>% 
  group_by(donor, receptor) %>% 
  summarise(n=mean(total)) %>% 
  rename(from = donor, to = receptor, weight = n) %>% 
  ungroup() %>%
  slice(c(-10,-13,-28)) %>%  # Remove singletons
  filter(from!=to) # Remove self loops
  
tur_network <- create_monolayer_network(tur2016_altitude2000, directed = T, bipartite = F)

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
  x <- create_monolayer_network(x,directed = T,bipartite = F) # Create a monolayer object
  shuffled[[i]] <- create_infomap_linklist(x)$edge_list_infomap #Create a link-list
}  

# Use the shuffled link lists. 
tur_signif <- run_infomap_monolayer(tur_network, infomap_executable='Infomap',
                      flow_model = 'rawdir',
                      silent=T,
                      trials=100, two_level=T, seed=200952,
                      signif = T, shuff_method = shuffled)


print(tur_signif$pvalue)

plots <- plot_signif(tur_signif, plotit = F)
```
