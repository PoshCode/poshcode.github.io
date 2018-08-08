function New-UrlFile
{
	param( $URL = "http://www.google.com")
	$UrlFile = [system.io.Path]::ChangeExtension([system.io.Path]::GetTempFileName(),".url")
	$UrlFileContents = `
		"[InternetShortcut]",
		"URL=$URL"
	Write-Host $URL
	$UrlFileContents | Set-Content -Path $UrlFile
	Get-Item $UrlFile
}

