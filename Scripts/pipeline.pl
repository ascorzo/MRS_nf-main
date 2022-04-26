#!/usr/bin/perl
#=========
#
#
#
use File::Basename;

# 1.Look for ima Files and sort them in the correct order
`ls -d /home/bmi/Documents/MRS/projects/fMRS_dataset_20201007/ocd748b/*m_*m*.ima | sort -V > ima_list.in`;

print "Is the list Ok?\n";

open(IMA_LIST, "ima_list.in");

while ($ima_file = <IMA_LIST>) {
	chomp($ima_file);
	print "$ima_file\n";
}
print "\n Enter \"no\" to stop the process\n";

$ok_list = <>;

if ($ok_list eq "no") {
	print "[$0]: Analysis Stoped\n";
	exit;
}

print "[$0]: All good\n";

# 2.Create header and RAW file
open(IMA_LIST, "ima_list.in") or die "Could not open IMA_LIST file\n";

while ($ima_file = <IMA_LIST>){
	chomp($ima_file);
	`./ima_mrs2raw_hdr -in $ima_file`;
	my($filename, $dirs, $suffix) = fileparse($ima_file);
	print "[$0]: $filename raw file created\n";
}
print "[$0]:raw files created\n";
close(IMA_LIST);


# 3. Create control file

open(IMA_LIST, "ima_list.in") or die "Could not open IMA_LIST file\n";

while ($ima_file = <IMA_LIST>){
        chomp($ima_file);
        `./lcm_create_control $ima_file` ;
        my($filename, $dirs, $suffix) = fileparse($ima_file);
        print "[$0]: $filename control file created\n";
}
print "[$0]:control files created\n";
close(IMA_LIST);

# 4. Execute lcmodel files
open(IMA_LIST, "ima_list.in") or die "Could not open IMA_LIST file\n";

while ($ima_file = <IMA_LIST>){
        chomp($ima_file);
        my($filename, $dirs, $suffix) = fileparse($ima_file, qr/.ima/);
				`chmod +x "$dirs$filename.lcmodel"`;
				`"$dirs./$filename.lcmodel"`;
	print "[$0]: Lcmodel Output Created\n";
}
print "[$0]: Lcmodel analisis terminated\n";
close(IMA_LIST);

# 5. Create txt files from .table files

open(IMA_LIST, "ima_list.in") or die "Could not open IMA_LIST file\n";

while ($ima_file = <IMA_LIST>){
        chomp($ima_file);
        my($filename, $dirs, $suffix) = fileparse($ima_file, qr/.ima/);
				`./lcm_table2txt_sv "$dirs$filename.table"`;
	print "[$0]: lc_out txt file created\n";
}
print "[$0]: All lc_out txt files created\n";
close(IMA_LIST);

# 6. Create project text file

open(IMA_LIST, "ima_list.in") or die "Could not open IMA_LIST file\n";

$ima_file = <IMA_LIST>;
chomp($ima_file);
my($filename, $dirs, $suffix) = fileparse($ima_file, qr/.ima/);
`./create_project_txt.pl -c "$dirs$filename.lc_out"`;

while ($ima_file = <IMA_LIST>){
        chomp($ima_file);
	$count = $count + 1;
        my($filename, $dirs, $suffix) = fileparse($ima_file, qr/.ima/);
	`./create_project_txt.pl -u "$dirs$filename.lc_out"`;
	print "[$0]: txt Output Created\n";
}

print "[$0]: Project txt file done\n";
close(IMA_LIST);
