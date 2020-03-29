\name{infomap class}
\alias{infomap}
\title{An object of class infomap}

\value{
A list with:
\itemize{
  \item \code{call} The call to Infomap with all the arguments.
  \item \code{L} The value of the map equation for the observed netwotk.
  \code{edge_list} The original edge list (network).
  \item \code{modules} A tibble with node id, module affiliations and node attributes if they exist.
  \item \code{L_sim} A vector with values of L for the shuffled network, with length as the number of randomizations. \code{NULL} if significance test was not performed.
  \item \code{pvalue} P value of comparison to randomizations. \code{NULL} if significance test was not performed.
}
}
\description{
An object of class infomap contains all the information resulting from an analysis of modularity. It facilitates subsequernt analyses and plotting.
}
\seealso{
\code{run_infomap_monolayer_nonrandom}
}

