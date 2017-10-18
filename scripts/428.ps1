function df ( $Path ) {
	if ( !$Path ) { $Path = (Get-Location -PSProvider FileSystem).ProviderPath }
	$Drive = (Get-Item $Path).Root -replace "\\"
	$Output = Get-WmiObject -Query "select freespace from win32_logicaldisk where deviceid = `'$drive`'"
	Write-Output "$($Output.FreeSpace / 1mb) MB"
}
