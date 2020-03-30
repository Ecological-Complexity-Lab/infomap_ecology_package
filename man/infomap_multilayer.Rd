\name{infomap multilayer class}
\alias{infomap multilayer}
\title{An object of class infomap_multilayer}

\value{
A list with:
\itemize{ 
    \item \code{call} The call to Infomap with all the arguments.
    \item \code{L} The value of the map equation.
    \item \code{modules} A tibble with nodes, their module affiliations, and node attributes. }
}

\description{
An object of class infomap_multialyer contains all the information resulting from an analysis of modularity on multilayer networks. It facilitates subsequernt analyses and plotting.
}
\seealso{
\code{run_infomap_multilayer}
}

