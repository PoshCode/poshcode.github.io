# Roll-Dice.ps1
# Cody Bunch
# ProfessionalVMware.com

Begin {
	$rand = New-Object System.Random
	$dice = $rand.next(1,3)
}

Process {
	if ( $_ -isnot [VMware.VimAutomation.Types.Snapshot] ) { continue }
	if ($dice -gt 1) { 
		$_ | Remove-Snapshot -Confirm:$false
		Write-Host "$_.Name OH NOES! Has been deleted!`n" 
	} else {
		Write-Host "$_.Name lives to fight again!`n"
	}
}
