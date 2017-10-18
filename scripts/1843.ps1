function Write-EventDetail {
	param(
		$id
	)
	$id | Write-Host
	$Event | Write-Host
	$EventSubscriber | Write-Host
	$Sender | Write-Host
	$SourceEventArgs | Write-Host
	$SourceArgs | Write-Host
}

'test'
