#!/bin/bash
#############################################
# The following lines are parameters for SLURM job submission, and can be ignored if running locally
############################################
#SBATCH --time=144:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4 
#SBATCH --mem=24000

############################################################################
# Convert functional MRI data to BIDS folder
# Uses dcm2niix to convert dicoms to BIDS compatible folder structure with appropriate json files. 
# Requires an accompanying Parameters file to run.
# Takes as input: SubjectID (as labeled on the dicoms folder), name of functional file, output/BIDS folder path,
# & Dicom/Input directory.
# -junaid.salim.merchant 2018.07.30
############################################################################
#
############################################
# The following lines are parameters for SGE job submisson and can be ignored if running locally
############################################
# Use current working directory
#$ -cwd
# Combine job and error logs
#$ -j y
# Name of job/error log
#$ -N BidsConvertFunc
# Directory where job/error logs are written. !CHANGE THIS!
#$ -o ~/Desktop
# Use bash
#$ -S /bin/bash
#$ -V
#
if [ $# -ne 2 ]; then
	echo "This is script is to convert functional, structural, & fieldmap MRI data into BIDS format."
	echo ""
	echo "Takes parameters file as input, which defines the subject IDs, paths, and files to covert."
	echo ""
	echo "USAGE: ./BidsConvert.sh </path/to/parameters/file> <SubID>"
	exit;
fi
#
#
source $1
#
SubID=$2
#
# Loop through all the subjects and convert
for s in ${SubID[@]}; do
	#
	echo "Working on $s:"
	# Take in the subject ID from first input, but remove any dashes or special characters
	subid=${s//[-._]/}
	#
	# Assign output subject directory, and make dir if there isn't one.
	outdir=${OutDir}/sub-${subid}
	if [ ! -d $outdir ]; then
		mkdir $outdir
	fi
	#
	#
	#### START WORKING ON FUNCTIONALS ############################################
	# Assign output func directory, and make dir if there isn't one.
	if [ ! -d $outdir/func ]; then
		mkdir $outdir/func
	fi
	#
	# First, get a count for all the functional folders that need Converting
	Count=$(seq 0 $((${#FuncDcms[@]}-1)))
	#
	# Then use this count to loop through the functional files
	for c in ${Count[@]}; do
		funcD=${FuncDcms[$c]}
		funcN=${FuncName[$c]}
		echo "-- $funcN"
		#
		# Get input directory by searching the subject dicom folder for the
		# current functional.
		indir=$(find $DcmDir/$s -type d -name *$funcD*)
		#
		# Check to see if there was only one directory of that name. If there
		# are multiple folders, select the last one and send message.
		# Note that if a functional is suppposed to have more than one run, make
		# sure to indicate that in the parameters file.
		if [ $(find $DcmDir/$s -type d -name *$funcD* | wc -l) -gt 1 ]; then
			echo "Attention: there is more than one directory for $funcD , please check!"
			echo "Using the last directory for now..."
			indir=$(ls -d -v $DcmDir/$s/*/*$funcD* | tail -1)
			echo $indir
		fi
		#
		# Now you can convert that functional, and label it with the appropriate
		# label in the FuncName list:
		$Vert -o $outdir/func/ -f sub-${subid}_task-${FuncName[$c]}_bold -b y -ba y -z y $indir >> log.txt
		#
		# End functional loop.
	done
	#
	#### START WORKING ON STRUCTURALS ############################################
	# Assign output anat directory, and make dir if there isn't one.
  echo "-- anat/T1w"
  if [ ! -d $outdir/anat ]; then
		mkdir $outdir/anat
	fi
	#
	# Get input directory by searching the subject dicom folder for the
	# structural. It's currently set up only for one structural.
	indir=$(find $DcmDir/$s -type d -name *$StrctDcms*)
	#
	# Check to see if there was only one directory of that name. If there
	# are multiple folders, select the last one and send message.
	if [ $(find $DcmDir/$s -type d -name *$StrctDcms* | wc -l) -gt 1 ]; then
		echo "Attention: there is more than one directory for $StrctDcms , please check!"
		echo "Using the last directory for now..."
		indir=$(ls -d -v $DcmDir/$s/*/*$StrctDcms* | tail -1)
	fi
	#
	# Convert MPRAGE and label with '_T1w' as per BIDS specification.
	$Vert -o $outdir/anat/ -f sub-${subid}_T1w -b y -ba y -z y $indir >> log.txt

	# end subject loop
done

