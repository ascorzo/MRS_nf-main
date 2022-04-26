#!/usr/bin/perl
#=========
#
#usage: get_glutamate_values.pl <PROJECT_TXT_FILE>
#

use File::Basename;

my($filename, $dirs, $suffix) = fileparse($ARGV[0]);

if ( -e "${dirs}glu.txt" ){
	print "[$0]: File already exist, don't worry about it\n[$0]: Detected File: ${dirs}glu.txt\n";
} else{
	`cat "$ARGV[0]" | cut -d " " -f 17 | cut -f 15 >> "${dirs}glu.txt" `;
	print "[$0]: glu.txt created\n[$0]:Directory: $dirs\n";
}
exit
