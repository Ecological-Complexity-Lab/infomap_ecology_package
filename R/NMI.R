#' Normalized mutual information
#'
#' Calculate normalized mutual information based on a confusion matrix. Very
#' useful to compare between two partition structures of a network.
#'
#' @param N A confusion matrix.
#'
#' @return Value between 0 (no mutual information) to 1 (complete mutual
#'   information).
#'
#' @details If the partitions are exactly the same then all the nodes that
#'   appear in a given module in the first network will also appear in the same
#'   module in the second. In this case, the confusion matrix will have all the
#'   values on the diagonal, and NMI=1.
#'
#' @references Danon L, Díaz-Guilera A, Duch J, Arenas A. Comparing community
#'   structure identification. J Stat Mech. 2005;2005: P09008.
#' @references Guimerà R, Sales-Pardo M, Amaral LAN. Module identification in
#'   bipartite and directed networks. Phys Rev E Stat Nonlin Soft Matter Phys.
#'   2007;76: 036102.
#' @references Pilosof S, Fortuna MA, Cosson J-FC, Galan M, Kittipong C, Ribas
#'   A, et al. Host-parasite network structure is associated with
#'   community-level immunogenetic diversity. Nat Commun. 2014;5: 5172.
#'
#'
#' @export

NMI <- function (N) {
  S <- sum(N)
  CA = dim(N)[1]; CB = dim(N)[2]
  Iup=0
  for (i in 1:CA){
    for (j in 1:CB){
      if (N[i,j] != 0){
        Ni.=sum(N[i,])
        N.j=sum(N[,j])
        Iup = Iup+N[i,j]*log((N[i,j]*S)/(Ni.*N.j))
      }
    }
  }
  Idown1=0;Idown2=0
  for (i in 1:CA){
    Ni.=sum(N[i,])
    Idown1=Idown1+Ni.*log(Ni./S)
  }
  for (j in 1:CB){
    N.j=sum(N[,j])
    Idown2=Idown2+N.j*log(N.j/S)
  }
  I=-2*Iup/(Idown1+Idown2)

  return(I)
}
