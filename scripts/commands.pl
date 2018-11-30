#!/usr/bin/perl

use strict; use warnings;
use Getopt::Long;

my $seed_count;
my $on_target_cutoff;
my $cutoff;
my $raise_cut_max;
my $display_count;
my $run_test;
my @files=();
my $test = -1;
my $title;
my $exon_yes = "";
my $off_target_important="Yes";
GetOptions ("s=i" => \$seed_count,    # numeric
              "o=f"   => \$on_target_cutoff,      # specify the on target cutoff
              "c=f"  => \$cutoff, #specify the cutoff percentage for off-target
              "r=i" => \$raise_cut_max, #specify custom max cut count desired
       		  "f=s" => \@files, #give files (Fasta)
       		  "t=s" => \$title,  #give string of title of output
       		  "test=i" => \$test,
       		  "e=s" => \$exon_yes, 
            "i=s" => \$off_target_important,
                       "d=i" => \$display_count)   # if invoked, run test on script and give the specified test run (integer value)
or die("Error in command line arguments\n");
foreach (@files){
	print $_."\n";
}

if ($test != -1){
	system("perl ./test/validate.pl $test"); exit;
}

print "Screening all sgRNAs\n";
system("perl scripts/g2.pl $seed_count @files");
print "Finding coverage and cut counts for PSSs\n";
system("./scripts/get_ratio_max.pl $seed_count $cutoff");
print "Filtering based on coverage and cut count\n";
system("./scripts/get_CFD.pl $seed_count $cutoff $raise_cut_max");
print "Determining on-target scores\n";
system("./scripts/filtered.pl $seed_count");
if ($exon_yes ne ""){
	print "Creating OPTIONAL gene location file\n";
	system("./scripts/make_exon_file.pl $seed_count $exon_yes");
}
print "Determining off-target activity, SSV, and OPTIONAL on-chromosome (same on-chromosome) genes affected for each PTS\n";
system("./scripts/get_off_target_score.pl $seed_count $on_target_cutoff $cutoff $off_target_important $exon_yes");
print "finishing\n";
system("./scripts/final_filtered.pl $seed_count $display_count $off_target_important");
`rm ./tmp/*`;
`mv output/final.csv $title`;

