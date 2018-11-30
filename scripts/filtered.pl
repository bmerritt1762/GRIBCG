#!/usr/bin/perl


use strict; use warnings;
open ( my $fh, '<', "./tmp/cutoff.txt");
my %filtered=();
while (my $row = <$fh>){
	chomp $row;
	my @splitrow = split('\t', $row);
	$filtered{$splitrow[0]}{$splitrow[1]}=1;
}
close $fh;
use strict; use warnings;
open ( my $fh2, '<', "./tmp/tmp_txt.txt");
my %fullseqs=();
my $i=0;
if (-e './tmp/pasted_thermodynamic_sequences.txt'){
	`rm ./tmp/pasted_thermodynamic_sequences.txt`;
}
if (-e "tmp/saved_thermo.txt"){
	`rm tmp/saved_thermo.txt`;
}
open ( my $fh_Output, '>', "./tmp/full_seqs_filtered.txt");
my @a = ();
while (my $row = <$fh2>){
	chomp $row;
	if (!($row =~ /^">>"/)){
		my @splitrow = split(/\|/, $row);
		if (scalar(@splitrow) > 2 && $filtered{$splitrow[1]}{$splitrow[3]}){
			printf $fh_Output $splitrow[1]."\t".$splitrow[3]."\t".$splitrow[5]."\n";
			$i++;
			if ($i > 100000	){
				$i = 0;
				`Rscript scripts/40NT.R`;
				`cat tmp/pasted_thermodynamic_sequences.txt >> tmp/saved_thermo.txt`;
				`rm tmp/full_seqs_filtered.txt`;
				close $fh_Output;
				open ($fh_Output, '>', "./tmp/full_seqs_filtered.txt");

			}
		}

		
	}
}
`Rscript scripts/40NT.R`;
`cat tmp/pasted_thermodynamic_sequences.txt >> tmp/saved_thermo.txt`;
`rm tmp/full_seqs_filtered.txt`;
close $fh2;
close $fh_Output;