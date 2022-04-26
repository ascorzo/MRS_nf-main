#!/usr/bin/perl
#=========
#
#
#
use File::Basename;
#%%
# 1. Beffore Run beggins check for experiment parameters

print "What\'s The subjects Name?\n";
$subj_name					= <STDIN>;
chomp($subj_name);

print "Experiment Date?\n (day/month/year)\n";
$exp_date					= <STDIN>;
chomp($exp_date);

print "TR? (in seconds)\n";
$exp_trials					= <STDIN>;
chomp($exp_trials);

print "Number of trials? (include baseline trials)\n";
$exp_trials					= <STDIN>;
chomp($exp_trials);

print "Number of baseline trials?\n";
$exp_baselineTrials			= <STDIN>;
chomp($exp_baselineTrials);

print "Incoming files (ima or rda) (only IMA supported)\n";
$file_ext					= <STDIN>;
chomp($file_ext);

print "Input directory (incoming files from scanner directory)\n";
$file_dir					= <STDIN>;
chomp($file_dir);

#%%
#######################################################################
####################	MAIN LOOP START		###########################
#######################################################################

@file_list = 1..$exp_trials;
print("NUMBER OF TRIALS = $#file_list\n");

foreach $trial (@file_list){

	$filebase		= "${file_dir}${trial}";
	$ima_file		= "${filebase}.${file_ext}";
	($filename, $dirs, $suffix) = fileparse($ima_file);
	
	#1. Check if file exist or wait for it to appear
	print "[$0]: waiting for $filename to appear...\n";
	sleep 0.2 while not -e $ima_file;

	# 2.Create header and RAW file
	`./ima_mrs2raw_hdr -in $ima_file` or die "could not create RAW file\n";
	print "[$0]:raw files created\n";
	
	# 3. Create control file
    `./lcm_create_control $ima_file` or die "could not create Control file\n";
	print "[$0]:control files created\n";

	# 4. Execute lcmodel files
	`chmod +x "$dirs$filename.lcmodel`;
	`"$dirs./$filename.lcmodel"` or die "could not analyze lcmodel file\n";
	print "[$0]: Lcmodel analisis terminated\n";

	# 5. Create txt files from .table files
	`./lcm_table2txt_sv "$dirs$filename.table"` or die "could not create Control file\n";
	print "[$0]: lc_out txt file created\n";




}

exit();
