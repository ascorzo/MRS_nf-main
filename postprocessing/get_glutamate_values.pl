#!/usr/bin/perl
#=========
#
#usage: get_glutamate_values.pl <PROJECT_TXT_FILE>
#

use File::Basename;

my($filename, $dirs, $suffix) = fileparse($ARGV[0]);
@basename = split(/[.]/, $filename);

$out_file = "$basename[0]_glu.txt";

if ( -e "${dirs}${out_file}_glu.txt" ){
	print "[$0]: File already exist, don't worry about it\n[$0]: Detected File: ${dirs}$out_file\n";
} else{
	`cat "$ARGV[0]" | cut -d " " -f 17 | cut -f 15 >> "${dirs}${out_file}" `;
	print "[$0]: $out_file created\n[$0]:Directory: $dirs\n";
}
exit
