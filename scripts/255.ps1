function Get-Parameter ($Cmdlet) {
	foreach ($paramset in (Get-Command $Cmdlet).ParameterSets){
		$Output = @()
		foreach ($param in $paramset.Parameters) {
			$process = "" | Select-Object Name, ParameterSet, Aliases, IsMandatory, CommonParameter
			$process.Name = $param.Name
			if ( $paramset.name -eq "__AllParameterSets" ) { $process.ParameterSet = "Default" }
			else { $process.ParameterSet = $paramset.Name }
			$process.Aliases = $param.aliases
			$process.IsMandatory = $param.IsMandatory 
			if ($param.aliases -match "vb|db|ea|wa|ev|wv|ov|ob") { $process.CommonParameter = $TRUE }
			else { $process.CommonParameter = $FALSE }
			$output += $process
		}
		Write-Output $Output
		#Write-Host "`n"
	}
}

