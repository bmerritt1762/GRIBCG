#!/usr/bin/perl
use strict; use warnings;

open ( my $fh, '<', "./tmp/tmp_txt.txt");
my %locations=();
my %seq_size=();
my $chr = "";
my %partials =();
my $sequence = 'null';

my $size;
open ( my $fh_Output, '>', "./tmp/coverage.txt");
while (my $row = <$fh>){
	chomp $row;
	if (!($row =~ /^>>/)){
		my @splitrow = split('\|', $row);
		push @{$locations{$splitrow[3]}}, $splitrow[4];
	}
	elsif ($row =~ /^>>/){
		if (($sequence ne "null")){
			foreach my $seq_partial (keys %locations){
				my ( $coverage ) = coverage(\@{$locations{$seq_partial}}, $size);
				$partials{$seq_partial} = $coverage;
			}
			foreach my $seq_partial (keys %partials){
				printf $fh_Output $sequence."|".$seq_partial."|".$partials{$seq_partial}."|";
				printf $fh_Output scalar(@{$locations{$seq_partial}});
				printf $fh_Output "|".$size."|".($partials{$seq_partial}/$size)."|";
				printf $fh_Output "\n";		
			}
		}
		( $sequence ) = $row =~ />>(.+?)\t/;
		( $size ) = $row =~ /\t(.+?)$/;
		$seq_size{$sequence} = $size;
		%locations = ();
		%partials = ();
	}	
}
foreach my $seq_partial (keys %locations){
	my ( $coverage ) = coverage(\@{$locations{$seq_partial}}, $size);
	$partials{$seq_partial} = $coverage;
}
foreach my $seq_partial (keys %partials){
	printf $fh_Output $sequence."|".$seq_partial."|".$partials{$seq_partial}."|";
	printf $fh_Output scalar(@{$locations{$seq_partial}});
	printf $fh_Output "|".$size."|".($partials{$seq_partial}/$size)."|";
	printf $fh_Output "\n";		
}
close $fh;
close $fh_Output;

sub coverage {
	my ( $b, $y  ) = @_;
	my $coverage = 0;
	my @range=();
	my $i;
	my @b = @{$b};
	s/[+]// for (@b);
	s/[-]// for (@b);
	my $buffer_zone= 2e06;
	my @a =sort(@b);	
	foreach my $lo (@a){
			$i=0; my $no_range_overlap=0;
			if (scalar(@range) == 0){
			} 
			else {
				while ($i < scalar(@range)){
					my $start =( $lo - $buffer_zone);
					my $end = ( $lo + $buffer_zone );
					if ($start >= $range[$i] && $start <= $range[$i+1]){
						$range[$i+1] = $end;
						$no_range_overlap = 1;
					}
					$i +=2;
				}
			}
			if ($no_range_overlap ==0){
				push @range, ($lo - $buffer_zone);
				push @range, ($lo + $buffer_zone);
			}
	}
	$i=0;
		my $p = "";
		my $reduced=0;
		while ($i < scalar(@range)){
			$reduced += ($range[$i+1] - $range[$i]);
			$p .= $range[$i]."-".$range[$i+1]."|";	
			$i+=2;
	}
	if ($reduced > $y){
		$reduced = $y;
	}
	return ($reduced);
}
exit;
# foreach my $seq_partial (keys %locations){
# 				my ( $coverage ) = coverage(\@{$locations{$seq_partial}}, $size);
# 				$partials{$seq_partial} = $coverage;
# 			}
# 			foreach my $seq_partial (keys %partials){
# 				printf $fh_Output $chr."|".$seq_partial."|".$partials{$seq_partial}."|";
# 				printf $fh_Output scalar(@{$locations{$seq_partial}});
# 				printf $fh_Output "|".$size."|".($partials{$seq_partial}/$size)."|";
# 				printf $fh_Output "\n";		
# 			}