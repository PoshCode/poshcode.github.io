# to load c:\powershellscripts\cluster_utils.ps1 if it isn't already loaded
@@. require cluster_utils

Here are the functions:

$global:loaded_scripts=@{}
function require([string]$filename){      
	if (!$loaded_scripts[$filename]){           
		. c:\powershellscripts\$filename
		$loaded_scripts[$filename]=get-date     
	}
}

function reload($filename){     
	. c:\powershellscripts\$filename.ps1     
	$loaded_scripts[$filename]=get-date
}
