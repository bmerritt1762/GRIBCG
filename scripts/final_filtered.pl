#!/usr/bin/perl


open ( my $fh, '<', "./output/all.csv");
my %rows_filtered=();
my %rows_f = ();
my $i=0;
my $seed_count = $ARGV[0];
if ($ARGV[2] eq "Yes") {
	while (my $row = <$fh>){
		chomp $row;
			if ($i >0){
			my @splitrow = split(',', $row);
			if (exists ($rows_filtered{$splitrow[0]}{substr($splitrow[1], length($splitrow[1])-$seed_count)})){
				my @splitrow2 = split(',', $rows_filtered{$splitrow[0]}{substr($splitrow[1], length($splitrow[1])-$seed_count)});
				my $SSV = $splitrow2[2];
				if ($SSV < $splitrow[2]){
					$rows_filtered{$splitrow[0]}{substr($splitrow[1], length($splitrow[1])-$seed_count)} = $row;
				}
			}
			else{
				$rows_filtered{$splitrow[0]}{substr($splitrow[1], length($splitrow[1])-$seed_count)} = $row;
			}
			
		}
		$i++;
	}
}
else{
	while (my $row = <$fh>){
		chomp $row;
			if ($i >0){
			my @splitrow = split(',', $row);
			if (exists ($rows_filtered{$splitrow[0]}{substr($splitrow[1], length($splitrow[1])-$seed_count)})){
				my @splitrow2 = split(',', $rows_filtered{$splitrow[0]}{substr($splitrow[1], length($splitrow[1])-$seed_count)});
				my $coverage = $splitrow2[6];
				if ($coverage < $splitrow[6]){
					$rows_filtered{$splitrow[0]}{substr($splitrow[1], length($splitrow[1])-$seed_count)} = $row;
				}
			}
			else{
				$rows_filtered{$splitrow[0]}{substr($splitrow[1], length($splitrow[1])-$seed_count)} = $row;
			}
			
		}
		$i++;
	}
}
close $fh;

open (my $fh_output, '>', "./output/final.csv");
printf $fh_output "Chr,Sequence,SSV,Avg On Target,CFD,Cuts,Coverage(%),# Genes Affected,Genes,Off target sites (high probability)\n";
foreach my $seq_id (sort{ ($a) <=> ($b)} keys %rows_filtered){
	my $i = 0;
	foreach my $seq_partial (  sort {get($rows_filtered{$seq_id}{$b})<=>get($rows_filtered{$seq_id}{$a})}   keys %{$rows_filtered{$seq_id}}){
		printf $fh_output $rows_filtered{$seq_id}{$seq_partial}."\n";
		if ($i+1 >= $ARGV[1]){
			last;
		}
		$i++;
	}
}
close ($fh_output);

sub get {
	my ( $row ) = @_;
	my @splitrow = split(',', $row);
	my $g =$splitrow[2];
	return ($g);
}