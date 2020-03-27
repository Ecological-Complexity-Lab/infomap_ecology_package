\name{infomap link list class}
\alias{infomap_link_list}
\title{An object of class infomap_link_list}

\value{
An R list with:
\itemize{
 \item \code{edge_list_infomap} A link list (format: from, to, weight) formatted for Infomap, with node IDs
 \item \code{nodes} A tibble with node IDs, names and possibly other attributes.
}
}
\description{
A network object of class infomap_link_list contains all the necessary information and R objects to run Infomap and parse the results back to R.
}
\seealso{
\code{create_infomap_linklist}
}