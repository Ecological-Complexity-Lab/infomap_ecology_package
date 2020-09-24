library(infomapecology)
library(tidyverse)
library(igraph)

# Original network -------------------------------
d <- read_csv('gillaranz.csv', col_types = 'ccilc')
nodes <- tibble(node_name=as.character(1:20), color=rep(c('blue','green','orange','red'), each=5))
x <- create_monolayer_object(d, directed = F, bipartite = F, node_metadata = nodes)
g <- x$igraph_object
list.vertex.attributes(g)
list.edge.attributes(g)

svg('gillaranz.svg',8,8)
plot(g, vertex.color=V(g)$color, edge.color=E(g)$color, edge.width=E(g)$weight, edge.curved=0.5)
dev.off()

# Modules with infomap
infomap_object <- run_infomap_monolayer(x, infomap_executable='Infomap',
                                        flow_model = 'undirected',
                                        silent=F,trials=100, two_level=T)
modules_infomap <- infomap_object$modules$module_level1
# modules_infomap <- rep(1:max(modules_infomap), times=table(modules_infomap))  # Reorder module numbers


V(g)$mod_infomap <- modules_infomap

plot(g, vertex.color=V(g)$mod_infomap, edge.color=E(g)$color, edge.width=E(g)$weight)

# Modules with Q
m <- igraph::fastgreedy.community(g, membership = T, weights = E(g)$weight)
modules_Q <- m$membership
modules_Q <- rep(1:max(modules_Q), times=table(modules_Q))  # Reorder module numbers

V(g)$mod_Q <- modules_Q # Reorder module numbers
plot(g, vertex.color=V(g)$mod_Q, edge.color=E(g)$color, edge.width=E(g)$weight)

# Compare
modules_comparison <- data.frame(cbind(modules_infomap, modules_Q))
N <- with(modules_comparison, table(modules_infomap, modules_Q))
NMI(N)


# values <- split(as.matrix(modules_comparison), rep(1:nrow(modules_comparison), each = 2))
# plot(g, vertex.shape="pie", vertex.pie=values,
#      vertex.pie.color=list(heat.colors(5)),
#      vertex.size=seq(10,30,length=10), vertex.label=NA)


# Change weight -------------------------------
NMI_res <- NULL
d_orig <- read_csv('gillaranz.csv', col_types = 'ccdlc')
modules_planted <- rep(1:4, each=5)
for (w in seq(1,4, by=0.05)){
  d <- d_orig
  # w <- rpois(1, 6)
  # w <- rnorm(1, mean = 3,sd = 0.5)
  d[d$from==3 & d$to==6,'weight'] <- w
  d[d$from==5 & d$to==8,'weight'] <- w
  nodes <- tibble(node_name=as.character(1:20), color=rep(c('blue','green','orange','red'), each=5))
  x <- create_monolayer_object(d, directed = F, bipartite = F, node_metadata = nodes)
  g <- x$igraph_object
  # list.vertex.attributes(g)
  # list.edge.attributes(g)
  # plot(g, vertex.color=V(g)$color, edge.color=E(g)$color, edge.width=E(g)$weight)
  
  # Modules with infomap
  infomap_object <- run_infomap_monolayer(x, infomap_executable='Infomap',
                                          flow_model = 'undirected',
                                          silent=T,trials=10, two_level=T, seed = 1000)
  modules_infomap <- infomap_object$modules$module_level1
  modules_infomap <- rep(1:max(modules_infomap), times=table(modules_infomap))  # Reorder module numbers
  
  
  V(g)$mod_infomap <- modules_infomap
  # plot(g, vertex.color=V(g)$mod_infomap, edge.color=E(g)$color, edge.width=E(g)$weight, main=paste(i,'Infomap'))
  # Modules with Q
  m <- igraph::fastgreedy.community(g, membership = T, weights = E(g)$weight)
  modules_Q <- m$membership
  modules_Q <- rep(1:max(modules_Q), times=table(modules_Q))  # Reorder module numbers
  
  V(g)$mod_Q <- modules_Q # Reorder module numbers
  # plot(g, vertex.color=V(g)$mod_Q, edge.color=E(g)$color, edge.width=E(g)$weight, main=paste(i,'Q'))
  
  # Compare
  modules_comparison <- data.frame(cbind(modules_infomap, modules_Q, modules_planted))
  N_IQ <- with(modules_comparison, table(modules_infomap, modules_Q))
  N_IP <- with(modules_comparison, table(modules_infomap, modules_planted))
  N_QP <- with(modules_comparison, table(modules_Q, modules_planted))
  # N
  # NMI(N)
  NMI_res <- rbind(NMI_res, tibble(
                                   w=w,
                                   m_Infomap=max(modules_infomap), 
                                   m_Q=max(modules_Q),
                                   NMI_IQ=NMI(N_IQ),
                                   NMI_IP=NMI(N_IP),
                                   NMI_QP=NMI(N_QP)
                                   ))
}


# NMI_res <- read_csv('Q_vs_I_changing_weights.csv')
svg('gilarranz_I_vs_Q_modules.svg',8,8)
NMI_res %>% 
  gather(key, value, -w) %>% 
  filter(key %in% c('m_Infomap', 'm_Q')) %>% 
  ggplot(aes(w, value, color=key))+
  geom_point(size=3.5, alpha=0.8, position = position_dodge(width = 0.05))+
  # geom_line()+
  labs(y='Number of modules', x='Weight', legend='Method')+
  scale_y_continuous(breaks = c(3,4))+
  scale_color_manual(values = c('dark green','skyblue'))+
  theme_bw()+
  theme(panel.grid = element_blank(),
        axis.title = element_text(size=20, color='black'),
        axis.text = element_text(size=20, color='black'),
        legend.position = 'none')

dev.off()

write_csv(NMI_res, 'Q_vs_I_changing_weights.csv')

# Change directions -------------------------------
# Modules with Q
d <- read_csv('gillaranz.csv', col_types = 'ccilc')
nodes <- tibble(node_name=as.character(1:20), color=rep(c('blue','green','orange','red'), each=5))
x <- create_monolayer_object(d, directed = F, bipartite = F, node_metadata = nodes)
g <- x$igraph_object
m <- igraph::fastgreedy.community(g, membership = T, weights = E(g)$weight)
modules_Q <- m$membership
modules_Q <- rep(1:max(modules_Q), times=table(modules_Q))  # Reorder module numbers


d_within <- d %>% filter(within_mod==T)
d_within <- bind_rows(d_within,
                      d_within %>% select(from=to, to=from, weight, within_mod, color)) %>% print(n=Inf)

d_between <- d %>% filter(within_mod==F)
d_between <- bind_rows(d_between,
                       d_between %>% select(from=to, to=from, weight, within_mod, color)) %>% print(n=Inf)


x <- create_monolayer_object(bind_rows(d_within %>% sample_n(33, replace=F), d_between), directed = T, bipartite = F, node_metadata = nodes)
g <- x$igraph_object
svg('gillaranz_directed_instance.svg',8,8)
plot(g, vertex.color=V(g)$color, edge.color=E(g)$color, edge.width=E(g)$weight, edge.curved=0.5)
dev.off()



# NMI_res <- read_csv('Q_vs_I_changing_direction.csv')


NMI_res <- NULL

for (i in 1:500){
  # Make directed network randomly
  d <- bind_rows(d_within %>% sample_n(33, replace=F), 
                 d_between)
  
  nodes <- tibble(node_name=as.character(1:20), color=rep(c('blue','green','orange','red'), each=5))
  x <- create_monolayer_object(d, directed = T, bipartite = F, node_metadata = nodes)
  # Modules with infomap
  infomap_object <- run_infomap_monolayer(x, infomap_executable='Infomap',
                                          flow_model = 'directed',
                                          silent=T,trials=100, two_level=T)
  modules_infomap <- infomap_object$modules$module_level1

  # Compare
  modules_comparison <- data.frame(cbind(modules_infomap, modules_Q))
  N <- with(modules_comparison, table(modules_infomap, modules_Q))
  
  NMI_res <- rbind(NMI_res, tibble(m_Infomap=max(modules_infomap), m_Q=max(modules_Q), NMI=NMI(N)))
}

NMI_res %>% group_by(m_Infomap) %>%
  summarise(n = n()) %>%
  mutate(freq = n / sum(n))

mean(NMI_res$NMI)
  
NMI_res %>% filter(m_Infomap==4) %>% 
ggplot()+geom_histogram(aes(NMI), fill='purple',alpha=0.4)

write_csv(NMI_res, 'Q_vs_I_changing_direction.csv')