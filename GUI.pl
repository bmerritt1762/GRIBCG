#!/usr/bin/perl


use Tk; 
use Tk::FileSelect;
use Tk::Toplevel;
use Tk::Optionmenu;
use Tk::Balloon;
use Tk::Canvas;
my $file=''; my @array_of_files=();
 my $stored_Files=""; my $selected_exon_file="";
use warnings;
use strict;
my $title = "default.csv";
my $exon_checker_file;
my $fh;
my $seed_count=18;
my $file_exons = "";
my $on_target_cutoff=0.5;
my $display_count = 5;
my $cutoff=0.7;
my $raise_cut_max="";
my $run_test=0;
my $off_target_important = "Yes";
my $pam_mismatch_file = "./CFD_Scoring/pam_scores.pkl";
my $mismatch_file = "./CFD_Scoring/mismatch_score.pkl";
my $change_pam_mismatch_display; my $change_mismatch_display;
my $mw = MainWindow->new;
$mw->geometry("500x300");
$mw->title("Pam Finder");


#create message area at the bottom of the screen for help on hovering over given label
my $help_space = $mw -> Label(-borderwidth => 2, -relief => 'groove')->pack(-side => 'bottom', -fill => 'x');

#Change the output of the file
my $project_title = $mw->Label(-text => "Project Title", -anchor =>"nw")-> place (-anchor => "nw", -x => 20, -y => 20);
my $user_project_input=$mw->Entry(-textvariable => \$title, -background => 'black', -foreground => 'white')-> place (-anchor => "nw", -x => 120, -y => 20);

#Reset everything to default
my $reset_button = $mw -> Button (-text => "Reset All", -command => \&reset_all) -> place (-anchor => "nw", -x => 300, -y => 15);

#About This GUI and what it does. Opens a subwindow that contains information on the script similar to README
my $help_button = $mw -> Button (-text => "About", -command => \&about ) -> place (-anchor => "nw", -x => 300, -y => 60 );

#selecting files to input (should be entire genome included. Can be multiple files)
my $file_selector = $mw -> Button(-text => "Input Files*", - command => \&file_viewer)-> place (-anchor => "nw", -x => 20, -y => 60);
my $fileSelected = $mw->Label(-text => "Selected Files");
my $selected_files = $mw->Label(-text => $stored_Files, -background=>'white')-> place (-anchor => "nw", -x => 120, -y => 65);
my $file_selector_balloon = $mw -> Balloon(-statusbar => $help_space);
$file_selector_balloon -> attach($file_selector, -statusmsg => "Input FASTA file(s) ONLY. Be sure the entire genome is covered.");


#select a file containing genes that will tell the user if a specific cut site occurs within a gene region
my $exon_button = $mw->Button(-text => "Gene File", -command => \&exon_file_search)-> place (-anchor => "nw", -x => 20, -y => 100);
my $selected_exon_file_display = $mw->Label(-text => $selected_exon_file, -background=>'white')-> place (-anchor => "nw", -x => 120, -y => 105);
my $exon_button_balloon = $mw -> Balloon(-statusbar => $help_space);
$exon_button_balloon -> attach($exon_button, -statusmsg => "Optional. Select FASTA file containing all gene regions in chromosomes.");


#Changing parameters for selecting sgRNA (only for advanced users that know how it runs)
my $parameters = $mw ->Button(-text => "Change Parameters", -command => \&alter_parameters)-> place (-anchor => "nw", -x => 20, -y => 140);
my $parameters_balloon = $mw ->Balloon(-statusbar => $help_space);
$parameters_balloon->attach($parameters, -statusmsg  => "Advanced option. Change specific parameters for GRINCH", -balloonmsg => "Advanced Options", -balloonposition => 'mouse');

my $run = $mw->Button(-text => "Execute Run", -command => \&run_sub) -> place (-anchor => "nw", -x => 20, -y => 180);


$fileSelected->configure(-background =>'yellow');


MainLoop;

sub alter_parameters{
	$mw->geometry("500x500");
	my ( $tvar, $var );
	my @range = (5..23);
	my $seed_options  = $mw -> Optionmenu(
		-options => [@range],
		-variable => \$seed_count,
		-textvariable => \$seed_count,
		-command => [sub {print $seed_count}],
		 ) -> place( -anchor => "nw", -x => 20,  -y => 230);
	my $seed_count_text = $mw -> Label(-text => "Seed count") -> place (-anchor => "nw", -x => 100, -y => 230);
	my $help_circle1 = $mw -> Radiobutton(-text => "?") -> place (-anchor => "nw", -x => 180, -y => 230);
	my $help_circle_balloon = $mw -> Balloon(-statusbar => $help_space);
	$help_circle_balloon-> attach($help_circle1, -statusmsg => "Change size of seed proximal to PAM");


	my $on_target_minimum = $mw -> Entry(-textvariable => \$on_target_cutoff, -width => 10)-> place ( -anchor => "nw", -x => 20, -y => 260);
	my $on_target_minimum_text = $mw -> Label(-text => "Minimum On-target score") -> place( -anchor => "nw", -x => 100, -y => 260);
	my $help_circle2 = $mw -> Radiobutton(-text => "?") -> place (-anchor => "nw", -x => 260, -y => 260);
	$help_circle_balloon-> attach($help_circle2, -statusmsg => "Alter minimum on-target score. Selects only above or equal to value");


	my $cutoff_minimum = $mw -> Entry(-textvariable => \$cutoff, -width => 10) -> place( -anchor => "nw", -x => 20, -y => 290 );
	my $cutoff_minimum_text = $mw -> Label (-text => "Cutoff for total balanced zones") -> place(-anchor => "nw", -x => 100, -y => 290) ;
	my $help_circle3 = $mw -> Radiobutton(-text => "?") -> place (-anchor => "nw", -x => 290, -y => 290);
	$help_circle_balloon-> attach($help_circle3, -statusmsg => "Minimize balancer regions. 2 MBp are balanced on either side of cut.");




	my $raise_cut_max_select = $mw -> Entry(-textvariable => \$raise_cut_max, -width => 10) -> place ( -anchor => "nw", -x => 20, -y => 320);
	my $raise_cut_max_select_text = $mw -> Label(-text => "Maximum cuts for balancer to take place") -> place (-anchor =>"nw", -x => 100, -y => 320)  ;
	my $help_circle4 = $mw -> Radiobutton(-text => "?") -> place (-anchor => "nw", -x => 340, -y => 320);
	$help_circle_balloon-> attach($help_circle4, -statusmsg => "Specify how max cuts that can occur for balanced chromosomes");


	my $change_pam_mismatch_button = $mw->Button(-text => "Pam Mismatch File", -command => \&pam_file_search)-> place (-anchor => "nw", -x => 20, -y => 350);
	$change_pam_mismatch_display = $mw->Label(-text => $pam_mismatch_file, -background=>'white')-> place (-anchor => "nw", -x => 180, -y => 355);
	my $pam_mismatch_balloon = $mw -> Balloon(-statusbar => $help_space);
	$pam_mismatch_balloon -> attach($change_pam_mismatch_button, -statusmsg => "Input .pkl file containing mismatch scoring matrix for pam sequences.");


	my $change_mismatch_button = $mw->Button(-text => "Pam Mismatch File", -command => \&mismatch_file_search)-> place (-anchor => "nw", -x => 20, -y => 390);
	$change_mismatch_display = $mw->Label(-text => $mismatch_file, -background=>'white')-> place (-anchor => "nw", -x => 180, -y => 395);
	my $mismatch_balloon = $mw -> Balloon(-statusbar => $help_space);
	$mismatch_balloon -> attach($change_mismatch_button, -statusmsg => "Input .pkl file containing mismatch scoring matrix for single, non-PAM NT's.");

	my $change_display_count = $mw -> Entry(-textvariable => \$display_count, -width => 10) -> place ( -anchor => "nw", -x => 20, -y => 420);
	my $change_display_count_text = $mw -> Label(-text => "Ideal sgRNA count") -> place (-anchor =>"nw", -x => 100, -y => 420)  ;
	my $help_circle5 = $mw -> Radiobutton(-text => "?") -> place (-anchor => "nw", -x => 340, -y => 420);
	$help_circle_balloon-> attach($help_circle5, -statusmsg => "Specify number of ideal sgRNA's in output file for each sequence");

	my @yesNo = ("Yes", "No");
	my $yesNoDD  = $mw -> Optionmenu(
		-options => [@yesNo],
		-variable => \$off_target_important,
		-textvariable => \$off_target_important,
		 ) -> place( -anchor => "nw", -x => 20,  -y => 450);
	my $yesNoDD_text = $mw -> Label(-text => "Consider off target cutting? (Other chromosomes)") -> place (-anchor => "nw", -x => 100, -y => 450);
	
}	




sub file_viewer{
	#my $top = MainWindow-> new;
	#$top -> geometry("600x200");
	#$top -> title("File Selection Viewer");

	my $start_dir = ".";
	my $FSref = $mw->FileSelect(-directory => $start_dir);              
	my $file_Path = $FSref->Show;
 #              Executes the fileselector until either a filename is
  #             accepted or the user hits Cancel. Returns the filename
   #            or the empty string, respectively, and unmaps the
    #           FileSelect.
  	( $file ) = $file_Path =~ m/.*\/(.+)$/;
  	if ($file){	
  		if ($stored_Files ne ""){
	  		 $stored_Files .= ", ".$file;
	  	}
	  	else{
	  		$stored_Files .= $file;
	  	}
	  	if ( !(grep(/^$file$/, @array_of_files)  )){
	  		push @array_of_files, $file_Path;
	  	}
	}
  		 
   $selected_files->configure(-text => $stored_Files);
}


sub run_sub {
	#check to see if all parameters necessary are set
	if (!($file)){
		error_no_file();
	}
	else {
		if ($raise_cut_max eq ""){
			$raise_cut_max = 0;
		}
		print "seed count: $seed_count\t $on_target_cutoff\n";
		my $message = "Executing Script. This may take several minutes\n";
		$message .= "Saving results to: ".$title."\n";
 		my $run_button = $mw->messageBox(-message => $message,
                                        -type => "ok");
 		my $file_list = "";
 		foreach (@array_of_files){
 			$file_list .= "--f ".$_." ";
 		}
 		if (!($exon_checker_file) || !(-f $exon_checker_file)){
			print "No Exon Path chosen.\n";
			system("time -v perl scripts/commands.pl $file_list -s $seed_count -c $cutoff -r $raise_cut_max -t $title -d $display_count -o $on_target_cutoff -i $off_target_important ");
		}
		else{
			system("time -v perl scripts/commands.pl $file_list -e $exon_checker_file -s $seed_count -c $cutoff -d $display_count -r $raise_cut_max -t $title -o $on_target_cutoff -i $off_target_important");
		}
 		
 		my $finished_message = "Done. Results saved to $title";
 		my $finished_click = $mw->messageBox(-message => $finished_message, -type => "ok");
 		@array_of_files = ();
 		$selected_files -> configure(-text => "");
	}
}

sub exon_file_search{
	my $start_dir ="."; 
	my $FSref = $mw ->FileSelect(-directory => $start_dir);
	my $file_Path = $FSref->Show;
	$exon_checker_file = $file_Path;
	( $file_exons ) = $file_Path =~ m/.*\/(.+)$/;
	$selected_exon_file_display -> configure(-text=> $file_exons);
}

sub pam_file_search {
	my $start_dir = ".";
	my $FSref = $mw -> FileSelect(-directory => $start_dir);
	my $file_Path = $FSref->Show;
	$pam_mismatch_file = $file_Path;
	my ( $file_pam  ) = $file_Path =~ /.*\/(.+)$/;
	$change_pam_mismatch_display -> configure (-text => $file_pam);
}
sub mismatch_file_search {
	my $start_dir = ".";
	my $FSref = $mw -> FileSelect(-directory => $start_dir);
	my $file_Path = $FSref->Show;
	$mismatch_file = $file_Path;
	my ( $file_mm  ) = $file_Path =~ /.*\/(.+)$/;
	$change_pam_mismatch_display -> configure (-text => $file_mm);
}
sub error_no_file{
	my $error_message = "Error! Please input at least one file to parse (Fasta)\n";
	my $error_dialog = $mw->messageBox(-message => $error_message,
										-type => "ok");

}

sub reset_all {
	$title = "default.csv";
	foreach (@array_of_files){
		print $_.",";
	}
	@array_of_files = ();
	$stored_Files = "";
	foreach (@array_of_files){
		print $_.",";
	}
	$file_exons = "";
	$selected_files->configure(-text => $stored_Files);
	$exon_checker_file = "";
	$selected_exon_file_display -> configure(-text=> $file_exons);
	$seed_count=18;
	$on_target_cutoff=0.5;
	$display_count = 5;
	$cutoff=0.7;
	$raise_cut_max="";
	$run_test=0;
	$off_target_important = "Yes";
	$pam_mismatch_file = "./CFD_Scoring/pam_scores.pkl";
	$mismatch_file = "./CFD_Scoring/mismatch_score.pkl";
}

sub about {
	my $subwindow = $mw -> Toplevel;
	$subwindow -> geometry("500x400");
	$subwindow -> title("About");
	my $text = << "EOT";
Balancer chromosomes have been a normal feature of genetic developments across generations amongst D. melanogaster for decades. 
These specialized chromosomes are the result of multiple, nested inversions in a single chromosome, preventing homologous recombination. 
In addition, CRISPR/Cas9 has been reported as a method of successfully producing balancers in a variety of organisms. 


GRIBCG is designed as a tool to screen for all possible sgRNAs located throughout every chromosome of a defined FASTA file (genome file).
It utilizes multiple steps, generating temporary files in order to reduce the heavy need for memory for larger genomes. 
On-target and off-target activity are utilized via predictSGRNA and CFD scoring, respectively. 
Lastly, the tool attempts to maximize ensured coverage of an entire chromosome by reporting a coverage % for each breakpoint induced by CRISPR/Cas9. 
Users may also define FASTA files containing the locations of all genes for desired chromosomes that will be reported for each sgRNA after the filtering process. 


EOT

	my $information  = $subwindow -> Label( -wraplength => 390, -text => $text)-> place ( -anchor => "nw", -x => 20, -y => 20 );
}



