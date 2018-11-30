#!/usr/bin/perl
use strict; use warnings;
use IPC::System::Simple qw(
  capture capturex system systemx run runx $EXITVAL EXIT_ANY
);
my $seed_count = $ARGV[0]; 
my %forty=(); my %exists_pasted=(); my $average_on_target_efficiency_score = $ARGV[1];
open ( my $fh, '<', "./tmp/saved_thermo.txt");
my %sum = (); my %cut_locations=();
while (my $row = <$fh>){
	chomp $row;
	my @splitrow = split("\t", $row);
	my $seq_PAM = substr($splitrow[3], 10, 23);
	push @{$forty{$splitrow[1]}{$seq_PAM}}, $splitrow[3];
	$exists_pasted{$splitrow[2]} = 1;
	$sum{$splitrow[1]}{$seq_PAM} += $splitrow[4];
}
close $fh;

open ( my $fh2, '<', "./tmp/cutoff.txt");
my %cut_off_coverage=();
while (my $row = <$fh2>){
	chomp $row;
	my @splitrow = split("\t", $row);
	$cut_off_coverage{$splitrow[0]}{$splitrow[1]} = $splitrow[2];
}
close $fh2;

my $g=0;
my $j = 0;
open ( my $fh3, '<', "./tmp/tmp_txt.txt");
my %full23=(); 
while (my $row = <$fh3>){
	chomp $row;
	if (!($row =~ /^>>/)){
		my @splitrow = split('\|', $row);
		if (exists($exists_pasted{$splitrow[3]})){			
			push @{$full23{$splitrow[3]}{$splitrow[1]}}, $splitrow[2];
			my $l = $splitrow[4];
			$l =~ s/[-+]//;
			push @{$cut_locations{$splitrow[1]}{$splitrow[3]}}, $l;
		}
	}
}
close $fh3;
my @ones = ();
my %exons=();
if ($ARGV[4]){
	open ( my $fh4, '<', "./tmp/exon_file.txt");
		while (my $row = <$fh4>){
			chomp $row;
			my @splitrow = split('\|', $row);
			push @{$exons{$splitrow[0]}{$splitrow[1]}}, $splitrow[2];
		}
	close $fh4;
}
my $rna; my $dna; my $position; my %matrix=();
open (my $fh5, "<", "tools/CFD_Scoring/mismatch_score.pkl");
while (my $row = <$fh5>){
	chomp $row;
	if ($row =~ /^sS/ || $row =~ /^S/){
		( $rna, $dna, $position ) = $row =~ /^s?S\'r([a-zA-Z])\:d([a-zA-Z])\,([0-9]+)\'$/;
	}
	elsif ($row =~ /^F/){
		my ( $num ) = $row =~ /^F([\.0-9]+)/;
		$matrix{$rna}{$dna}{$position} = $num;
	}
}
close $fh5;

my $alternate_pam=""; my %pams=();
open (my $fh6, "<", "tools/CFD_Scoring/pam_scores.pkl");
while (my $row = <$fh6>){
	chomp $row;
	if ($row =~ /^sS/ || $row =~ /^S/){
		( $alternate_pam  ) = $row =~ /^s?S\'([a-zA-Z]{2})\'$/;
	}
	elsif ($row =~ /^F/){
		my ( $num ) = $row =~ /^F([\.0-9]+)/;
		$pams{$alternate_pam} = $num;
	}
}
close $fh6;

printf "\n";
my %accepted=();
my %scores=();
my %potential_sites = ();
my @a = (); my $u = 0;
my $size = keys %sum;
print "size: ".$size."\n";
foreach my $seq_id (keys %sum){
	foreach my $seq_PAM (keys %{$sum{$seq_id}}){
		foreach my $seq_id2 (keys %{$full23{substr($seq_PAM, length($seq_PAM)-$seed_count)}}){
			unless ($seq_id eq $seq_id2){
				foreach (@{$full23{substr($seq_PAM, length($seq_PAM) - $seed_count)}{$seq_id2}}){
					push @a, $seq_id2.":".$_;
				}
			}
		}
		my ( $average_on_score )= avg_on_score($sum{$seq_id}{$seq_PAM}, scalar(@{$forty{$seq_id}{$seq_PAM}}));
		if ($average_on_score >= $average_on_target_efficiency_score){
			( $scores{$seq_id}{$seq_PAM}, $potential_sites{$seq_id}{$seq_PAM} ) = get_CFD($seq_PAM, \@a);
			$scores{$seq_id}{$seq_PAM}+=1;
			$scores{$seq_id}{$seq_PAM}= sprintf "%.1f", $scores{$seq_id}{$seq_PAM};
		}
		@a=();
	}
}


my $coverage=""; my $f = ""; my $s = ""; 
open ( my $fh_output, '>', "./output/all.csv");
printf "final score\n";
print $fh_output "Chr,Sequence,SSV,Avg_On Target,CFD,Cuts,Coverage(%),Genes Affected,Genes on, Off target sites\n";
foreach my $seq_id ( sort { $a cmp $b} keys %scores){
	foreach my $seq_PAM ( keys %{$scores{$seq_id}}){
		my @splices=();
		my $splice_full="";
		my $count_genes_affected=0;
		foreach my $splices (@{$cut_locations{$seq_id}{substr($seq_PAM, length($seq_PAM)-$seed_count)}}){
			my $cuts_in_exons=0;
			foreach my $accession (keys %{$exons{$seq_id}}){
				foreach (@{$exons{$seq_id}{$accession}}){
					my $location_range = $_;
					my ( $start ) = $location_range =~ /([\d]+)-/;
					my ( $end )= $location_range =~ /-(\d+)/; 
					$end = $end +0;
					if ($splices > $start && $splices <= $end){
						$splice_full .= $splices.":".$accession." ";
						$count_genes_affected++;
						$cuts_in_exons = 1;
					}
				}
			}
			if ($cuts_in_exons ==0){
				$splice_full.= $splices.":none ";
			}
		}
		my $i = 1;
		my @accessions_array=();
		while ($i < scalar(@splices)){
			if (!(grep (/$splices[$i]/, @accessions_array))){
				push @accessions_array, $splices[$i];
			}
			$i+=2;
		}
		$i=1;
		my $coverage = $cut_off_coverage{$seq_id}{substr($seq_PAM, length($seq_PAM)-$seed_count)};
		$coverage = sprintf "%.3f", $coverage;
		my ( $SSV, $avg ) = SSV( $sum{$seq_id}{$seq_PAM}, $scores{$seq_id}{$seq_PAM}, scalar(@{$forty{$seq_id}{$seq_PAM}}), $coverage);
		if ($avg > $average_on_target_efficiency_score){
			printf $fh_output $seq_id.",".$seq_PAM.",".$SSV.",";
			printf $fh_output $avg.",".$scores{$seq_id}{$seq_PAM}.",";
			my $cuts = scalar(@{$cut_locations{$seq_id}{substr($seq_PAM, length($seq_PAM)-$seed_count)}});
			printf $fh_output $cuts.",";
			printf $fh_output 100 * $coverage;
			printf $fh_output ",";
			printf $fh_output $count_genes_affected.",";
			printf $fh_output $splice_full.",";
			print $fh_output $potential_sites{$seq_id}{$seq_PAM}.",";
			printf $fh_output "\n";
		}
		
		
	}
	
}
close $fh_output;
my %exists=();
sub get_CFD {
	my ( $wt, $a  ) = @_;
	my @a = @{$a};
	my $sum=0;
	my $score;
	my $off_target_cuts = "";
	if (scalar(@a) > 0){
		foreach my $a (@a){
			my @splitrow = split('\:', $a);
			if (!(exists ($exists{$wt}{$a}))){
				$score=0;
				$score= cfd_calculator($wt, $splitrow[1]);
				if ($score > $ARGV[2]){
					$off_target_cuts .= " ".$a;
				}	
				$sum += $score;
				$exists{$wt}{$a} = $score;
			}
			else{
				$sum+=$exists{$wt}{$a};
			}
		}
	}
	else{
		$sum = 0;
	}
	return (($sum, $off_target_cuts ));
}
sub cfd_calculator{
	my ( $wt, $off )=@_;
	my $score_o; my $score=1;
	$score =1;
	for (my $i = 0; $i < length($wt); $i++){			
		my $a_letter = substr($wt, $i, 1); my $b_letter = substr($off, $i, 1);
		if ($i <= 19 && $a_letter ne $b_letter){
			$a_letter =~ tr/T/U/;; $b_letter =~ tr/AGCTagct/TCGAtcga/;
			$score_o = $matrix{$a_letter}{$b_letter}{$i+1}; $score = $score_o * $score; 
		}
		elsif($i == 21 && substr($off, $i, 2)){
			$score= $score * $pams{substr($off, $i, 2)}; 
		}
	}
	return $score;
}


sub SSV {
	my ( $sum_on_target_efficiency, $CFD_plus, $scalar, $coverage  )= @_;
	if (!($scalar >=1)){
		$scalar =1;
	}
	my $avg_on = $sum_on_target_efficiency/$scalar;

	my $SSV = $coverage/$CFD_plus;
	$avg_on= sprintf "%.3f", $avg_on;
	$SSV= sprintf "%.3f", $SSV;

	return ($SSV, $avg_on);
}
sub avg_on_score {
	my ( $sum_on_target_efficiency, $scalar ) = @_;
	my $avg_on = $sum_on_target_efficiency/$scalar;
	return $avg_on;
}

