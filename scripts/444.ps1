function Get-Parameter ( $Cmdlet, [switch]$ShowCommon ) {
	foreach ($paramset in (Get-Command $Cmdlet).ParameterSets){
		$Output = @()
		foreach ($param in $paramset.Parameters) {
			if ( !$ShowCommon ) {
				if ($param.aliases -match "vb|db|ea|wa|ev|wv|ov|ob|wi|cf") { continue }
			}
			$process = "" | Select-Object Name, Type, ParameterSet, Aliases, Position, IsMandatory
			$process.Name = $param.Name
			$process.Type = $param.ParameterType.Name 
			if ( $paramset.name -eq "__AllParameterSets" ) { $process.ParameterSet = "Default" }
			else { $process.ParameterSet = $paramset.Name }
			$process.Aliases = $param.aliases
			if ( $param.Position -lt 0 ) { $process.Position = $null }
			else { $process.Position = $param.Position }
			$process.IsMandatory = $param.IsMandatory 
			$output += $process
		}
		Write-Output $Output
		#Write-Host "`n"
	}
}
