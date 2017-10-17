function Get-UNCPath {param(	[string]$HostName,
				[string]$LocalPath)
	$NewPath = $LocalPath -replace(":","$")
	#delete the trailing \, if found
	if ($NewPath.EndsWith("\")) {
		$NewPath = [Text.RegularExpressions.Regex]::Replace($NewPath, "\\$", "")
	}
	"\\$HostName\$NewPath"
}
