# Roll-Dice.ps1
# Cody Bunch
# ProfessionalVMware.com

Begin {
	$rand = New-Object System.Random
	$dice = $rand.next(1,4)
}

Process {
	if ( $_ -isnot [VMware.VimAutomation.Types.Snapshot] ) { continue }
	if ($dice -gt 1) { 
		$_ | Remove-Snapshot -Confirm:$false
		Write-Host "OH NOES! Snapshot $_ Has been deleted!`n" 
	} else {
		Write-Host "Snapshot $_ lives to fight again!`n"
	}
}
