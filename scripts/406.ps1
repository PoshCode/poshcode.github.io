function New-UrlFile
{
	param( $URL = "http://www.google.com")
	$UrlFile = [system.io.Path]::ChangeExtension([system.io.Path]::GetTempFileName(),".url")
	$UrlFileContents = `
		"[InternetShortcut]",
		"URL=$URL"
	$UrlFileContents | Set-Content -Path $UrlFile
	Get-Item $UrlFile
}

function Find-MSDN
 {
	param( $Class,
	$DotNetVersion = "2.0",
	$Section = ""
	)
	switch ($DotNetVersion) {
		"1.1"	{ $VersionStem = "(VS.71)"; break}
		"2.0"	{ $VersionStem = "(VS.80)"; break}
		"3.0"	{ $VersionStem = "(VS.85)"; break}
		"3.5"	{ $VersionStem = ""; 		break}
	}
	switch ($Section) {
		"Members"		{ $SectionStem = "_members"; break}
		"Methods"		{ $SectionStem = "_methods"; break}
		"Properties"	{ $SectionStem = "_properties"; break}

	}
	$UrlFile = New-UrlFile "http://msdn2.microsoft.com/en-us/library/$Class$SectionStem$VersionStem.aspx"
	Invoke-Item $UrlFile
	Remove-Item $UrlFile
}
