while ($TRUE) {
	$Requests = get-moverequest|get-moverequeststatistics
	$Requests | Foreach-Object {
		if ($_.status -eq "InProgress") {
			Write-Host -foregroundcolor "Yellow" "Mailbox move for $($_.Displayname) is in progress and is $($_.PercentComplete)% complete"
		}
		elseif ($_.status -eq "Completed"){
			Write-Host -ForegroundColor "Green" "Mailbox move for $($_.Displayname) is complete. $($_.BaditemsEncountered) bad items were encountered"
		}
		elseif ($_.status -eq "Queued"){
			Write-Host -ForegroundColor "RED" "Mailbox move for $($_.Displayname) is still queued"
		}

	}
	Start-sleep -seconds 10
	Clear-Host
}
