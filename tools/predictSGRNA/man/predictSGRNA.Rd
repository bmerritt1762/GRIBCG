\name{predictSGRNA}
\alias{predictSGRNA}
\title{
Predicts sgRNA efficiency
}
\description{
Predicts sgRNA efficiency from position dependent dinucleotide model of Kuan et al. (2016).}
\usage{
predictSGRNA(seq.vec, outfile = "output")
}
\arguments{
  \item{seq.vec}{
sgRNA sequences each of length 40 bps. See details.
}
  \item{outfile}{
output file name
}
}
\details{
It is important to note that each sequence must be of length 40 bps (5' flanking + sgRNA target sequence + PAM + 3' flanking), with the PAM (NGG) sequence at position 31, 32 and 33 of the sequence.
}
\value{
Results are saved in outfile.csv. First column is the sequence. Second column is the predicted class (either "Efficient" or "NotEfficient"). Third column is the predicted probability of being "Efficient". The higher the probability, the more likely the sgRNA will be efficient.
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
