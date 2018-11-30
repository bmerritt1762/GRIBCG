#!/usr/bin/perl
use strict; use warnings;

my %CFDs=();
my %cuts = ();
my %coverage = ();
my %seq_size=();
my $buffer_zone = 4e06;

open ( my $fh, '<', "./tmp/coverage.txt");
open ( my $fh_Output, '>', "./tmp/cutoff.txt");
my $cutoff = $ARGV[1];
my $additional_cuts = 0;
if ($ARGV[2]){
	$additional_cuts = $ARGV[2];
}

while (my $row = <$fh>){
	chomp $row;
	my @splitrow = split('\|', $row);
	if ($splitrow[3] <= cut_max($additional_cuts, $splitrow[4], $buffer_zone ) && $splitrow[3] > 1){
		if ($cutoff <= $splitrow[5]){	
			printf $fh_Output $splitrow[0]."\t".$splitrow[1]."\t".$splitrow[5]."\n";
		}
	}
}
close $fh;
close $fh_Output;

sub cut_max {
	 my ( $c, $seq_size, $buffer_zone  )=@_;
	 if ($c == 0){
	 	$c = int($seq_size / $buffer_zone) +1;
	 	if ($c <2){
	 		$c = 2;
	 	}
	 }
	 else{
	 	$c = $c;
	 }
	 return $c;
}

