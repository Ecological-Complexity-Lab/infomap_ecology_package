## 1. Install the R package
The package was built under R 4.1 and depends on other packages.

```R
# Install  (if not installed) and load necessary packages
package.list=c("attempt", "cowplot", "igraph", "ggalluvial","magrittr","metafolio","tidyverse","vegan", "devtools")
loaded <-  package.list %in% .packages()
package.list <-  package.list[!loaded]
installed <-  package.list %in% .packages(TRUE)
if (!all(installed)) install.packages(package.list[!installed], repos="http://cran.rstudio.com/")

# Install infomapecology 
devtools::install_github('Ecological-Complexity-Lab/infomap_ecology_package', force=T)
library(infomapecology)

# Check the version. Should be at least 1.01
packageDescription('infomapecology')
```

## 2. Install Infomap
We use Infomap version 1.x as a stand-alone file. Future versions (or a different package) will integrate Infomap directly intro R.

All instructions to install Infomap are in [https://www.mapequation.org/infomap/#Install](https://www.mapequation.org/infomap/#Install). But here is a summary to help you get this done step-by-step. In any case of contradiction, the instructions on Infomap's website hold.

### MacOS / Linux
You need to have a few pakages installed using homebrew.
* Install homebrew as specified in [https://brew.sh](https://brew.sh). This will take a while.
* install node: `brew install node` or upgrade if you have it: `brew upgrade node`.
* install packages: `brew install llvm libomp`.

Then install Infomap via the `install_infomap` function in the package, or follow the instructions on how to download, install and use Infomap in [https://www.mapequation.org](https://www.mapequation.org).

```R
# Install infomap if you have not done so externally (see previous section in this readme)
setwd('where your Infomap file and R script will live')
install_infomap()

# Check Infomap is running
setwd('where your Infomap file and R script now live')
check_infomap() # Make sure file can be run correctly. Should return TRUE
```

### Windows
* Install prerequisits for windows as described here: [https://www.mapequation.org/infomap/#Windows](https://www.mapequation.org/infomap/#Windows), including WSL and the others.
* You need a Pythin environemnt, Anaconda is great
* Install Infomap via `pip`: [https://www.mapequation.org/infomap/#UsingPip](https://www.mapequation.org/infomap/#UsingPip). After installing via python as instructued, in the anaconda terminal you can type `where infomap` to find the file. 

**Important notes:**
1. The best practice is to compile Infomap under the file name "Infomap" and place it in the
same working folder in which the R code is run.
2. Though technically Infomap can run on Windows as detailed above, I find that this is not always so easy to do. If you don't manage to install it, Linux/MacOS are the best options.
