function Get-WordOutline ( $Path, [int]$MaxDepth = 9 ) {
	if ( $Path -is [System.IO.FileInfo] ) { $Path = $_.FullName }
	$word = New-Object -comObject word.application
	$document = $wordd.documents.open( $path )
	$outline = $document.paragraphs | Where-Object {
		$_.outlineLevel -le $MaxDepth
	} | ForEach-Object {
		$n = ($_.outlineLevel - 1) * 2
		' ' * $n + ($_.range.text -replace '\u000d$')
	}
	Write-Output $outline
	$document.close( [ref]$false )
	$word.quit()
}
