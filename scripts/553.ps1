# ==============================================================================================
#  
# NAME: FileArchivingCrTime.ps1
# 
# AUTHOR: Saehrig ,Steven 
# DATE  : 5/19/2008
# 
# COMMENT: This script will search a directory and archive files based on create time -7 days.
# for specified extension.
# ==============================================================================================

#variables - This section defines the source and destination locations
@@$source = 'sourcefilepath'
@@$archive = 'DestinationFilepath'



#Functions - This section defines all the functions to be called below.
function ArchiveFiles{
	foreach ($a in Get-ChildItem  $source) {
@@		if ($a.Extension.Equals('.pdf') -and ($a.creationtime -lt ($(Get-Date).Adddays(-7))))
		{	
			$cm = $a.creationtime.month
			$cy = $a.creationtime.year
			if (Test-Path $archive\$cy-$cm){
				Move-Item $a.FullName $archive\$cy-$cm
			}
			else {
				New-Item -path $archive -name $cy-$cm -type directory
				Move-Item $a.FullName $archive\$cy-$cm
			}

		}	
	}
}


#Execution of Script will begin here.
ArchiveFiles
