## Install Infomap
We use Infomap version 1 as a stand-alone file. Future versions (or a different
package) will integrate Infomap directly intro R. On Linux/MacOs, you can install Infomap via the `install_infomap` function in the package (see next section), or follow the instructions on how to download, install and use Infomap in [https://www.mapequation.org](https://www.mapequation.org).

For Windows, try this:
1. Install  miniconda Python 3 from here: https://docs.conda.io/en/latest/miniconda.html. You may also need Visual Studio (https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2017). If so, choose Workload: Desktop Development with C++.
2. Open the miniconda prompt or Windows' powershell.
3. type: `pip install infomap`.

This will create a file called `infomap`. In the anaconda terminal you can type `where infomap` to find the file. 

An alternative is to install a local Linux environment like Ubuntu from the Microsoft Store.

**Important notes:**
1. The best practice is to compile Infomap under the file name "Infomap" and place it in the
same working folder in which the R code is run.
2. Though technically Infomap can run on Windows as detailed above, I find that this is not always so easy to do. If you don't manage to install it, Linux/MacOS are the best options.

## Install the R package
The package was built under R 3.6.3 and requires `attempt, igraph, bipartite, magrittr, tidyverse`.

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

# Check the version. Should be at least 0.1.1.1
packageDescription('infomapecology')

# Install infomap if you have not done so externally (see previous section in this readme)
setwd('where your Infomap file and R script will live')
install_infomap()

# Check Infomap is running
setwd('where your Infomap file and R script now live')
check_infomap() # Make sure file can be run correctly. Should return TRUE
```
