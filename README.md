## GRIBCG
------------------------

## About

Balancer chromosomes are tools used by fruit fly geneticists to prevent meiotic recombination. Recently, CRISPR/Cas9 genome editing has been shown capable of generating inversions similar to the chromosomal rearrangements present in balancer chromosomes. Extending the benefits of balancer chromosomes in other multicellular organisms could significantly accelerate biomedical and plant genetics research. 

Here, we present GRIBCG (Guide RNA Identifier for Balancer Chromosome Generation), a tool for the rational design of balancer chromosomes. GRIBCG identifies single guide RNAs (sgRNAs) for use with Streptococcus pyogenes Cas9 (SpCas9). These sgRNAs would efficiently cut a chromosome multiple times while minimizing off-target cutting in the rest of the genome. We describe the performance of this tool on six model organisms and compare our results to two routinely used fruit fly balancer chromosomes. 

GRIBCG is the first of its kind tool for the design of balancer chromosomes using CRISPR/Cas9. GRIBCG can accelerate genetics research by providing a fast, systematic and simple to use framework to induce chromosomal rearrangements.

## Dependencies & Languages

# Languages: Perl 5 & R 3.4.4
# Dependencies: Perl Tk GUI, predictSGRNA, BioPerl

## Additional Information

This is a a local run-tool for Linux-based platforms. Throughout testing has not been performed on Windows or Mac. 

GRIBCG generates several temporary files during its process. Because of the size of some genomes, it is recommended to allow several gigabytes of storage for organisms of larger genome sizes. In addition, the recommended memory changes based on genome size as well. Mouse, for instance, requires over 8 GB of Memory whereas A. thaliana requires 970 MB. 

## Tutorial
Refer to usage.pdf for a walkthrough of this tool

## Resource Locations
predictSGRNA: http://www.ams.sunysb.edu/~pfkuan/softwares.html#predictsgrna

CFD Scoring Matrix: https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4744125/

Perl Tk GUI: https://metacpan.org/pod/Tk::UserGuide

BioPerl: https://bioperl.org/INSTALL.html
