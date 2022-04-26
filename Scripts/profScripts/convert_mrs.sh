#!/bin/tcsh -f
#=========
#
#
#


set program = $0
set program = $program:t

set rda_hdr        = "rda_hdr"
set rda_data       = "rda_data"
set rda_ext        = "rda"

set ima_mrs2raw_hdr	= "ima_mrs2raw_hdr"		# Matlab function embedded




##set ima or rda files 
set rda_files = `echo ${1:r}*.[i,I,r][m,M,d][a,A]`


if ( $#rda_files >= 1 ) then

	foreach rda_file ( ${rda_files} )
		set rda_ima = ${rda_file:e}

		if ( ${rda_ima} == "ima" ) then

			echo "[${program}]: Converting *.ima to raw and rda_hdr"
			${ima_mrs2raw_hdr} -in ${rda_file} -out ${rda_file:r}	

			rm -f ${rda_file:r}.txt
			rm -f ${rda_file:r}.gdcm
		endif
	
		## header file info
	
   		set rda_hdr_file = "${rda_file:r}.${rda_hdr}"
   	

		

   		set studydate     = `awk '/StudyDate/ { printf ("%d", $2) }' ${rda_hdr_file}`
   		set studytime     = `awk '/StudyTime/ {print $2}' ${rda_hdr_file} | cut -c1-4`
   		set instancetime  = `awk '/InstanceTime/ {print $2}' ${rda_hdr_file}`

###
 
   		set institute     = `awk '/InstitutionName/' ${rda_hdr_file} | cut -d: -f2 | cut -c1-33 |  tr '[:upper:]' '[:lower:]'`
   		set institute     = `echo $institute | sed "s/\ /_/g"`
   		set modelname     = `awk '/ModelName/ { print $2 }' ${rda_hdr_file} | cut -c1-17 |  tr '[:upper:]' '[:lower:]'`
   		set freq_mhz      = `awk '/MRFrequency/ { print $2 }' ${rda_hdr_file}`
   		set freq_integer  = `printf "%s\n" ' int( '${freq_mhz}' ) ' | new_bc`
   		set stationname   = `awk '/StationName/ { print $2 }' ${rda_hdr_file} |  tr '[:upper:]' '[:lower:]'`

   		if ( $freq_integer == 68 || $freq_integer == 49 || $freq_integer == 120 ) then
			set nuclei = "31P"
   		else
			set nuclei = "1H"
   		endif


   		set freq_hz       = `printf "%s\n" 'scale = 6; '${freq_mhz}' * 1000000' | bc`
   		set studydate_year  = `echo $studydate | cut -c1-4`
   		set studydate_month = `echo $studydate | cut -c5,6`
   		set studydate_day   = `echo $studydate | cut -c7,8`
   		set acq_date        = "${studydate_month}/${studydate_day}/${studydate_year}"
   		set proc_date = `date +%m/%d/%Y`



   		set scan_matrix_x = `awk '/CSIMatrixSizeOfScan\[0\]:/ { printf ("%d", $2) }' ${rda_hdr_file}`
   		set series_name = `awk '/SeriesDescription:/ { printf $2 }' ${rda_hdr_file}`

   		set csimat0       = `awk '/CSIMatrixSize\[0\]:/ { printf ("%d", $2) }' ${rda_hdr_file}`
   		set csimat1       = `awk '/CSIMatrixSize\[1\]:/ { printf ("%d", $2) }' ${rda_hdr_file}`
   		set csimat2       = `awk '/CSIMatrixSize\[2\]:/ { printf ("%d", $2) }' ${rda_hdr_file}`
   		set vectorsize    = `awk '/VectorSize/ { printf ("%d", $2) }' ${rda_hdr_file}`

   		set tr            = `awk '/TR:/ { printf ("%d", $2) }' ${rda_hdr_file}`
   		set tr            = `python -c "print int(float('${tr}'))"`
   		set te            = `awk '/TE:/ { printf ("%d", $2) }' ${rda_hdr_file}`

  		set pnts          = `awk '/VectorSize/ { printf ("%d", $2) }' ${rda_hdr_file}`
   		set field         = `awk '/MagneticFieldStrength/ { print $2 }' ${rda_hdr_file}`
   		set freq_hz       = `printf "%s\n" 'scale = 6; '${freq_mhz}' * 1000000' | bc`

   		set series        = `awk '/SeriesNumber/ { print $2 }' ${rda_hdr_file}`
   		set acq           = `awk '/AcquisitionNumber/ { print $2 }' ${rda_hdr_file}`
   		set avg           = `awk '/NumberOfAverages/ {print $2}' ${rda_hdr_file}` 

   		set instance_no	 = `awk '/InstanceNumber/ {print $2}' ${rda_hdr_file}`

   		set sequence_org  = `awk '/SequenceName/ { print $2 }' ${rda_hdr_file} | tr -d "*"`

   		set seq_short     = `awk '/global\tspec_sequence\t'${sequence_org}'\t/ {print $4}' $par_config_file`
   		set seq           = `awk '/global\tspec_sequence\t'${sequence_org}'\t/ {print $5}' $par_config_file`
   
   		set sv_csi        = `awk '/global\tspec_sequence\t'${sequence_org}'\t/ {print $7}' $par_config_file`
   		set sequence      = "${seq_short}_${seq}"

   
	
   		set voi_pos_z     = `awk '/VOIPositionTra/ { print $2 }' ${rda_hdr_file}`

   		if ( $voi_pos_z != "" ) then
      		set voi_pos_x     = `awk '/VOIPositionSag/ { print $2 }' ${rda_hdr_file}`
      		set voi_pos_y     = `awk '/VOIPositionCor/ { print $2 }' ${rda_hdr_file}`

      		set voi_thick_z   = `awk '/VOIThickness/ { printf ("%d", $2) }' ${rda_hdr_file}`
      		set voi_thick_x   = `awk '/VOIReadoutVOV/ { printf ("%d", $2) }' ${rda_hdr_file}`
      		if ( $voi_thick_x == "" ) set voi_thick_x   = `awk '/VOIReadoutFOV/ { printf ("%d", $2) }' ${rda_hdr_file}`  
      		set voi_thick_y   = `awk '/VOIPhaseFOV/ { printf ("%d", $2) }' ${rda_hdr_file}`
   		else
      		set voi_pos_x     = `awk '/PositionVector\[0\]:/ { printf ("%d", $2) }' ${rda_hdr_file}`
      		set voi_pos_y     = `awk '/PositionVector\[1\]:/ { printf ("%d", $2) }' ${rda_hdr_file}`
      		set voi_pos_z     = `awk '/PositionVector\[2\]:/ { printf ("%d", $2) }' ${rda_hdr_file}`

      		set voi_thick_y   = `awk '/FoVHeight:/ { printf ("%d", $2) }' ${rda_hdr_file}`
     		 set voi_thick_x   = `awk '/FoVWidth:/ { printf ("%d", $2) }' ${rda_hdr_file}`
      		set voi_thick_z   = `awk '/SliceThickness:/ { print $2 }' ${rda_hdr_file}`
   		endif

   set loc           =  "${voi_pos_x}x${voi_pos_y}x${voi_pos_z}"
   set voi_dim       =  "${voi_thick_x}x${voi_thick_y}x${voi_thick_z}"
   set volume        = `printf "%s\n" 'scale = 6; '${voi_thick_z}' * '${voi_thick_x}' * '${voi_thick_y}'/1000' | bc` 

 
   if ( ${avg:r} >= 2 && ${tr} <= 6000 && ${scan_matrix_x} == 1 && ${seq} != "mega" ) then
      	set sup_unsup = "m"
      	set sup_unsup2 = "metabolite"
	else if ( ${avg:r} >= 2 && ${tr} >= 6001 && ${scan_matrix_x} == 1 && ${seq} != "mega" ) then
      	set sup_unsup = "w"
      	set sup_unsup2 = "water"
    #else if ( ${avg:r} >= 16 && ${scan_matrix_x} == 1 && ${seq} == "fid" ) then
     	#set sup_unsup = "m"
     	#set sup_unsup2 = "metabolite"
   	else if ( ${avg:r} <= 3 && ${scan_matrix_x} >= 9 && ${seq} != "mega" ) then
     	set sup_unsup = "m"
     	set sup_unsup2 = "metabolite"
   	else if ( ${avg:r} <= 4 &&  ${scan_matrix_x} >= 2 && ${scan_matrix_x} <= 9 && ${seq} != "mega" ) then
     	set sup_unsup = "w"
     	set sup_unsup2 = "water"
   	else if ( ${avg:r} >= 16 && ${scan_matrix_x} >= 7 && ${seq} != "mega" ) then
      	set sup_unsup = "m"
      	set sup_unsup2 = "metabolite"
   	else if ( ${avg:r} >= 7 && ${scan_matrix_x} == 0 && ${seq} != "mega" ) then
        set sup_unsup = "m"
		set sup_unsup2 = "metabolite"
   	else if ( ${seq} == "mega" && ${instance_no} == "1" && ${avg:r} >= 7 ) then
        set sup_unsup = "n"
		set sup_unsup2 = "edit-off"
   	else if ( ${seq} == "mega" && ${instance_no} == "2"  && ${avg:r} >= 7 ) then
        set sup_unsup = "e"
		set sup_unsup2 = "edit-on"
   	else if ( ${seq} == "mega" && ${instance_no} == "1" && ${avg:r} <= 4 ) then
        set sup_unsup = "w"
		set sup_unsup2 = "edit-off-water"
   	else if ( ${seq} == "mega" && ${instance_no} == "2"  && ${avg:r} <= 4 ) then
        set sup_unsup = "x"
		set sup_unsup2 = "edit-on-water-x"
   	else
      	echo "default value"
      	set sup_unsup = "w"
		set sup_unsup2 = "water"
   	endif
 


	## voxel location - hardwired
	set side = "r"
	set region = "pfc"


	## define output file names
	set new_rda_file = "${base}${time_pt}_${region}_${side}_${series}${sup_unsup}${acq}.${rda_ima}"
	set new_hdr_file = "${base}${time_pt}_${region}_${side}_${series}${sup_unsup}${acq}.${rda_hdr}"
	set new_raw_file = "${base}${time_pt}_${region}_${side}_${series}${sup_unsup}${acq}.raw"


### CREATING LC Model RAW File
###



	if ( -d ./temp ) rm -r -f ./temp

	if ( ! -e ${new_raw_file} ) then

		if ( $sup_unsup == "m" ) then
			echo "CREATING MET:   ${new_rda_file:r}.raw"
			mkdir -p ./temp/met
		  	$lc_bin2raw ${data_path}/${new_rda_file} ${data_path}/temp/ met
		  	mv -f ./temp/met/RAW ${new_rda_file:r}.raw
			#sed -i "s/how's/how_s/g" ${new_rda_file:r}.raw

		  	set title = `sed 's/\*//' ${data_path}/temp/met/cpStart | awk '/title=/'`
		  	echo $title >  ${new_rda_file:r}.title

		  	mv -f ./temp/met/extraInfo ${new_rda_file:r}.extraInfo
		  	mv -f ./temp/met/error ${new_rda_file:r}.error
		  	mv -f ./temp/met/cpStart ${new_rda_file:r}.cpStart

		else
 			mkdir -p ./temp/h2o
		  	echo "CREATING H2O:  ${new_rda_file:r}.raw"
		  	$lc_bin2raw ${data_path}/${new_rda_file} ${data_path}/temp/ h2o
		  	mv ./temp/h2o/RAW ${new_rda_file:r}.raw
		  	#sed -i "s/how's/how_s/g" ${new_rda_file:r}.raw	

		  	set title = `sed 's/\*//' ${data_path}/temp/h2o/cpStart | awk '/title=/'`
		  	echo $title >  ${new_rda_file:r}.title


		  	mv -f ./temp/h2o/extraInfo ${new_rda_file:r}.extraInfo
		  	mv -f ./temp/h2o/error ${new_rda_file:r}.error
		  	mv -f ./temp/h2o/cpStart ${new_rda_file:r}.cpStart

		endif

		rm -r ./temp
		
		 
	endif

	rda_raw2ps_plot ${new_rda_file} ${new_rda_file}
	


	end
endif




exit

