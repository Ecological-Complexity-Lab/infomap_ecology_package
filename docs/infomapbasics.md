# Infomap arguments
Most of the Infomap arguments we use are common for all the examples and their detailed description can be found [here](https://www.mapequation.org/code.html#Options). We explain in each example the most relevant specific arguments. Here is a typical running command:

`./Infomap infomap.txt . --tree -i link-list  --seed 123 -N 20 -f undirected -2`.

* `infomap.txt` is the name of the input file
*  `.` indicates that the output will be written to the same folder as the input file.
* `--tree` sets the output format.
* `-i  link-list` indicates that the input is a [link list](https://www.mapequation.org/code.html#Link-list-format).
* `--seed 123` provides a seed to the random number generator such that each run will result in the same output, which is useful for replication.
* `-N 20` tells infomap to run 20 trials and select the result of the best one.
* `-f undirected` indicates flow on an undirected network.
* `-2` indicates a two-level solution, with no hierarchical modules (modules within modules).

# Infomap output
The output, written into the `tree` file, is as follows (details [here](https://www.mapequation.org/infomap/#Output)). 
```python
# v1.0.6
# ./Infomap infomap.txt . -i link-list --out-name infomap_out --tree --seed 123 -N 20 -f undirected --silent --two-level
# started at 2020-03-11 14:24:12
# completed in 0.0300386 s
# codelength 4.565 bits
# relative codelength savings 2.4337%
# path flow name node_id
1:1 0.00091617 "1" 1
1:2 0.00229043 "7" 7
1:3 0.00114521 "8" 8
1:4 0.00091617 "10" 10
1:5 0.000458085 "11" 11
```
The first four lines are quite obvious. The 5th line provides the value of the map equations objective function (_L_) for the optimal partition. After the headings, rows describe module affiliation and flow. The `path` column is a tree-like format. The last integer after the colon indicates the ID of the leaf in the module, and not the ID of the node. See detailed explanations also in the R function (`run_infomap_monolayer`) in the package, which automatically reads this output and adds the affiliation of modules to the node table to create an output similar to this:

```python
node_id node_name             module_level1 module_level2 node_type node_group
 1       1 Aglais.urticae                    1             1 c         A         
 2       2 Apis.mellifera                    2             1 c         A         
 3       3 Bombus.lapidarius                 2             2 c         A         
 4       4 Bombus.muscorum                   3             1 c         A         
 5       5 Bombus.pascuorum                  3             2 c         A         
 6       6 Bombus.terrestris                 2             3 c         A 
```

Here, `module_level1` is the module ID and `module_level2` is the leaf ID, extracted from the `path` column. `node_type` is either `c` for column or `r` for row, indicating of the node appears in the column or row of the matrix format.
