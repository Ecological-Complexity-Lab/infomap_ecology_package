library(igraph)
library(bipartite)
library(dplyr)
library(tidyverse)
library(magrittr)
library(cowplot)
library(infomapecology)
library(ggplot2)
library(reshape2)
library(RColorBrewer)
library(scales)

data("kongsfjorden_links")
data("kongsfjorden_nodes")

nodes <- kongsfjorden_nodes %>%
  select(node_name=Species, node_id_original=NodeID, everything())
anyDuplicated(nodes$node_name)

interactions<- kongsfjorden_links %>%
  select(from=consumer, to=resource) %>%
  mutate_if(is.factor, as.character) %>%
  mutate(weight=1)

# Prepare network objects
network_object <- create_monolayer_object(x=interactions, directed = T, bipartite = F, node_metadata = nodes)
# AE: here we actually need something that states what are the crucial things to include!
# Run infomap without hieararchy
infomap_object <- run_infomap_monolayer(network_object, infomap_executable='Infomap',
                                        flow_model = 'directed',
                                        silent=T,trials=100, two_level=F, seed=123)


######################################

# ARRANGE for plotting
mods <-  infomap_object$modules
mods <- arrange(mods, module_level1, module_level2)#, module_level3, module_level4) 
links <- infomap_object$edge_list

# create matrix where species are sorted
# make matrix from edgelist
A <- matrix(0, length(mods$node_id), length(mods$node_id)) 
colnames(A) <- mods$node_name
rownames(A) <- mods$node_name
# add interactions as 1:s from infomap_object$edgelist
for(i in unique(cbind(links$from, links$to))){
  prey <- which(links$from==i)
  A[links[prey,]$to, i] <- 1
}

sumData<-melt(A)

# rename columns to keep track of which are consumer and resources respectively
sumData %<>% 
  as_tibble() %>%
  rename(consumer = Var1 , resource = Var2) %>%
  mutate(consumer =as.character(consumer), resource = as.character(resource))

# keep an "original"
sumData_org <- sumData

# Add the module belonging for each link info for both consumers and resources
  # for Var 1
sumData %<>% left_join(mods, by=c('consumer'='node_name')) %>% 
  select(consumer, resource, value, module_level1, module_level2, Environment, FeedingType, Mobility) 

# fix specific numbers for modeule levels
# change NA:s to 0 (now only for module_level3 - make more general)
#sumData$module_level3[which(is.na(sumData$module_level3))] <- 0

sumData %<>%
  rename(consumer_mod_1=module_level1, consumer_mod_2=module_level2, consumer_habitat=Environment, consumer_spType=FeedingType, consumer_mobility = Mobility)
sumData1 <- sumData

# for Var 2
sumData <- sumData_org

sumData %<>% left_join(mods, by=c('resource'='node_name')) %>% 
  select(consumer, resource, value, module_level1, module_level2, Environment, FeedingType, Mobility) 

# fix specific numbers for modeule levels
# change NA:s to 0 (now only for module_level3 - make more general)
#sumData$module_level3[which(is.na(sumData$module_level3))] <- 0

sumData  %<>%
  rename(resource_mod_1=module_level1, resource_mod_2=module_level2, resource_habitat=Environment, resource_mobility = Mobility, resource_spType=FeedingType)
sumData2 <- sumData

# merge the two frames
allData <- full_join(sumData1, sumData2)


allData <- allData %>% as_tibble() %>%
  mutate(consumer_mod_1 = paste("0", consumer_mod_1, sep=""))  %>%
  mutate(resource_mod_1 = paste("0", resource_mod_1, sep=""))  %>%
  mutate(consumer_mod_2 = paste("0", consumer_mod_2, sep=""))  %>%
  mutate(resource_mod_2 = paste("0", resource_mod_2, sep=""))  %>%
  mutate(MOD = paste(consumer_mod_1, resource_mod_1, consumer_mod_2, resource_mod_2, sep="")) %>%
  mutate(Same_mod_1 = ifelse(consumer_mod_1==resource_mod_1, consumer_mod_1, "x")) %>%
  mutate(Same_mod_2 = ifelse(consumer_mod_2==resource_mod_2, consumer_mod_2, "x")) %>% 
  mutate(Same_mod_2 = ifelse(Same_mod_1== "x", "x", Same_mod_2)) %>%
  mutate(MOD = paste(Same_mod_1, Same_mod_2, sep="")) %>%
  mutate(MOD = as.factor(MOD)) %>%
  mutate(value = as.factor(value))


# find all modules that only include one species and give them the module number "99"
# (this is only in order to lower the number of modules to plot)
tab1 <- which(table(allData$MOD)==1) 
new1 <- (which(allData$MOD %in% names(tab1)))
allData$MOD <- as.character(allData$MOD)
allData$MOD[new1] <- "99"

#-------- plot matrix with interactions and modules --------#

# arrange the ordering of the x- and y-axis
allData$consumer = factor(allData$consumer, levels = unique(allData$consumer))
allData$resource = factor(allData$resource, levels = unique(allData$resource))

# Set colors
# mycolors <- c("#660033", "#900066", "#CC3366", "#CC3399", "#006666", "#339999", "#66CCCC", "#99FFFF", "#0066CC", "#3399FF", "white", "lightgrey", "white", "white", "white", "white")            
mycolors <- c(colorRampPalette(c("darkblue", "lightblue"))(10), "firebrick4", "firebrick2", "tomato2", "lightgrey","lightgrey", "lightgrey")            

# plotting
allData %>%
  ggplot() +
  geom_tile(data = allData, aes(x = consumer, y = resource, fill= MOD, alpha = 0.5)) + # this is all that is needed
  scale_fill_manual(values = mycolors) +
  #scale_fill_viridis_d(option="D") +
  geom_point(data = allData %>% filter(value == 1), aes(x = consumer, y = resource, fill=value), size=0.6) +
  theme_bw() + theme(
        panel.grid.major = element_line(),
        panel.grid.minor = element_blank(),
        panel.background = element_blank(),
        axis.text.x = element_blank(),
        axis.text.y = element_blank(), 
        axis.ticks = element_blank())
       

#-------- analyse traits of species in modules ------------#

traits_and_mods <- allData %>%
                  select(consumer, consumer_mod_1, consumer_mod_2, consumer_habitat, consumer_mobility, consumer_spType) %>%
                  mutate(consumer_mod = paste(consumer_mod_1, consumer_mod_2, sep="")) %>%  
                  distinct() %>%
                  filter(consumer_mod_1 %in% c("01", "02", "03", "04")) %>% 
                  mutate(Habitat_SpType = paste(consumer_habitat, consumer_spType, sep="_")) %>%
                  mutate(Habitat_Mobility = paste(consumer_habitat, consumer_mobility, sep="_")) %>%
                  mutate(Mobility_SpType = paste(consumer_mobility, consumer_spType,sep="_")) %>%
                  mutate(Habitat_Mobility_SpType = paste(consumer_habitat, consumer_mobility,consumer_spType, sep="_")) %>%
                  mutate(consumer_mobility = as.character(consumer_mobility))
                    
# plot the distribution of traits in module level 1
ggplot(traits_and_mods, aes(consumer_mod_1, fill = Mobility_SpType)) +
  geom_histogram(stat = "count") + #aes(y=..ncount..)#/sum(..count..))) + 
  #scale_y_continuous(labels = percent_format()) + 
  facet_wrap(~consumer_mod_1, 1,4, scales = "free") +
  labs(x="Modules", y="number of species", title="Module_level_1") 

# plot traits for certain submodules in level 2 
  # here one might want to ignore species that are in a module on their own
traits_and_mods %<>%
                group_by(consumer_mod) %>% filter(n()>1)# %>%
                #filter(consumer_mod %in% c("0101","0102","0108"))
  
# change the fill depending on what trait/combination of traits that should be plotted                
ggplot(traits_and_mods, aes(consumer_mod, fill = Mobility_SpType)) +
              geom_histogram(stat = "count") + #,aes(y=..count../sum(..count..))) + 
              labs(x="Modules", y="number of species", title="Module_level_2") 





