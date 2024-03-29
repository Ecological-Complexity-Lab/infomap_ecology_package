% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/create_infomap_linklist.R
\name{create_infomap_linklist}
\alias{create_infomap_linklist}
\title{Create a link list for Infomap}
\usage{
create_infomap_linklist(
  x,
  make_directed = F,
  write_to_file = F,
  output_file = "infomap_link_list.txt"
)
}
\arguments{
\item{x}{A monolayer object created with \code{create_monolayer_network}.}

\item{make_directed}{for undirected networks, create two sets of edges.}

\item{write_to_file}{write the link list into a file?}

\item{output_file}{the name of the output file (default is 'infomap_link_list.txt')}
}
\value{
An object of class \code{infomap_link_list}, which is an R list with:
\itemize{
  \item \code{edge_list_infomap} A link list (format: from, to, weight) formatted for Infomap, with node IDs
  \item \code{nodes} A tibble with node IDs, names and possibly other attributes.
}
}
\description{
Takes a monolayer object and returns a link list and a tibble with nodes.
}
\details{
Used internally by \code{run_infomap_monolayer}, but also useful for writing the link list to a file.
}
\examples{
network_object <- create_monolayer_network(bipartite::memmott1999,
 bipartite = TRUE, directed = FALSE, group_names = c('A','P'))
 
x <- create_infomap_linklist(network_object, make_directed = FALSE, 
write_to_file = FALSE)

}
\seealso{
\code{infomap_link_list}
}
