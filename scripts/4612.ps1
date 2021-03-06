function get-currentPayOffInYears {
	[cmdletbinding()]
	param(
		[Parameter(Mandatory=$true,Position=1)]
			[double]$additionalCost, 
		[Parameter(Mandatory=$true,Position=2)]
			[double]$yearlyMiles,
		[Parameter(Mandatory=$true,Position=3)]
			[int]$newMPG, 
		[Parameter(Mandatory=$true,Position=4)]
			[int]$oldMPG,
		[Parameter(Mandatory=$true,Position=5)]
			[double]$GasPrice
	)
	[int]$savingsMPG = [int]$newMPG - [int]$oldMPG
	[double]$timeToPayOffInYears = $additionalcost / (($yearlymiles / $savingsMPG) * $gasprice)
	
	Write-Host "--------------------------------------------------------------"
	write-host "If an item cost: "-NoNewline
	Write-Host -ForegroundColor 'blue' "$additionalcost " -NoNewline
	write-host "dollars and saves you: " -NoNewline
	Write-Host -ForegroundColor 'blue' "$savingsMPG miles/gallon " -NoNewline
	Write-Host "and you drive: "-NoNewline
	Write-Host -ForegroundColor 'blue' "$yearlyMIles " -NoNewline
	write-host "miles per year"
	write-host "`nYour time in years to pay it off is : "-NoNewline
	Write-Host -ForegroundColor 'blue' "$additionalcost dollars / (($yearlymiles miles)" -nonewline
	write-host -ForegroundColor 'blue' '/' -nonewline
	write-host -ForegroundColor 'blue' "$savingsMPG mpg)" -nonewline
	write-host -ForegroundColor 'blue' '*' -nonewline
	write-host -ForegroundColor 'blue' "$gasprice dollars/gallon): "-NoNewline
	$today = Get-Date
	
	$timetoPayoffInDays = $timeToPayOffInYears * 365
	$timetoPayoffInDays = [math]::Round($timetoPayoffInDays)
	
	$futureDate = $today.AddDays($timetoPayoffInDays)
	write-host -ForegroundColor 'red' "$timeToPayOffInYears years"
	write-host "This investment will pay off on: "-NoNewline
	Write-Host -ForegroundColor 'red' "$futureDate"
	Write-Host "--------------------------------------------------------------"
	
	return [double]$timeToPayOffInYears
}
function get-currentPayOffIfInvested{
	[cmdletbinding()]
	
	param(
		[Parameter(Mandatory=$true,Position=1)]
			[double]$currentPayOffInYears, 
		[Parameter(Mandatory=$true,Position=2)]
			[double]$Principle, 
		[Parameter(Mandatory=$true,Position=3)]
			[int]$interestRate, 
		[Parameter(Mandatory=$true,Position=5)]
			[double]$yearlyMiles,
		[Parameter(Mandatory=$true,Position=6)]
			[int]$newMPG, 
		[Parameter(Mandatory=$true,Position=7)]
			[int]$oldMPG,
		[Parameter(Mandatory=$true,Position=8)]
			[double]$GasPrice
	
	)
	[double]$interest = $interestRate / 100
	[double]$FVIFBase = (1 + $interest) 
	[double]$FVIF = [math]::Pow($FVIFBase, $currentPayOffInYears)
	[double]$FV = $Principle * $FVIF
	
	$FVString = "{0:N2}" -f $FV
	[int]$savingsMPG = [int]$newMPG - [int]$oldMPG
	[double]$timeToPayOffInYears = $FV / (($yearlymiles / $savingsMPG) * $gasprice)
	
	Write-Host "--------------------------------------------------------------"
	write-host "`nIf invested at $interestRate % then you will have " -NoNewline
	Write-Host -ForegroundColor "blue" "$FVString dollars in $currentpayoffInYears years: $FVString dollars"
	
	write-host "If an Item cost: "-NoNewline
	Write-Host -ForegroundColor 'blue' "$FV "-NoNewline
	write-host "and saves you: " -NoNewline
	Write-Host -ForegroundColor 'blue' "$savingsMPG miles/gallon"
	write-host "`nYour time in years to pay it off is: "-NoNewline
	Write-Host -ForegroundColor 'blue' "$FVString dollars / (($yearlymiles miles)" -nonewline
	write-host -ForegroundColor 'blue' '/' -nonewline
	write-host -ForegroundColor 'blue' "$savingsMPG mpg)" -nonewline
	write-host -ForegroundColor 'blue' '*' -nonewline
	write-host -ForegroundColor 'blue' "$gasprice dollars/gallon): "-NoNewline
	
	$today = Get-Date
	$timetoPayoffInDays = $timeToPayOffInYears * 365
	$timetoPayoffInDays = [math]::Round($timetoPayoffInDays)
	
	$futureDate = $today.AddDays($timetoPayoffInDays)
	write-host -ForegroundColor 'red' "$timeToPayOffInYears years"
	write-host "The investment will pay off on: "-NoNewline
	Write-Host -ForegroundColor 'red' "$futureDate"
	Write-Host "--------------------------------------------------------------"
	return $FV
}


[string]$additionalCost = read-host "Enter Addl cost of an item"
[int]$yearlyMiles = read-host "Enter 12 mo avg miles per year"
[int]$newMPG = read-host "Enter new MPG"
[int]$oldMPG = read-host "Enter old MPG"
[double]$GasPrice = read-host "Enter price of gasoline"


$returnValue = get-currentPayOffInYears -additionalCost $additionalCost -GasPrice $GasPrice -newMPG $newMPG -oldMPG $oldMPG -yearlyMiles $yearlyMiles

if((Read-Host "Would you like to see what it would be if invested?(y/n)") -match 'y'){
	$FVCost = get-currentPayOffIfInvested -currentPayOffInYears $returnValue -Principle $additionalCost -interestRate (Read-Host "Enter your anticipated integer interest rate for the above duration(i.e. 3 for 3 %)") -yearlyMiles $yearlyMiles -GasPrice $GasPrice -newMPG $newMPG -oldMPG $oldMPG 
}
