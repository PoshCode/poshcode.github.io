## CONFIG START ##
	
	# Service messages and logging variables.
	$timeNow = get-date -Format g
	$serviceStop =  $timeNow + " Service has stopped."
	$serviceStart =  $timeNow + " Service has started."
	
	$PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
	Set-Location -Path "$PSScriptRoot"
		
	# Load configuration XML
	[xml]$configfile = Get-Content configuration.xml
	
	# Load createSignature function
	Import-Module $configfile.settings.modulepath
	
	# If siglogs do not exist create them.
	
	if ((Test-Path $configfile.settings.siglog) -eq $false) {
		New-Item $configfile.settings.siglog -type file
		}
	
	if ((Test-Path $configfile.settings.siglogerror) -eq $false) {
		New-Item $configfile.settings.siglogerror -type file
		}
	
	# If Tempdir does not exist create it.
	
	if ((Test-Path $configfile.settings.tempdir) -eq $false) {
		New-Item $configfile.settings.tempdir -type folder
		}
	
	# If output path is not found log and stop service.
	
	if ((Test-Path $configfile.settings.outputdir) -eq $false) {
		"Error`: Output path is invalid. Please check configuration.xml and restart service." | Out-File $configfile.settings.siglogerror -Append
		$serviceStop | Out-File $configfile.settings.siglogerror -Append
		break
		}
	
	# If module is not found log and stop service.
	
	if ((Test-Path $configfile.settings.modulepath) -eq $false) {
		"Error`: createSignature.psm1 not found. Please check configuration.xml and restart service." | Out-File $configfile.settings.siglogerror -Append
		$serviceStop | Out-File $configfile.settings.siglogerror -Append
		break
		}
	
	# Load created signatures log.
	$sigLog = Get-Content -path $configfile.settings.siglog
	
## CONFIG END ##
		
# Log service start.

$serviceStart | Out-File $configfile.settings.siglogerror -Append

# For each user generate HTML signature.

while($true) {

	try {
		$getUser = Get-ADUser -Searchbase $configfile.settings.searchbase -Properties * -Filter {Enabled -eq $true -and Mail -like '*'} | Where {$sigLog -notcontains $_.SamAccountName}
		$timeNow + " Signatures for " + $getUser.Count + " users to be created." | Out-File $configfile.settings.siglogerror -Append
		}
	catch {
		$timeNow + " Searchbase error. Please check configuration.xml and restart service`: $_" | Out-File $configfile.settings.siglogerror -Append
		$serviceStop | Out-File $configfile.settings.siglogerror -Append
		break
		}
		
	$getUser | foreach {
			
		# Set signature filename per user and pull in variables from getUser.
		$sigFilename = ($_.samaccountname)+".htm"
		
		# Create signature using function in temp dir then copy to output dir. Out-file does not play nicely wit UNC paths so is necessary.
		
		$sigtempFile = $configfile.settings.tempdir + "\" + $sigFilename
		$copyDir = $configfile.settings.outputdir + "\" + $sigFilename
		
		createSignature -template $configfile.settings.template -Name $_.Name -Title $_.title -StreetAddress $_.streetAddress -City $_.City -postalCode $_.postalCode -OfficePhone $_.OfficePhone -MobilePhone $_.mobilePhone -Company "Paperchase Products Ltd" -Sigpath $sigtempFile
		
		Copy-Item $sigtempFile $copyDir -Force
		Remove-Item $sigtempFile -Force
		
		# Log signature creation
		if ((Test-Path $copyDir) -eq $true) {
			($_.samaccountname) | Out-File $configfile.settings.siglog -Append
			}
		else {
			"Error creating`:" + ($_.samaccountname) | Out-File $configfile.settings.siglogerror -Append
			}
		
		}
	
	start-sleep -Seconds $configfile.settings.generationinterval
}

