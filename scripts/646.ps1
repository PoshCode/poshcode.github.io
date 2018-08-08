function Invoke-SSH {
	param (
		[string]$Server = "$(throw 'Server is a mandatory parameter.')",
		$Credential = "$(throw 'Credential is a mandatory parameter.')",
		[switch]$Echo = $true,
		[string]$Command = "$(throw 'Command is a mandatory parameter.')"
	)
	# Since function name is same as cmdlet, we have to fully-qualify cmdlet name using format Snapin\Cmdlet
	$ShellObject = Netcmdlets\Invoke-SSH -Server $Server -Credential $Credential -Force -Command $Command
	# Foreach loop creates a string array from the output, one line per array item
	$Output = $ShellObject | ForEach-Object { ($_.Text).split("`n") }
	# By default will simulate a bash-like prompt with username and server. Good for pasting in emails.
	if ( $Echo ) {
		$UserName = $Credential.UserName -replace "\\"
		Write-Host -foregroundcolor Yellow "$UserName@$Server # $Command"
	}
	Write-Output $Output
}
