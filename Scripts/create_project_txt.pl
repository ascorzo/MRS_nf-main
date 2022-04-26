#!/usr/bin/perl
#=========
#Last modified: 12/10/2020
#
#
#Usage:
#	create_project_txt.pl  -OPTION path/FILENAME.lc_out
#	Option:
#	-c to create new project txt file
#	-u to update the project txt file
#Output: Creates or updates
#note: FILENAME corresponds to the name of the file whith the output from:
#		lcm_table2txt_sv FILENAME.table
#
#
use File::Basename;


$filename = $ARGV[1];
($basefile, $dirs, $suffix) = fileparse($filename);
@split_basefile = split(/[m]\d/, $basefile);
print "@split_basefile\n";
$project_txt_file = "$dirs$split_basefile[0].txt";
@split_project_txt_file = split("/", $project_txt_file);
$project_txt_file_base = $split_project_txt_file[$#$split_project_txt_file];
#options
if ($ARGV[0] eq "-c"){
	$option = "create";
}elsif ($ARGV[0] eq "-u"){
	$option = "update";
}elsif($ARGV[0] =~ m/\/|.lc_out/){
	print "[$0]:Specify -c or -u before the file. Unexpected input\n";
	exit;
}else{
	print "[$0]:Check input. Something is wrong with your input options\n";
	exit;
}

#Check if file exists and if the option is set to update or create
if ( -e $project_txt_file) {
	if ($option eq "update" ){
		`cat "$filename" >> "$project_txt_file"`;
		print "[$0]: Project file \"$project_txt_file_base\" updated\n";
		exit;
	} elsif ($option eq "create"){
		print "[$0]: Process interrupted. Project file \"$project_txt_file_base\" already exist\n";
		exit;
	} else{
		print "[$0]: File \"$project_txt_file_base\" exist but options are wrong\n";
		exit;
	}
}else{
	if ($option eq "update" ){
		print "[$0]: Project file \"$project_txt_file_base\" could not be updated. File not found\n";
		exit;
	}elsif ($option eq "create"){
		`cat "$filename" >> "$project_txt_file"`;
		print "[$0]: Project file \"$project_txt_file_base\" succesfuly created\n";
		exit;
	} else{
		print "[$0]: File \"$project_txt_file_base\" not found but options are wrong";
		exit;
	}
}
print "[$0]: Something went wrong. This message should not appear\n";
exit;
