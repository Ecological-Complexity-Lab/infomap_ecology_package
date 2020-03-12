## infomapecology: A package for running Infomap, inspired by ecological networks

The package contains functions that prepare monolayer and multilayer networks
for analysis with Infomap, run Infomap from within R and parse the results
back to R. The package is inspired by analysis of ecological networks but is
suitable for other areas of research as well. The package also includes several data sets of ecological networks.

## Some details
We use Infomap version 1 as a stand-alone file. Future versions (or a different
package) will integrate Infomap directly intro R. Complete instructions on how
to download, install and use Infomap can be found in
[https://www.mapequation.org](https://www.mapequation.org). The best
practice is to compile Infomap under the file name "Infomap" and place it in the
same working folder in which the R code is run.

## Installing
```R
install.packages("devtools")
devtools::install_github('Ecological-Complexity-Lab/infomap_ecology_package')
```
