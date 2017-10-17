Process { 
	#Get the type of object we have
	$InputTypeName = $_.GetType().Name 
    
	#Do something with that object
	#is it VMware?
	if ( $InputTypeName -eq "VMHostImpl" ) { 
        	$output = $_ | Get-View | Select-Object $VMHost_UUID 
	#is it Xen?
	} elseif ($InputTypeName -eq "Host"){
		$output = $_ | get-view | Select-Object $XenHost_UUID 
	#Otherwise throw an error
	} else { 
	        Write-Host "`nPlease pass this script either a VMHost or VM object on the pipeline.`n" 
	} 
}
