#!/usr/bin/perl

use strict; use warnings; 
my @files = @ARGV[1..scalar(@ARGV)-1];
foreach (@files){
	print $_."\n";
}
my $seq_id;
my $seed_count = $ARGV[0];
my @explored_id=();  my @array=();
my $found=0; my $loca; my $k = 0;
my %sizes=(); my $seq_length=0;
my %fullseqs=();
my %accepted;
my @sequence_ids=();
my %count = (); my $off_target_count=0; my $size = 0;
my $number = ""; my @a=(); my $fullseq; my $current_seq; my $partial;

open (my $fh_Output, '>', "./tmp/tmp_txt.txt");
open (my $fh_output_test_fullseqs, ">", "./tmp/test_on_target_score.txt");
#loop through each file contents
use Bio::SeqIO; 
foreach my $fileName (@files){
	my $seqio = Bio::SeqIO->new(-file => $fileName, '-format' => 'Fasta');
	while(my $seq = $seqio->next_seq) {
		my $file = $seq->display_id;
		my $pam = "NGG";
		my $length = $seq->length;
		my $seq_id = $seq->display_id;
		if ($seq_id =~ /NC/i || $seq_id =~ /NT_/i){
			print $fh_Output ">>".$seq->display_id."\t".$length."\n";
			push @sequence_ids, $seq_id;
			$current_seq = $seq->seq;
			find_seq( $current_seq, $pam, $length, $seq_id, $file );
		}
	}
}

sub combine {
	my ( $seq_id, $fullseq, $loca ) = @_;
	if ($fullseq =~ /^[AGTCUagtcu]+$/ && length($fullseq) == 40){	
		my $seq = substr($fullseq, 33-23, 23);
		my $partial = substr($seq, length($seq)-$seed_count, $seed_count);
		print $fh_Output $k."|".$seq_id."|".$seq."|".$partial."|".$loca."|".$fullseq."|\n";
		print $fh_output_test_fullseqs $fullseq."\n";
		$k++;
	}
}
#######Search with Bioperl for all possible NGG sequences (both strands)############
sub find_seq {
	my (  $current_string,  $pam, $length, $seq_id, $file  ) = @_;
	my $i = 0; my $last_string; %count=(); my $next_string; my $reverse_seq;
	my $started = 0; my $inc = 10; my $space=0; my $sequence; my $back_seq = 20; my $partial;  
	my %count = ();  
	$current_string = uc($current_string);
	my $found = 0; my $index = 0;
	my $backward = 10; my $forward = 7;
	$found = index($current_string, "GG", $index);
	while ($found > -1){
		if ($found -$back_seq-1  >= 0){
			if ($found - $back_seq - $backward -1 >= 0 && $found + length($pam)-1 + $forward <= $length){
				$fullseq = substr($current_string, $found - $back_seq-$backward - 1, $backward + $back_seq+ length($pam)+$forward);
				$sequence = substr($current_string, $found-$back_seq-1, $back_seq + length($pam));
				$partial = substr($sequence, 5, length($sequence)-5);
				combine( $seq_id, $fullseq, $found);
				$size++;				
			}
		}
		$index = $found +1;
		$found = index($current_string, "GG", $index);
	}
	$found = -1; $index = 0;
	$found = index($current_string, "CC", $index);
	my $reverse_fullseq;
	while ($found > -1){
		if ($found +$back_seq+length($pam)  <= $length){
			if ($found - $forward >= 0 && $forward + length($pam) + $back_seq + $backward <= $length){
				$fullseq = substr($current_string, $found - $forward,  $forward + length($pam) + $back_seq + $backward);
				$sequence = substr($current_string, $found, $back_seq + length($pam));
				$reverse_seq = reverse($sequence); $reverse_seq =~ tr/AGCT/TCGA/;
				$partial = substr($sequence, 5, length($sequence)-5);
				$reverse_fullseq = reverse($fullseq); $reverse_fullseq =~ tr/AGCT/TCGA/;
				combine( $seq_id, $reverse_fullseq, $found);
				$size++;
			}
		}
		$index = $found +1;
		$found = index($current_string, "CC", $index);
	}	
}