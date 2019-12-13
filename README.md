
Here is all the code needed for 1) converting dicoms to bids format; 2) running fmriprep on the converted data; 3) running post-prep to get everything to an afni-ready state for modeling! Here is a quick description of the files: 

BidsConvert.sh - is the main script to convert dicoms to bids format. It is a wrapper command around dcm2niix which requires an installation to run this script. Find that here:https://github.com/rordenlab/dcm2niix . It also requires the following BidsConvertParameters.sh file to run. The basic usage is: /path/to/BidsConvert.sh /path/to/BidsConvertParameters <subject id>
The subject ID should be exactly how the dicoms folder is labelled. You can also use this on a SLURM cluster by simply adding 'sbatch' before the main usage. 
  
BidsConvertParameters.sh - is the parameters file that is used in conjunction with the BidsConvert.sh script above. Edit this file to fit the needs of your study. Instructions are contained within the script, and in the presentation

Esteban_2019_fMRIprep_NatureMethods.pdf - fmriprep nature methods publication for more information

ExtractRegressors.R - R script that extracts the relevant nuissance regressors from the confounds .tsv file produced by fmriprep. This is called by the PostPrep.sh script, and should not be edited. 

IntroductionToSupercomputing_BHG2019.pdf - A presentation I did on using supercomputers, like bswift, for neuroimaging. I included this as additional reference if anyone is interested. 

PostPrep.sh - is the script to use after running fmriprep to get everything ready to model in AFNI. There are parameters at the beginning of the file that need to be edited to meet the specifics of your study.

WTfMRIprep_LabCoreDec2019.pptx - the presentation with more information than you probably care for about this workflow.

fMRIprep_preprint.pdf - a preprint of the fmriprep paper that has a litte more details than the actual publication.

fmriprep_job_script_example.sh - here is an example script for use on bswift (or other SLURM) cluster for running through freesurfer and fmriprep. Use this as your starting point when you are setting things up!

fmriprep_reports - here is folder with example reports. if you download this folder, and launch the containing html file, it will give you an idea of the quality check reports fmriprep outputs. 
