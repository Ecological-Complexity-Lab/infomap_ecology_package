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

# Check the version. Should be at least 1.03
packageDescription('infomapecology')
```

## 2. Install Infomap
We use Infomap version 1.x as a stand-alone file. Future versions (or a different package) will integrate Infomap directly intro R.

### MacOS (Linux should be similar)
#### 1. In the terminal run:
* `xcode-select --install`
* For OpenMP support
  * Install homebrew as specified in [https://brew.sh](https://brew.sh). This will take a while.
  * install packages: `brew install libomp`.

#### 2. Then either:
Install Infomap via the `install_infomap` function in the package as below. Avoid folder names with spaces or non-english lettes.

```R
setwd('where your Infomap file and R script will live')
install_infomap()

# Check Infomap is running
setwd('where your Infomap file and R script now live')
check_infomap() # Make sure file can be run correctly. Should return TRUE
```

or download a binary from [here](https://github.com/mapequation/infomap/releases/latest) and put the file in the working folder.


### Windows

Install Infomap via the `install_infomap` function in the package as below. Avoid folder names with spaces or non-english lettes.

```R
setwd('where your Infomap file and R script will live')
install_infomap()

# Check Infomap is running
setwd('where your Infomap file and R script now live')
check_infomap() # Make sure file can be run correctly. Should return TRUE
```

or download a binary from [here](https://github.com/mapequation/infomap/releases/latest) and put the file in the working folder.


**Important notes:**
1. The best practice is to compile Infomap under the file name "Infomap" and place it in the
same working folder in which the R code is run.
2. Other ways to install: [https://www.mapequation.org/infomap/#Install](https://www.mapequation.org/infomap/#Install)
