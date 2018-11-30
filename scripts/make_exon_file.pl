#!/usr/bin/perl
use strict; use warnings;


open (my $fh, '<:encoding(UTF-8)', "tmp/cutoff.txt") or
 	die "could not open file: tmp/cutoff.txt $!";
my %exists=();
while (my $row = <$fh>){
	chomp $row;
	my @splitrow = split('\t', $row);
	if (!($exists{$splitrow[0]})){
		$exists{$splitrow[0]} = 1;
	}
}



my %exons=();
my %accessions=();
my $exon_checker_file = $ARGV[1];
#my $exon_checker_file = "./data/test_seq_file.txt";
open (my $fh_exons, '<:encoding(UTF-8)', $exon_checker_file) or
 	die "could not open file: $exon_checker_file $!";
while (my $row = <$fh_exons>){
	chomp $row;
	if ($row =~ /^>/){
		my @split = split('\|', $row);
		my ( $accession ) = $row =~ /(>[\d\w.]+|)/;
		my ( $chromosome, $location ) = $row =~ /\|\s*([^\s]+)?:[\s]?([\d-]+)/;
		if ($exists{$chromosome}){	
			push @{$exons{$chromosome}{$accession}}, $location;
		}
		
		
	}


}
close $fh_exons;

open (my $fh_Output, '>', "./tmp/exon_file.txt");


foreach my $chromosome (keys %exons){
	foreach my $accession (keys %{$exons{$chromosome}}){
		printf $fh_Output $chromosome."|".$accession."|";
		foreach my $location_range (@{$exons{$chromosome}{$accession}}){
			printf $fh_Output $location_range.",";
		}
		printf $fh_Output "|"."\n";
	}
}

close $fh_Output;