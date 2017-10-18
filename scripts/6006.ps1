$filteredFileList = Get-ChildItem $myFolder | Where-Object {
	($_.Extension -eq ".Log") -and `
	(($db | Where-Object $_ <uh, the one from my $db|> -eq $_ <uh, the one from my Where-Object{}>) -eq $null)
