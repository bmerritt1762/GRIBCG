#!/usr/bin/perl
use strict; use warnings;
open ( my $fh_Output, '>', "./tmp/fullseqs.txt");
open ( my $fh, '<', "./tmp/tmp_txt.txt");
my %fullseqs=();
while (my $row = <$fh>){
	chomp $row;
	if (!($row =~ /^>>/)){
		my @splitrow = split('\|', $row);
		printf $fh_Output $splitrow[1]."\t".$splitrow[3]."\t".$splitrow[5]."\n";;
	}
}
close $fh;
close $fh_Output;