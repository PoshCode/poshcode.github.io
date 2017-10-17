# Transcribe output to log
$null = Start-Transcript "$pwd\$([System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Definition)).log"
# Check the QAD snapins are installed
if ( (Get-PSSnapin -Name Quest.ActiveRoles.ADManagement -ErrorAction silentlycontinue) -eq $null ) {
	# The QAD snapin is not active. Check it's installed
	if ( (Get-PSSnapin -Name Quest.ActiveRoles.ADManagement -Registered -ErrorAction SilentlyContinue) -eq $null) {
		Write-Error "You must install Quest ActiveRoles AD Tools to use this script!"
	} else {
		Write-Host "Importing QAD Tools"
		Add-PSSnapin -Name Quest.ActiveRoles.ADManagement -ErrorAction Stop
	}
}
Write-Host "Beginning ADDS Replication"
Write-Host "=========================="
Get-QADComputer -ComputerRole 'DomainController' | % {
	Write-Host "Replicating $($_.Name)"
	$null = repadmin /kcc $_.Name
	$null = repadmin /syncall /A /e $_.Name
}
Write-Host "=========================="
Write-Host "Completed ADDS Replication"
Stop-Transcript
