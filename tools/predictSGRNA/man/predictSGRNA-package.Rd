\name{predictSGRNA-package}
\alias{predictSGRNA-package}
\alias{predictSGRNA}
\docType{package}
\title{
Predict sgRNA efficiency
}
\description{
The predictSGRNA package predicts sgRNA efficiency from position dependent dinucleotide model of Kuan et al. (2017).
}
\details{
\tabular{ll}{
Package: \tab predictSGRNA\cr
Type: \tab Package\cr
Version: \tab 1.0\cr
Date: \tab 2016-06-13\cr
License: \tab  GPL (>= 2)\cr
}
}
\author{
Pei Fen Kuan

Maintainer: Pei Fen Kuan <peifen.kuan@stonybrook.edu>
}
\references{
P.F. Kuan, S. Powers, S. He, K. Li, X. Zhao and B. Huang (2017). A systematic evaluation of nucleotide properties for CRISPR sgRNA design. BMC Bioinformatics, 18:297, DOI: 10.1186/s12859-017-1697-6.
}
\seealso{
\code{\link{predictSGRNA}}
}
\examples{
head(exampleData)
predictSGRNA(exampleData,'TestFile')
}
