#Checking for available updates
Write-Host "  Checking for available updates... Please wait!" -ForegroundColor 'Yellow'
$UpdateSession = New-Object -ComObject Microsoft.Update.Session
$SearchResult = $UpdateSession.CreateUpdateSearcher().Search($criteria).Updates | ? {$_.Title -notmatch $skipUpdates}
$SearchResult = $SearchResult | Sort-Object LastDeploymentChangeTime -Descending
$totalUpdates = $SearchResult.Count

ForEach ($Update in $SearchResult) {
	If ($totalUpdates -eq $null) { $totalUpdates = 1}
	# Add Update to Collection 
	$UpdatesCollection = New-Object -ComObject Microsoft.Update.UpdateColl
	if ($Update.EulaAccepted -eq 0) { $Update.AcceptEula() }
	$null = $UpdatesCollection.Add($Update)
	
	# Download
	$fileSize = "{0:N0} MB" -f ($($Update.MaxDownloadSize) / 1MB)
	Write-Host "  Downloading ($($counter.ToString("00"))/$($totalUpdates.ToString("00"))) - $fileSize - " -ForegroundColor 'Yellow' -NoNewline
	$counter++
	Write-Host "$($Update.Title)" -ForegroundColor 'White'
	$UpdatesDownloader = $UpdateSession.CreateUpdateDownloader()
	$UpdatesDownloader.Updates = $UpdatesCollection
	$UpdatesDownloader.Priority = 3

	Write-Host "`t- Download " -NoNewline -ForegroundColor 'White'
	$DownloadResult = $UpdatesDownloader.Download()
	Switch ($DownloadResult.ResultCode) {
		0   { Write-Host "Not Started" -ForegroundColor 'Black' -BackgroundColor 'Yellow' }
		1   { Write-Host "In Progress" -ForegroundColor 'Black' -BackgroundColor 'Yellow' }
		2   { Write-Host "Succeeded" -ForegroundColor 'Green' }
		3   { Write-Host "Succeeded (with Errors)" -ForegroundColor 'Black' -BackgroundColor 'Yellow' }
		4   { Write-Host "Failed" -ForegroundColor 'White' -BackgroundColor 'Red' }
		5   { Write-Host "Aborted" -ForegroundColor 'White' -BackgroundColor 'Red' }
	}

	# Install
	$UpdatesInstaller = $UpdateSession.CreateUpdateInstaller()
	$UpdatesInstaller.Updates = $UpdatesCollection

	Write-Host "`t- Install  " -NoNewline -ForegroundColor 'White'
	$InstallResult = $UpdatesInstaller.Install()
	Switch ($installResult.ResultCode) {
		0   { Write-Host "Not Started" -ForegroundColor 'Black' -BackgroundColor 'Yellow' }
		1   { Write-Host "In Progress" -ForegroundColor 'Black' -BackgroundColor 'Yellow' }
		2   { Write-Host "Succeeded" -ForegroundColor 'Green' }
		3   { Write-Host "Succeeded (with Errors)" -ForegroundColor 'Black' -BackgroundColor 'Yellow' }
		4   { Write-Host "Failed" -ForegroundColor 'White' -BackgroundColor 'Red' }
		5   { Write-Host "Aborted" -ForegroundColor 'White' -BackgroundColor 'Red' }
	}
	# Change the line below if you don't want to automatically reboot...
	If ($installResult.rebootRequired -eq 'True') { $needsReboot = $true }
}
