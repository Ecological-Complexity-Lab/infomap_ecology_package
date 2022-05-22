## infomapecology: A package for running Infomap, inspired by ecological networks

The package contains functions that prepare monolayer and multilayer networks
for analysis with Infomap, run Infomap from within R and parse the results
back to R. It is inspired by analysis of ecological networks but is
suitable for other areas of research as well. The package also includes several data sets of ecological networks.

## Citation
The paper accompanying this repository is:
Farage, C., D. Edler, A. Eklöf, M. Rosvall, and S. Pilosof. 2021. Identifying flow modules in ecological networks using Infomap. Methods in Ecology and Evolution

## Acknowledgements
This work was supported by research grant ISF (Israel Science Foundation) 1281/20 to Shai Pilosof.

## Full documentation
Complete instructions for installation and many examples are in [https://ecological-complexity-lab.github.io/infomap_ecology_package/](https://ecological-complexity-lab.github.io/infomap_ecology_package/).

<br>

******************

### News

__2022-01-19 :__

Updating the package to be compatible with the latest version of Infomap (2.0.0). 
  
<ul>
  <li>Defaults to installing the latest Infomap version.</li>
  <li>Defaults to including self-link as apposed to previous versions that defaulted to excluding them. <br>
  Excluding self-links now requires adding "\--no-self-links" to the optional arguments.</li>
</ul>


__2021-10-27 :__

Update Install_infomap function to default as downlading the pre-compiled binary versions of Infomap, as can be found  [here](https://github.com/mapequation/infomap/releases/tag/v2.0.0).
